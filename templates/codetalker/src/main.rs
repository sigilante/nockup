use std::error::Error;
use std::fs;
use std::io::{self, Write};
use std::net::{IpAddr, Ipv4Addr, SocketAddr};

use nockapp::driver::{make_driver, IODriverFn, NockAppHandle};
use nockapp::kernel::boot;
use nockapp::noun::slab::NounSlab;
use nockapp::wire::{SystemWire, Wire, WireRepr, WireTag as AppWireTag};
use nockapp::{AtomExt, Bytes, NockApp, NockAppError, Noun};
use nockapp::{exit_driver, file_driver, markdown_driver, one_punch_driver};
use nockapp_grpc::NockAppGrpcServer;
use nockapp_grpc::client::NockAppGrpcClient;
use nockapp_grpc::driver::grpc_listener_driver;
use nockapp_grpc::wire_conversion::create_grpc_wire;
use nockvm::noun::{Atom, D, T};
use nockvm_macros::tas;
use noun_serde::{NounDecode, NounDecodeError, NounEncode};
use tracing::{error, info};

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let cli = boot::default_boot_cli(false);
    boot::init_default_tracing(&cli);

    let kernel = fs::read("out.jam")
        .map_err(|e| format!("Failed to read out.jam: {}", e))?;

    let mut nockapp: NockApp = boot::setup(
        &kernel,
        Some(cli),
        &[],
        "codetalker",
        None
    )
    .await
    .map_err(|e| format!("Kernel setup failed: {}", e))?;

    let grpc_address = "5555".to_string();
    nockapp
        .add_io_driver(grpc_listener_driver(grpc_address))
        .await;
    nockapp
        .add_io_driver(exit_driver())
        .await;
    nockapp
        .run()
        .await
        .expect("Failed to run app");

    Ok(())
}
