use std::fs;
use std::io::Read;
use std::path::PathBuf;
use std::process::Stdio;

use anyhow::{anyhow, Context, Result};
use blake3;
use colored::Colorize;
use flate2::read::GzDecoder;
use sha1::{Digest, Sha1};
use tar::Archive;
use tokio::fs as tokio_fs;
use tokio::process::Command;

const GITHUB_REPO: &str = "sigilante/nockup";
const TEMPLATES_BRANCH: &str = "master";

pub async fn run() -> Result<()> {
    let cache_dir = get_cache_dir()?;

    println!("{} Setting up nockup cache directory...", "🚀".green());
    println!(
        "{} Cache location: {}",
        "📁".blue(),
        cache_dir.display().to_string().cyan()
    );

    // Create cache directory structure
    create_cache_structure(&cache_dir).await?;

    // Download or update templates
    download_templates(&cache_dir).await?;

    // Download new toolchain files.
    download_toolchain_files(&cache_dir).await?;

    // Set default channel to stable and this architecture
    let cache_dir = get_cache_dir()?;
    let config_path = cache_dir.join("config.toml");
    let mut config = get_config()?;
    println!("📝 Config installed at: {}", config_path.display());
    config["channel"] = toml::Value::String("stable".into());
    // Get architecture of current platform.
    config["architecture"] = toml::Value::String(get_target_identifier());
    // Write architecture to config file
    fs::write(config_path, toml::to_string(&config)?).context("Failed to write config file")?;

    // Write commit details to status file.
    write_commit_details(&cache_dir).await?;

    // Download binaries for current channel.
    download_binaries(&config).await?;

    // Prepend cache bin directory to PATH for system shell rc file.
    prepend_path_to_shell_rc(&cache_dir.join("bin")).await?;

    println!("{} Setup complete!", "✅".green());
    println!(
        "{} Templates are now available in: {}",
        "📂".blue(),
        cache_dir.join("templates").display().to_string().cyan()
    );

    Ok(())
}

fn get_target_identifier() -> String {
    let arch = std::env::consts::ARCH;
    let os = std::env::consts::OS;
    
    match (arch, os) {
        ("x86_64", "linux") => "x86_64-unknown-linux-gnu".to_string(),
        ("x86_64", "windows") => "x86_64-pc-windows-msvc".to_string(),
        ("x86_64", "macos") => "x86_64-apple-darwin".to_string(),
        ("aarch64", "linux") => "aarch64-unknown-linux-gnu".to_string(),
        ("aarch64", "macos") => "aarch64-apple-darwin".to_string(),
        ("aarch64", "windows") => "aarch64-pc-windows-msvc".to_string(),
        _ => format!("{}-unknown-{}", arch, os), // fallback
    }
}

async fn prepend_path_to_shell_rc(bin_dir: &PathBuf) -> Result<()> {
    // Determine the user's shell and corresponding rc file
    let shell = std::env::var("SHELL").unwrap_or_default();
    let rc_file = if shell.contains("zsh") {
        dirs::home_dir().unwrap().join(".zshrc")
    } else if shell.contains("bash") {
        dirs::home_dir().unwrap().join(".bashrc")
    } else {
        return Ok(()); // Unsupported shell, do nothing
    };

    // Read the current contents of the rc file
    let mut contents = String::new();
    if rc_file.exists() {
        let mut file = fs::File::open(&rc_file)?;
        file.read_to_string(&mut contents)?;
    }

    // Check if the path is already prepended
    let path_entry = format!("export PATH=\"{}:$PATH\"", bin_dir.display());
    println!("{}", path_entry);
    if !contents.contains(&path_entry) {
        // Prepend the path entry
        let new_contents = format!("{}\n{}", contents, path_entry);
        fs::write(&rc_file, new_contents)?;
        println!("{} Updated {}", "📝".green(), rc_file.display());
    }

    Ok(())
}

fn get_cache_dir() -> Result<PathBuf> {
    let home = dirs::home_dir().ok_or_else(|| anyhow::anyhow!("Could not find home directory"))?;
    Ok(home.join(".nockup"))
}

