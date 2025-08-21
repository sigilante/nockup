use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "nockup")]
#[command(about = "A developer support framework for NockApp development")]
#[command(version = env!("FULL_VERSION"))]
pub struct Cli {
    #[command(subcommand)]
    pub command: Option<Commands>,
}

#[derive(Subcommand)]
pub enum Commands {
    /// Initialize a new NockApp project (uses project_name from default-manifest.toml)
    Init {
        /// Project name (ignored - uses default-manifest.toml)
        #[arg(help = "Project name (ignored - uses default-manifest.toml)")]
        name: Option<String>,
    },
    /// Check for updates to nockup, hoon, and hoonc
    Up,
    /// Build a NockApp project
    Build {
        /// Path to the project directory
        project: String,
    },
    /// Run a NockApp project
    Run {
        /// Path to the project directory  
        project: String,
    },
}