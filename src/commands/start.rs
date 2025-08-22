use anyhow::{Context, Result};
use colored::Colorize;
use std::path::PathBuf;
use tokio::fs;
use tokio::process::Command;

const GITHUB_REPO: &str = "sigilante/nockup";
const TEMPLATES_BRANCH: &str = "master"; // or whatever branch has your templates

pub async fn run() -> Result<()> {
    let cache_dir = get_cache_dir()?;
    
    println!("{} Setting up nockup cache directory...", "🚀".green());
    println!("{} Cache location: {}", "📁".blue(), cache_dir.display().to_string().cyan());
    
    // Create cache directory structure
    create_cache_structure(&cache_dir).await?;
    
    // Download or update templates
    download_templates(&cache_dir).await?;
    
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
    
    // Create main cache directory
    fs::create_dir_all(cache_dir).await
        .context("Failed to create cache directory")?;
    
    // Create bin subdirectory
    let bin_dir = cache_dir.join("bin");
    fs::create_dir_all(&bin_dir).await
        .context("Failed to create bin directory")?;
    
    // Create templates subdirectory
    let templates_dir = cache_dir.join("templates");
    fs::create_dir_all(&templates_dir).await
        .context("Failed to create templates directory")?;
    
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
    let mut entries = fs::read_dir(templates_dir).await
        .context("Failed to read templates directory")?;
    
    let mut count = 0;
    while let Some(_entry) = entries.next_entry().await? {
        count += 1;
        if count > 1 { // More than just .git directory
            return Ok(true);
        }
    }
    
    Ok(false)
}

async fn clone_templates(templates_dir: &PathBuf) -> Result<()> {
    // Remove existing directory if it exists but is empty/corrupted
    if templates_dir.exists() {
        fs::remove_dir_all(templates_dir).await
            .context("Failed to remove existing templates directory")?;
    }
    
    // Create a temporary directory for the full clone
    let temp_dir = templates_dir.parent().unwrap().join("temp_repo");
    if temp_dir.exists() {
        fs::remove_dir_all(&temp_dir).await.ok();
    }
    
    let repo_url = format!("https://github.com/{}.git", GITHUB_REPO);
    
    // Clone the full repo to temp directory
    let mut command = Command::new("git");
    command
        .arg("clone")
        .arg("--depth=1") // Shallow clone for faster download
        .arg("--branch")
        .arg(TEMPLATES_BRANCH)
        .arg(&repo_url)
        .arg(&temp_dir);
    
    let status = command.status().await
        .context("Failed to execute git clone - make sure git is installed")?;
    
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
        fs::remove_dir_all(&temp_dir).await.ok();
        return Err(anyhow::anyhow!(
            "No 'templates' directory found in the repository"
        ));
    }
    
    // Move just the templates directory to our cache location
    fs::rename(&repo_templates_dir, templates_dir).await
        .context("Failed to move templates directory from repo")?;
    
    // Clean up the temporary repo directory
    fs::remove_dir_all(&temp_dir).await
        .context("Failed to clean up temporary directory")?;
    
    println!("{} Templates downloaded successfully", "✓".green());
    Ok(())
}

async fn update_templates(templates_dir: &PathBuf) -> Result<()> {
    // For now, just re-clone to get the latest version
    // In the future, you might want to implement proper git pull logic
    clone_templates(templates_dir).await
}

// Helper function to get the templates directory path
pub fn get_templates_dir() -> Result<PathBuf> {
    let cache_dir = get_cache_dir()?;
    Ok(cache_dir.join("templates"))
}

// Helper function to check if cache is set up
pub fn is_cache_initialized() -> Result<bool> {
    let cache_dir = get_cache_dir()?;
    let templates_dir = cache_dir.join("templates");
    
    Ok(cache_dir.exists() && templates_dir.exists())
}