async fn create_cache_structure(cache_dir: &PathBuf) -> Result<()> {
    println!("{} Creating cache directory structure...", "📁".green());

    // Create main cache directory; if it exists, overwrite
    fs::create_dir_all(cache_dir)?;

    // Create bin subdirectory
    let bin_dir = cache_dir.join("bin");
    fs::create_dir_all(&bin_dir)?;

    // Create templates subdirectory
    let templates_dir = cache_dir.join("templates");
    fs::create_dir_all(&templates_dir)?;

    println!("{} Created directory structure", "✓".green());
    Ok(())
}

async fn download_templates(cache_dir: &PathBuf) -> Result<()> {
    let templates_dir = cache_dir.join("templates");

    // Check if templates directory already has content
    if has_existing_templates(&templates_dir).await? {
        println!("{} Existing templates found, updating...", "🔄".yellow());
        update_templates(&templates_dir).await?;
    } else {
        println!("{}  Downloading templates from GitHub...", "⬇️".green());
        clone_templates(&templates_dir).await?;
    }

    Ok(())
}

async fn has_existing_templates(templates_dir: &PathBuf) -> Result<bool> {
    if !templates_dir.exists() {
        return Ok(false);
    }

    // Check if it's a git repository with our remote
    let git_dir = templates_dir.join(".git");
    if !git_dir.exists() {
        return Ok(false);
    }

    // Check if it has any content
    let entries = fs::read_dir(templates_dir)?;
    let mut count = 0;
    for entry in entries {
        let entry = entry?;
        let file_name = entry.file_name();
        if file_name != ".git" {
            count += 1;
            if count > 0 {
                // More than just .git directory
                return Ok(true);
            }
        }
    }

    Ok(false)
}

async fn clone_templates(templates_dir: &PathBuf) -> Result<()> {
    // Check Git commit HEAD of branch and compare to reported local version.
    let commit_id = get_git_commit_id().await?;
    let commit_file = templates_dir.join("commit.toml");

    // Try to read the file directly
    match tokio_fs::read_to_string(&commit_file).await {
        Ok(commit_content) => {
            let commit: toml::Value =
                toml::de::from_str(&commit_content).context("Failed to parse commit file")?;
            let local_commit_id = commit["commit"]["id"].to_string().replace("\"", "");
            if local_commit_id == commit_id {
                println!("{} Templates are up to date", "✅".green());
                return Ok(());
            }
        }
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => {
            println!("{} No local commit ID found", "🔍".yellow());
        }
        Err(e) => {
            return Err(anyhow::anyhow!("Failed to read commit file: {}", e));
        }
    }

    // Remove existing directory if it exists but is empty/corrupted
    if templates_dir.exists() {
        fs::remove_dir_all(templates_dir)?;
    }

    // Create a temporary directory for the full clone
    let temp_dir = templates_dir.parent().unwrap().join("temp_repo");
    if temp_dir.exists() {
        fs::remove_dir_all(&temp_dir)?;
    }

    let repo_url = format!("https://github.com/{}.git", GITHUB_REPO);

    // Clone the full repo to temp directory; suppress output
    let mut command = Command::new("git");
    command
        .arg("clone")
        .arg("--depth=1") // Shallow clone for faster download
        .arg("--branch")
        .arg(TEMPLATES_BRANCH)
        .arg(&repo_url)
        .arg(&temp_dir);

    command.stdout(Stdio::null());
    command.stderr(Stdio::null());
    let status = command.status().await?;

    if !status.success() {
        return Err(anyhow::anyhow!(
            "Failed to clone templates from GitHub. Exit code: {}",
            status.code().unwrap_or(-1)
        ));
    }

    // Check if templates directory exists in the repo
    let repo_templates_dir = temp_dir.join("templates");
    if !repo_templates_dir.exists() {
        // Cleanup and return error
        fs::remove_dir_all(&temp_dir).ok();
        return Err(anyhow::anyhow!(
            "No 'templates' directory found in the repository"
        ));
    }

    // Move just the templates directory to our cache location
    fs::rename(&repo_templates_dir, templates_dir)?;

    // Check if manifests directory exists in the repo
    let repo_manifests_dir = temp_dir.join("manifests");
    if !repo_manifests_dir.exists() {
        // Cleanup and return error
        fs::remove_dir_all(&temp_dir).ok();
        return Err(anyhow::anyhow!(
            "No 'manifests' directory found in the repository"
        ));
    }

    // Move just the manifests directory to our cache location
    let manifests_dir = templates_dir.parent().unwrap().join("manifests");
    fs::rename(&repo_manifests_dir, manifests_dir)?;

    // Update the commit.toml file.
    let commit_file = templates_dir.join("commit.toml");
    let commit_data = format!("[commit]\nid = \"{}\"\n", commit_id);
    fs::write(&commit_file, commit_data)?;

    // Clean up the temporary repo directory
    fs::remove_dir_all(&temp_dir)?;
    println!("{} Templates and manifests downloaded successfully", "✓".green());
    Ok(())
}

