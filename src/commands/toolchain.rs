use anyhow::{Context, Result};
use std::path::{PathBuf};
use crate::cli::ToolchainAction;

fn set_toolchain(toolchain: &str) -> Result<()> {
    let mut config = get_config()?;
    config["toolchain"] = toml::Value::String(toolchain.to_string());
    let cache_dir = get_cache_dir()?;
    let config_path = cache_dir.join("config.toml");
    std::fs::write(config_path, toml::to_string(&config)?)
        .context("Failed to write config file")?;
    println!("Set default toolchain to '{}'.", toolchain);
    Ok(())
}

fn list_toolchain() -> Result<()> {
    let config = get_config()?;
    println!("Default toolchain: {}", config["toolchain"]);
    println!("Architecture: {}", config["architecture"]);
    Ok(())
}

fn get_cache_dir() -> Result<PathBuf> {
    let home = dirs::home_dir()
        .ok_or_else(|| anyhow::anyhow!("Could not find home directory"))?;
    Ok(home.join(".nockup"))
}

fn get_config() -> Result<toml::Value> {
    let cache_dir = get_cache_dir()?;
    let config_path = cache_dir.join("config.toml");
    let config_str = std::fs::read_to_string(&config_path)
        .context("Failed to read config file")?;
    let config: toml::Value = toml::de::from_str(&config_str)
        .context("Failed to parse config file")?;
    Ok(config)
}

pub async fn run(command: ToolchainAction) -> Result<()> {
    match command {
        ToolchainAction::Set { toolchain } => set_toolchain(&toolchain),
        ToolchainAction::List => list_toolchain(),
    }
}
