use clap::Parser;
use std::process;

mod cli;
mod commands;
mod version;

use cli::*;

#[tokio::main]
async fn main() {
    let cli = Cli::parse();

    let result = match cli.command {
        None => {
            // No subcommand provided - show version info
            version::show_version_info().await
        }
        Some(Commands::Install) => commands::install::run().await,
        Some(Commands::Start { name }) => commands::start::run(name).await,
        Some(Commands::Update) => commands::update::run().await,
        Some(Commands::Build { project }) => commands::build::run(project).await,
        Some(Commands::Run { project }) => commands::run::run(project).await,
        Some(Commands::Channel { action }) => commands::channel::run(action).await,
    };

    if let Err(e) = result {
        eprintln!("Error: {}", e);
        process::exit(1);
    }
}