async fn update_templates(templates_dir: &PathBuf) -> Result<()> {
    // For now, just re-clone to get the latest version
    clone_templates(templates_dir).await
}
async fn download_toolchain_files(cache_dir: &PathBuf) -> Result<()> {
    let toolchain_dir = cache_dir.join("toolchain");

    // Check if toolchain directory already has content
    if has_existing_toolchain_files(&toolchain_dir).await? {
        println!(
            "{} Existing toolchain files found, updating...",
            "🔄".yellow()
        );
        update_toolchain_files(&toolchain_dir).await?;
    } else {
        println!(
            "{}  Downloading toolchain files from GitHub...",
            "⬇️".green()
        );
        clone_toolchain_files(&toolchain_dir).await?;
    }

    Ok(())
}

async fn has_existing_toolchain_files(toolchain_dir: &PathBuf) -> Result<bool> {
    if !toolchain_dir.exists() {
        return Ok(false);
    }
    let entries = fs::read_dir(toolchain_dir)?;
    for entry in entries {
        let entry = entry?;
        if entry.file_type()?.is_file() {
            return Ok(true);
        }
    }
    Ok(false)
}

async fn update_toolchain_files(toolchain_dir: &PathBuf) -> Result<()> {
    // For now, just re-clone to get the latest version
    clone_toolchain_files(toolchain_dir).await
}

async fn clone_toolchain_files(toolchain_dir: &PathBuf) -> Result<()> {
    // Remove existing directory if it exists but is empty/corrupted
    if toolchain_dir.exists() {
        fs::remove_dir_all(toolchain_dir)?;
    }

    // Create a temporary directory for the full clone
    let temp_dir = toolchain_dir.parent().unwrap().join("temp_repo");
    if temp_dir.exists() {
        fs::remove_dir_all(&temp_dir)?;
    }

    let repo_url = format!("https://github.com/{}.git", GITHUB_REPO);

    // Clone the full repo to temp directory; suppress output
    let mut command = Command::new("git");
    command
        .arg("clone")
        .arg("--depth=1") // Shallow clone for faster download
        .arg("--branch")
        .arg("master")
        .arg(&repo_url)
        .arg(&temp_dir);

    command.stdout(Stdio::null());
    command.stderr(Stdio::null());
    let status = command.status().await?;

    if !status.success() {
        return Err(anyhow::anyhow!(
            "Failed to clone toolchain files from GitHub. Exit code: {}",
            status.code().unwrap_or(-1)
        ));
    }

    // Check if toolchain directory exists in the repo
    let repo_toolchain_dir = temp_dir.join("toolchain");
    if !repo_toolchain_dir.exists() {
        // Cleanup and return error
        fs::remove_dir_all(&temp_dir).ok();
        return Err(anyhow::anyhow!(
            "No 'toolchain' directory found in the repository"
        ));
    }

    // Move just the toolchain directory to our cache location
    fs::rename(&repo_toolchain_dir, toolchain_dir)?;

    // Clean up the temporary repo directory
    fs::remove_dir_all(&temp_dir)?;
    println!("{} Toolchain files downloaded successfully", "✓".green());
    Ok(())
}

fn get_config() -> Result<toml::Value> {
    let cache_dir = get_cache_dir()?;
    let config_path = cache_dir.join("config.toml");
    if !config_path.exists() {
        write_config(&config_path)?;
    }
    let config_str = std::fs::read_to_string(&config_path).context("Failed to read config file")?;
    let config: toml::Value =
        toml::de::from_str(&config_str).context("Failed to parse config file")?;
    Ok(config)
}

fn write_config(config_path: &PathBuf) -> Result<()> {
    let default_config = format!(
        r#"channel = "stable"
architecture = "{}"
"#,
        std::env::consts::ARCH
    );
    std::fs::write(config_path, default_config).context("Failed to create default config file")?;
    Ok(())
}

