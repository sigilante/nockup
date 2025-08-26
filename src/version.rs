use anyhow::Result;
use colored::Colorize;
use std::path::PathBuf;
use tokio::process::Command as TokioCommand;

pub async fn show_version_info() -> Result<()> {
    // Show nockup version
    println!("nockup version {}", env!("FULL_VERSION"));

    // Get hoon version
    match get_binary_version("hoon").await {
        Ok(version) => println!("hoon   version {}", version),
        Err(_) => println!("hoon   {}", "not found".red()),
    }

    // Get hoonc version
    match get_binary_version("hoonc").await {
        Ok(version) => println!("hoonc  version {}", version),
        Err(_) => println!("hoonc  {}", "not found".red()),
    }

    // Get current channel and architecture
    // The channel is in the TOML file at ~/.nockup/config.toml
    let config = get_config()?;
    println!(
        "current channel {}",
        config["channel"].as_str().unwrap_or("stable")
    );
    println!(
        "current architecture {}",
        config["architecture"].as_str().unwrap_or("unknown")
    );

    Ok(())
}

async fn get_binary_version(binary_name: &str) -> Result<String> {
    // First check if binary exists in PATH
    if which::which(binary_name).is_err() {
        return Err(anyhow::anyhow!("{} not found in PATH", binary_name));
    }

    // Try common version flags
    let version_flags = ["--version", "-V", "-v", "version"];

    for flag in &version_flags {
        if let Ok(output) = TokioCommand::new(binary_name).arg(flag).output().await {
            if output.status.success() {
                let version_output = String::from_utf8_lossy(&output.stdout);
                let version_line = version_output.lines().next().unwrap_or("").trim();

                if !version_line.is_empty() {
                    return Ok(extract_version_string(version_line));
                }
            }
        }
    }

    Err(anyhow::anyhow!(
        "Could not determine {} version",
        binary_name
    ))
}

fn extract_version_string(version_line: &str) -> String {
    // Try to extract just the version part from output.
    let words: Vec<&str> = version_line.split_whitespace().collect();

    // Look for a word that looks like a version (starts with digit or 'v').
    for word in &words {
        if word.chars().next().map_or(false, |c| c.is_ascii_digit()) {
            return word.to_string();
        }
        if word.starts_with('v') && word.len() > 1 {
            return word[1..].to_string();
        }
    }

    // Fallback: return the whole line.
    version_line.to_string()
}

fn get_cache_dir() -> Result<PathBuf> {
    let home = dirs::home_dir().ok_or_else(|| anyhow::anyhow!("Could not find home directory"))?;
    Ok(home.join(".nockup"))
}

fn get_config() -> Result<toml::Value> {
    let cache_dir = get_cache_dir()?;
    let config_path = cache_dir.join("config.toml");
    let config_str = std::fs::read_to_string(&config_path)?;
    let config: toml::Value = toml::de::from_str(&config_str)?;
    Ok(config)
}
