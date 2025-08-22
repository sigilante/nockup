use clap::Parser;
use std::process;

mod cli;
mod version;
mod commands;

use cli::*;

#[tokio::main]
async fn main() {
    let cli = Cli::parse();
    
    let result = match cli.command {
        None => {
            // No subcommand provided - show version info
            version::show_version_info().await
        }
        Some(Commands::Init { name }) => {
            commands::init::run(name).await
        }
        Some(Commands::Up) => {
            commands::up::run().await
        }
        Some(Commands::Build { project }) => {
            commands::build::run(project).await
        }
        Some(Commands::Run { project }) => {
            commands::run::run(project).await
        }
    };
    
    if let Err(e) = result {
        eprintln!("Error: {}", e);
        process::exit(1);
    }
}