async fn download_binaries(config: &toml::Value) -> Result<()> {
    let channel = config["channel"]
        .as_str()
        .ok_or_else(|| anyhow::anyhow!("Invalid channel in config"))?;
    let architecture = config["architecture"]
        .as_str()
        .ok_or_else(|| anyhow::anyhow!("Invalid architecture in config"))?;

    // Load channel details from ./toolchain/
    let channel = format!("channel-nockup-{}", channel);
    let manifest_path = format!("./toolchain/{}.toml", channel);
    let manifest = std::fs::read_to_string(&manifest_path)
        .context(format!("Failed to read channel manifest for '{}'", channel))?;
    let manifest: toml::Value = toml::de::from_str(&manifest).context(format!(
        "Failed to parse channel manifest for '{}'",
        channel
    ))?;

    println!(
        "{} Downloading binaries for channel '{}' and architecture '{}'...",
        "⬇️".green(),
        channel.cyan(),
        architecture.cyan()
    );

    // Download and verify binary archives.
    for index in ["hoon", "hoonc", "nockup"] {
        println!("{} Downloading {} binary...", "⬇️".green(), index.cyan());
        let archive_url = manifest["pkg"][index]["target"][architecture]["url"]
            .as_str()
            .ok_or_else(|| anyhow::anyhow!("{} Invalid URL for {} binary", "❌".red(), index))?;
        let archive_url = archive_url.replace("http://", "https://");
        let signature_url = format!("{}.asc", archive_url);

        let archive_blake3 = manifest["pkg"][index]["target"][architecture]["hash_blake3"]
            .as_str()
            .ok_or_else(|| {
                anyhow::anyhow!("{} Invalid Blake3 hash for {} binary", "❌".red(), index)
            })?;
        let archive_sha1 = manifest["pkg"][index]["target"][architecture]["hash_sha1"]
            .as_str()
            .ok_or_else(|| {
                anyhow::anyhow!("{} Invalid SHA1 hash for {} binary", "❌".red(), index)
            })?;

        println!("{} Blake3 checksum passed.", "✅".green());
        println!("{} SHA1 checksum passed.", "✅".green());

        // Download archive and signature
        let archive_path = download_file(&archive_url).await?;
        let signature_path = download_file(&signature_url).await?;

        // Verify GPG signature first
        verify_gpg_signature(&archive_path, &signature_path).await?;

        // Verify checksums of the archive
        verify_checksums(&archive_path, &archive_blake3, &archive_sha1).await?;

        // Extract binary from tar.gz
        let target_dir = get_cache_dir()?;
        let binary_path = target_dir.join("bin");
        fs::create_dir_all(&binary_path)?;

        extract_binary_from_archive(&archive_path, &binary_path, index).await?;

        // Clean up downloaded files
        fs::remove_file(&archive_path)?;
        fs::remove_file(&signature_path)?;
    }

    Ok(())
}

