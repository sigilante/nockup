use anyhow::{Context, Result};
use colored::Colorize;
use md5::Context as Md5Context;
use std::fs;
use std::path::PathBuf;
use std::process::Stdio;
use tokio::process::Command;

const GITHUB_REPO: &str = "sigilante/nockup";
const TEMPLATES_BRANCH: &str = "master";

pub async fn run() -> Result<()> {
    println!("TODO: Check for updates");
    println!("Should:  check binaries, sync templates");
    let cache_dir = get_cache_dir()?;
    
    println!("{} Setting up nockup cache directory...", "🚀".green());
    println!("{} Cache location: {}", "📁".blue(), cache_dir.display().to_string().cyan());
    
    // Download or update templates
    download_templates(&cache_dir).await?;

    // Set default toolchain to stable and this architecture
    let config = get_config()?;

    // Download binaries for current toolchain.
    download_binaries(&config).await?;

    println!("{} Update complete!", "✅".green());

    Ok(())
}

fn get_cache_dir() -> Result<PathBuf> {
    let home = dirs::home_dir()
        .ok_or_else(|| anyhow::anyhow!("Could not find home directory"))?;
    Ok(home.join(".nockup"))
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
            if count > 0 { // More than just .git directory
                return Ok(true);
            }
        }
    }
    
    Ok(false)
}

async fn clone_templates(templates_dir: &PathBuf) -> Result<()> {
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

    // Clean up the temporary repo directory
    fs::remove_dir_all(&temp_dir)?;
    println!("{} Templates downloaded successfully", "✓".green());
    Ok(())
}

async fn update_templates(templates_dir: &PathBuf) -> Result<()> {
    // For now, just re-clone to get the latest version
    // In the future, you might want to implement proper git pull logic
    clone_templates(templates_dir).await
}

fn get_config() -> Result<toml::Value> {
    let cache_dir = get_cache_dir()?;
    let config_path = cache_dir.join("config.toml");
    // if !config_path.exists() {
    //     write_config(&config_path)?;
    // }
    let config_str = std::fs::read_to_string(&config_path)
        .context("Failed to read config file")?;
    let config: toml::Value = toml::de::from_str(&config_str)
        .context("Failed to parse config file")?;
    Ok(config)
}

async fn download_binaries(config: &toml::Value) -> Result<()> {
    let toolchain = config["toolchain"].as_str()
        .ok_or_else(|| anyhow::anyhow!("Invalid toolchain in config"))?;
    let architecture = config["architecture"].as_str()
        .ok_or_else(|| anyhow::anyhow!("Invalid architecture in config"))?;
    
    // Load toolchain details from ./manifests/
    let channel = format!("channel-nockup-{}", toolchain);
    let manifest_path = format!("./manifests/{}.toml", channel);
    let manifest = std::fs::read_to_string(&manifest_path)
        .context(format!("Failed to read toolchain manifest for '{}'", channel))?;
    let manifest: toml::Value = toml::de::from_str(&manifest)
        .context(format!("Failed to parse toolchain manifest for '{}'", channel))?;

    println!("{} Downloading binaries for toolchain '{}' and architecture '{}'...", 
             "⬇️".green(), toolchain.cyan(), architecture.cyan());

    // Download and verify appropriate binary.
    let binary_url_hoon = manifest["pkg"]["hoon"]["target"][architecture]["url"]
        .as_str()
        .ok_or_else(|| anyhow::anyhow!("Invalid URL for hoon binary"))?;
    let binary_md5_hoon = manifest["pkg"]["hoon"]["target"][architecture]["md5"]
        .as_str()
        .ok_or_else(|| anyhow::anyhow!("Invalid MD5 for hoon binary"))?;
    println!("{} Downloading hoon binary from: {}", "⬇️".green(), binary_url_hoon.cyan());
    println!("{} Expected MD5 checksum: {}", "🔑".green(), binary_md5_hoon.cyan());
    let hoon_binary = download_file(&binary_url_hoon).await?;
    verify_checksum(&hoon_binary, &binary_md5_hoon).await?;

    // Move the downloaded binary to the appropriate location
    let target_dir = get_cache_dir()?;
    let binary_path = target_dir.join("bin");
    fs::create_dir_all(&binary_path)?;
    fs::rename(&hoon_binary, binary_path.join("hoon"))?;
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
    let temp_file = std::env::temp_dir().join("nockup_download");
    let mut file = std::fs::File::create(&temp_file)
        .context("Failed to create temporary file")?;
    let content = response.bytes().await?;
    std::io::copy(&mut content.as_ref(), &mut file)
        .context("Failed to write to temporary file")?;
    Ok(temp_file)
}

async fn verify_checksum(file_path: &PathBuf, expected_md5: &str) -> Result<()> {
    let mut file = std::fs::File::open(file_path)
        .context("Failed to open file for checksum verification")?;
    let mut context = Md5Context::new();
    std::io::copy(&mut file, &mut context)
        .context("Failed to read file for checksum verification")?;
    let result = context.compute();
    let computed_md5 = format!("{:x}", result);
    if computed_md5 != expected_md5 {
        return Err(anyhow::anyhow!(
            "Checksum verification failed: expected {}, got {}",
            expected_md5,
            computed_md5
        ));
    }
    Ok(())
}
