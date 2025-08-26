use anyhow::{Context, Result};
use colored::Colorize;
use std::path::Path;
use std::process::Stdio;
use tokio::process::Command;

pub async fn run(project: String) -> Result<()> {
    let project_dir = Path::new(&project);

    // Check if project directory exists
    if !project_dir.exists() {
        return Err(anyhow::anyhow!("Project directory '{}' not found", project));
    }

    // Check if it's a valid NockApp project (has manifest.toml)
    let manifest_path = project_dir.join("manifest.toml");
    if !manifest_path.exists() {
        return Err(anyhow::anyhow!(
            "Not a NockApp project: '{}' missing manifest.toml",
            project
        ));
    }

    // Check if Cargo.toml exists
    let cargo_toml = project_dir.join("Cargo.toml");
    if !cargo_toml.exists() {
        return Err(anyhow::anyhow!("No Cargo.toml found in '{}'", project));
    }

    println!("{} Building project '{}'...", "🔨".green(), project.cyan());

    // Run cargo build in the project directory
    let mut cargo_command = Command::new("cargo");
    cargo_command
        .arg("build")
        .arg("--release") // Build in release mode by default
        .current_dir(project_dir)
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit());

    let status = cargo_command
        .status()
        .await
        .context("Failed to execute cargo build")?;

    if !status.success() {
        return Err(anyhow::anyhow!(
            "Cargo build failed with exit code: {}",
            status.code().unwrap_or(-1)
        ));
    }

    println!("{} Cargo build completed successfully!", "✓".green());

    // Check if hoon app file exists
    let hoon_app_path = project_dir.join("hoon/app/app.hoon");
    if !hoon_app_path.exists() {
        return Err(anyhow::anyhow!(
            "Hoon app file not found: '{}'",
            hoon_app_path.display()
        ));
    }

    println!("{} Compiling Hoon app...", "📦".green());

    // Run hoonc command from project directory
    let mut hoonc_command = Command::new("hoonc");
    hoonc_command
        .arg("hoon/app/app.hoon")
        .current_dir(project_dir) // Run in project directory
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit());

    let hoonc_status = hoonc_command
        .status()
        .await
        .context("Failed to execute hoonc command - make sure hoonc is installed and in PATH")?;

    if !hoonc_status.success() {
        return Err(anyhow::anyhow!(
            "hoonc compilation failed with exit code: {}",
            hoonc_status.code().unwrap_or(-1)
        ));
    }

    println!("{} Hoon compilation completed successfully!", "✓".green());
    println!("{} Generated: {}", "📄".green(), "out.jam".cyan());

    Ok(())
}