async fn verify_gpg_signature(
    archive_path: &std::path::Path,
    signature_path: &std::path::Path,
) -> Result<()> {
    println!("{} Verifying GPG signature...", "🔐".yellow());

    // Check if files exist
    if !archive_path.exists() {
        return Err(anyhow::anyhow!(
            "Archive file does not exist: {}",
            archive_path.display()
        ));
    }
    if !signature_path.exists() {
        return Err(anyhow::anyhow!(
            "Signature file does not exist: {}",
            signature_path.display()
        ));
    }

    // First attempt to verify
    let output = Command::new("gpg")
        .args([
            "--verify", //"--verbose",
            signature_path.to_str().unwrap(),
            archive_path.to_str().unwrap(),
        ])
        .output()
        .await
        .context("Failed to execute gpg command")?;

    if output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        if stderr.contains("Good signature") {
            println!("{} GPG signature verified successfully", "✅".green());
            return Ok(());
        }
    }

    // Check if it's a missing public key issue
    let stderr = String::from_utf8_lossy(&output.stderr);
    if stderr.contains("No public key") {
        println!(
            "{} Public key not found, importing from keyserver...",
            "🔑".yellow()
        );

        // Try to import the public key from keyserver
        let import_output = Command::new("gpg")
            .args([
                "--keyserver",
                "keyserver.ubuntu.com",
                "--recv-keys",
                "A6FFD2DB7D4C9710",
            ])
            .output()
            .await
            .context("Failed to import public key from keyserver")?;

        println!(
            "{} Import exit status: {}",
            "🔍".yellow(),
            import_output.status
        );
        println!(
            "{} Import stdout: {}",
            "🔍".yellow(),
            String::from_utf8_lossy(&import_output.stdout)
        );
        println!(
            "{} Import stderr: {}",
            "🔍".yellow(),
            String::from_utf8_lossy(&import_output.stderr)
        );

        if !import_output.status.success() {
            let import_stderr = String::from_utf8_lossy(&import_output.stderr);
            println!(
                "{} Failed to import public key: {}",
                "⚠️".yellow(),
                import_stderr
            );

            // Try alternative keyserver
            println!("{} Trying alternative keyserver...", "🔑".yellow());
            let alt_import = Command::new("gpg")
                .args([
                    "--keyserver",
                    "keys.openpgp.org",
                    "--recv-keys",
                    "A6FFD2DB7D4C9710",
                ])
                .output()
                .await;

            if let Ok(alt_output) = alt_import {
                println!(
                    "{} Alt import exit status: {}",
                    "🔍".yellow(),
                    alt_output.status
                );
                println!(
                    "{} Alt import stderr: {}",
                    "🔍".yellow(),
                    String::from_utf8_lossy(&alt_output.stderr)
                );

                if !alt_output.status.success() {
                    return Err(anyhow::anyhow!(
                        "Failed to import public key from keyservers. Please import manually:\n  gpg --keyserver keyserver.ubuntu.com --recv-keys A6FFD2DB7D4C9710"
                    ));
                }
            } else {
                return Err(anyhow::anyhow!(
                    "Failed to import public key. Please import manually:\n  gpg --keyserver keyserver.ubuntu.com --recv-keys A6FFD2DB7D4C9710"
                ));
            }
        }

        println!("{} Public key imported successfully", "✅".green());

        // Retry verification after importing the key
        let retry_output = Command::new("gpg")
            .args([
                "--verify",
                "--verbose",
                signature_path.to_str().unwrap(),
                archive_path.to_str().unwrap(),
            ])
            .output()
            .await
            .context("Failed to execute gpg verification after key import")?;

        println!(
            "{} Retry exit status: {}",
            "🔍".yellow(),
            retry_output.status
        );
        println!(
            "{} Retry stderr: {}",
            "🔍".yellow(),
            String::from_utf8_lossy(&retry_output.stderr)
        );

        if !retry_output.status.success() {
            let retry_stderr = String::from_utf8_lossy(&retry_output.stderr);
            return Err(anyhow::anyhow!(
                "GPG signature verification failed after key import: {}",
                retry_stderr
            ));
        }

        let retry_stderr = String::from_utf8_lossy(&retry_output.stderr);
        if retry_stderr.contains("Good signature") {
            println!("{} GPG signature verified successfully", "✅".green());
        } else {
            return Err(anyhow::anyhow!(
                "GPG signature verification failed: {}",
                retry_stderr
            ));
        }
    } else {
        return Err(anyhow::anyhow!(
            "GPG signature verification failed: {}",
            stderr
        ));
    }

    Ok(())
}

async fn extract_binary_from_archive(
    archive_path: &std::path::Path,
    target_dir: &std::path::Path,
    binary_name: &str,
) -> Result<()> {
    println!(
        "{} Extracting {} from archive...",
        "📦".yellow(),
        binary_name
    );

    let file = std::fs::File::open(archive_path).context("Failed to open archive file")?;
    let decoder = GzDecoder::new(file);
    let mut archive = Archive::new(decoder);

    let mut found_binary = false;

    for entry in archive
        .entries()
        .context("Failed to read archive entries")?
    {
        let mut entry = entry.context("Failed to read archive entry")?;
        let entry_path = entry.path().context("Failed to get entry path")?;

        // Check if this is our target binary
        if entry_path.file_name() == Some(std::ffi::OsStr::new(binary_name)) {
            let target_path = target_dir.join(binary_name);

            // Extract the binary
            let mut buffer = Vec::new();
            entry
                .read_to_end(&mut buffer)
                .context("Failed to read binary from archive")?;

            std::fs::write(&target_path, buffer).context("Failed to write extracted binary")?;

            // Make executable
            #[cfg(unix)]
            {
                use std::os::unix::fs::PermissionsExt;
                let mut perms = std::fs::metadata(&target_path)?.permissions();
                perms.set_mode(0o755);
                std::fs::set_permissions(&target_path, perms)?;
            }

            println!(
                "{} Extracted {} to {}",
                "✅".green(),
                binary_name,
                target_path.display()
            );
            found_binary = true;
            break;
        }
    }

    if !found_binary {
        return Err(anyhow::anyhow!(
            "Binary '{}' not found in archive",
            binary_name
        ));
    }

    Ok(())
}

