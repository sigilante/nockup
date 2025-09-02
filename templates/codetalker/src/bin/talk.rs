use std::error::Error;
use std::fs;
use std::io::{self, Write};
use std::net::{IpAddr, Ipv4Addr, SocketAddr};
use std::path::Path;

use nockapp::driver::{make_driver, IODriverFn, NockAppHandle, Operation};
use nockapp::kernel::boot;
use nockapp::noun::slab::NounSlab;
use nockapp::wire::{SystemWire, Wire, WireRepr, WireTag as AppWireTag};
use nockapp::{AtomExt, Bytes, NockApp, NockAppError, Noun};
use nockapp::{exit_driver, file_driver, markdown_driver};
use nockapp_grpc::NockAppGrpcServer;
use nockapp_grpc::client::NockAppGrpcClient;
use nockapp_grpc::driver::grpc_listener_driver;
use nockapp_grpc::wire_conversion::create_grpc_wire;
use nockvm::noun::{Atom, D, T};
use nockvm_macros::tas;
use noun_serde::{NounDecode, NounDecodeError, NounEncode};
use tracing::{error, info};

use codetalker::string_to_atom;

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let cli = boot::default_boot_cli(false);
    boot::init_default_tracing(&cli);

    let source_filename = Path::new(file!())
        .file_stem()
        .unwrap()
        .to_str()
        .unwrap();
    let fallback_filename = format!("{}.jam", source_filename);

    let kernel = fs::read("out.jam")
        .or_else(|_| fs::read(&fallback_filename))
        .map_err(|e| format!("Failed to read kernel file: {}", e))?;
    let mut nockapp: NockApp = boot::setup(
        &kernel,
        Some(cli),
        &[],
        source_filename,
        None
    )
    .await
    .map_err(|e| format!("Kernel setup failed: {}", e))?;

    //  Set up drivers.
    nockapp
        .add_io_driver(grpc_listener_driver(codetalker::GRPC_PORT.to_string()))
        .await;
    nockapp
        .add_io_driver(exit_driver())
        .await;

    //  Load demo poke.
    let mut poke_slab = NounSlab::new();
    // let str_atom = string_to_atom(&mut poke_slab, "hello world")?;
    // let command_noun = T(&mut poke_slab, &[D(tas!(b"command")), str_atom.as_noun()]);
    let cause_noun = T(&mut poke_slab, &[D(tas!(b"cause")), D(0x0)]);
    poke_slab.set_root(cause_noun);

    //  Handle response from kernel to demo poke.
    match nockapp.poke(SystemWire.to_wire(), poke_slab).await {
        Ok(effects) => {
            let mut results = Vec::new();
            for (_i, effect) in effects.iter().enumerate() {
                let effect_noun = unsafe { effect.root() };
                if let Ok(cell) = effect_noun.as_cell() {
                    let Ok(tail_atom) = cell.tail().as_atom() else { todo!() };
                    let Ok(tail_string) = std::str::from_utf8(tail_atom.as_ne_bytes()) else {todo!() };
                    results.push(tail_string.trim_end_matches('\0').to_string());
                }
            }
            println!("{}", results.last().unwrap_or(&String::new()));
        }
        Err(e) => {
            error!("Poke failed: {}", e);
        }
    }

    Ok(())
}
