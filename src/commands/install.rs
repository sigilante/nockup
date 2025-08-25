use anyhow::{Context, Result};
use colored::Colorize;
use std::fs;
use std::path::PathBuf;
use std::process::Stdio;
use tokio::process::Command;

const GITHUB_REPO: &str = "sigilante/nockup";
const TEMPLATES_BRANCH: &str = "master";

pub async fn run() -> Result<()> {
    let cache_dir = get_cache_dir()?;
    
    println!("{} Setting up nockup cache directory...", "🚀".green());
    println!("{} Cache location: {}", "📁".blue(), cache_dir.display().to_string().cyan());
    
    // Create cache directory structure
    create_cache_structure(&cache_dir).await?;
    
    // Download or update templates
    download_templates(&cache_dir).await?;

    // Set default toolchain to stable and this architecture
    let cache_dir = get_cache_dir()?;
    let config_path = cache_dir.join("config.toml");
    let mut config = get_config()?;
    println!("Config path: {}", config_path.display());
    println!("Initial config: {:?}", config);
    config["toolchain"] = toml::Value::String("stable".into());
    // Get architecture of current platform.
    config["architecture"] = toml::Value::String(std::env::consts::ARCH.into());
    // Write architecture to config file
    fs::write(config_path, toml::to_string(&config)?)
        .context("Failed to write config file")?;

    println!("{} Setup complete!", "✅".green());
    println!("{} Templates are now available in: {}", 
             "📂".blue(), 
             cache_dir.join("templates").display().to_string().cyan());
    
    Ok(())
}

fn get_cache_dir() -> Result<PathBuf> {
    let home = dirs::home_dir()
        .ok_or_else(|| anyhow::anyhow!("Could not find home directory"))?;
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
        println!("{} Downloading templates from GitHub...", "⬇️".green());
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
    if !config_path.exists() {
        write_config(&config_path)?;
    }
    let config_str = std::fs::read_to_string(&config_path)
        .context("Failed to read config file")?;
    let config: toml::Value = toml::de::from_str(&config_str)
        .context("Failed to parse config file")?;
    Ok(config)
}

fn write_config(config_path: &PathBuf) -> Result<()> {
    let default_config = format!(r#"toolchain = "stable"
architecture = "{}"
"#, std::env::consts::ARCH);
    std::fs::write(config_path, default_config)
        .context("Failed to create default config file")?;
    Ok(())
}