async fn download_file(url: &str) -> Result<PathBuf> {
    let response = reqwest::get(url)
        .await
        .context(format!("Failed to download file from '{}'", url))?;
    if !response.status().is_success() {
        return Err(anyhow::anyhow!(
            "Failed to download file from '{}': HTTP {}",
            url,
            response.status()
        ));
    }

    // Extract filename from URL and add timestamp to ensure uniqueness
    let url_filename = url.split('/').last().unwrap_or("download");
    let timestamp = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_secs();
    let filename = format!("nockup_{}_{}", timestamp, url_filename);
    let temp_file = std::env::temp_dir().join(filename);

    let mut file = std::fs::File::create(&temp_file).context("Failed to create temporary file")?;
    let content = response.bytes().await?;
    std::io::copy(&mut content.as_ref(), &mut file).context("Failed to write to temporary file")?;
    Ok(temp_file)
}

async fn verify_checksums(
    file_path: &PathBuf,
    expected_blake3: &str,
    expected_sha1: &str,
) -> Result<()> {
    let bytes =
        std::fs::read(file_path).context("Failed to read file for checksum verification")?;

    let computed_blake3 = blake3::hash(&bytes);
    if computed_blake3.to_string() != expected_blake3 {
        return Err(anyhow::anyhow!(
            "Checksum verification failed: expected {}, got {}",
            expected_blake3,
            computed_blake3
        ));
    }

    // Get SHA1 checksum
    let mut hasher = Sha1::new();
    hasher.update(&bytes);
    let computed_sha1 = hasher.finalize();
    let expected_sha1: [u8; 20] = hex::decode(expected_sha1)
        .map_err(|e| anyhow::anyhow!("Invalid hex SHA-1: {}", e))?
        .try_into()
        .map_err(|_| anyhow!("Failed to convert to fixed array (length mismatch)"))?; // No need to format e here
    if computed_sha1.as_slice() != &expected_sha1 {
        let expected_hex = hex::encode(&expected_sha1);
        let computed_hex = hex::encode(computed_sha1.as_slice());
        return Err(anyhow::anyhow!(
            "Checksum verification failed: expected {}, got {}",
            expected_hex,
            computed_hex
        ));
    }
    Ok(())
}

async fn write_commit_details(cache_dir: &PathBuf) -> Result<()> {
    let status_file = cache_dir.join("status.toml");
    let mut config = toml::map::Map::new();
    config.insert("commit".into(), toml::Value::Table(toml::map::Map::new()));
    let commit_id = get_git_commit_id().await?;
    // error[E0277]: the `?` operator can only be used on `Result`s, not `Option`s, in an async function that returns `Result`
    let commit_table = config
        .get_mut("commit")
        .and_then(|commit| commit.as_table_mut())
        .ok_or_else(|| anyhow::anyhow!("Failed to insert commit ID into config"))?;
    commit_table.insert("id".into(), toml::Value::String(commit_id));
    fs::write(status_file, toml::to_string(&config)?).context("Failed to write config file")?;
    Ok(())
}

// load Git commit ID from HEAD of github.com/sigilante/nockchain
async fn get_git_commit_id() -> Result<String> {
    let repo_url = format!("https://api.github.com/repos/sigilante/nockchain/commits/master");
    let client = reqwest::Client::new();
    let response = client
        .get(&repo_url)
        .header("User-Agent", "nockup")
        .send()
        .await
        .context("Failed to fetch commit ID from GitHub")?;

    if !response.status().is_success() {
        return Err(anyhow::anyhow!(
            "Failed to fetch commit ID: HTTP {}",
            response.status()
        ));
    }

    let json: serde_json::Value = response.json().await.context("Invalid JSON response")?;
    let commit_id = json["sha"]
        .as_str()
        .ok_or_else(|| anyhow::anyhow!("Missing commit ID in response"))?;
    Ok(commit_id.to_string())
}
