use std::error::Error;
use std::fs;
use std::io::{self, Write};
use std::path::PathBuf;

use clap::{Command, Parser, Subcommand};
use nockapp::kernel::boot;
use nockapp::noun::slab::NounSlab;
use nockapp::wire::{SystemWire, Wire, WireRepr};
use nockapp::{system_data_dir, CrownError, NockAppError, ToBytesExt};
use nockapp::{AtomExt, NockApp};
use nockapp_grpc::client::NockAppGrpcClient;
use nockapp_grpc::driver::grpc_listener_driver;
use nockvm::jets::cold::Nounable;
use nockvm::noun::{Atom, Cell, IndirectAtom, Noun, D, NO, SIG, T, YES};
use nockvm_macros::tas;
use tokio::fs as tokio_fs;
use tracing::{error, info};
use zkvm_jetpack::hot::produce_prover_hot_state;

// mod error;

use nockapp::driver::*;
use nockapp::kernel::boot::Cli as BootCli;
use nockapp::utils::make_tas;
use nockapp::{exit_driver, file_driver, markdown_driver, one_punch_driver};

#[derive(Subcommand, Debug, Clone)]
pub enum Commands {
    GetHeaviestBlock,
    ListNotesByPubkey,
}
impl Commands {
    fn as_wire_tag(&self) -> &'static str {
        match self {
            Commands::GetHeaviestBlock => "get-heaviest-block",
            Commands::ListNotesByPubkey => "list-notes-by-pubkey",
        }
    }
}

#[derive(Parser, Debug, Clone)]
#[command(author, version, about, long_about = None)]
struct ChainCli {
    #[command(flatten)]
    boot: BootCli,

    #[command(subcommand)]
    command: Commands,

    #[arg(long, value_name = "PATH")]
    nockchain_socket: Option<PathBuf>,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let cli = ChainCli::parse();
    boot::init_default_tracing(&cli.boot.clone());
    println!("Starting NockApp Chain with args {:?}", cli);

    let kernel = fs::read("out.jam")
        .map_err(|e| -> Box<dyn Error> { format!("Failed to read out.jam: {}", e).into() })?;

    let mut nockapp: NockApp = boot::setup(&kernel, Some(cli.boot.clone()), &[], "chain", None)
        .await
        .map_err(|e| -> Box<dyn Error> { format!("Kernel setup failed: {}", e).into() })?;

    //  Check for a Nockchain gRPC socket.  (Not all possible commands would need it.)
    if cli.nockchain_socket.is_none() {
        if cli.nockchain_socket.is_none() {
            return Err("This command requires connection to a nockchain node. Please provide --nockchain-socket".into());
        }
    }

    //  Peek the chain.  We must do this via the NockApp's
    //  +poke arm because otherwise we +peek the NockApp,
    //  not the chain.  (+peek cannot issue effects.)
    let mut poke_slab = NounSlab::new();
    let head = make_tas(&mut poke_slab, "get-heaviest-block").as_noun();
    //  Make into a Hoon /head path type.
    let peek_noun = T(&mut poke_slab, &[head, D(0x0)]);

    //  Poke the chain with the peek request.
    poke_slab.set_root(peek_noun);

    nockapp
        .add_io_driver(one_punch_driver(poke_slab, Operation::Poke))
        .await;
    nockapp
        .add_io_driver(grpc_listener_driver(format!("http://127.0.0.1:{}", "5555".to_string())))
        .await;
    nockapp
        .add_io_driver(exit_driver())
        .await;

    nockapp.run().await;

    Ok(())
}
