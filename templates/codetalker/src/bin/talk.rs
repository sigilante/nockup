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
use nockapp::utils::make_tas;
use nockapp_grpc::NockAppGrpcServer;
use nockapp_grpc::client::NockAppGrpcClient;
use nockapp_grpc::driver::{GrpcEffect, grpc_listener_driver};
use nockapp_grpc::wire_conversion::{create_grpc_wire, grpc_wire_to_nockapp};
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
    let str_atom = string_to_atom(&mut poke_slab, "hello world")?;
    let head = make_tas(&mut poke_slab, "poke-value").as_noun();
    let command_noun = T(&mut poke_slab, &[head, str_atom.as_noun()]);
    poke_slab.set_root(command_noun);

    //  The demo poke generates a %grpc effect which we want to emit.
    let effects = nockapp.poke(SystemWire.to_wire(), poke_slab).await?;
    // for effect in effects.iter() {
    //     let effect_noun = unsafe { effect.root() };
    //     println!("Effect: {:?}", effect_noun);
    //     let grpc_effect = GrpcEffect::from_noun(&effect_noun).map_err(|err| {
    //         format!("Failed to decode gRPC effect noun: {}", err)
    //     })?;
    //     // let grpc_effect = match grpc_effect {
    //     //     Ok(effect) => effect,
    //     //     Err(_) => continue,
    //     // };
    //     match grpc_effect {
    //         GrpcEffect::Poke { pid, payload } => {
    //             let grpc_wire = create_grpc_wire();
    //             let response = nockapp
    //                 .poke(grpc_wire_to_nockapp(&grpc_wire)?, payload)
    //                 .await
    //                 .map_err(|err| format!("Failed to send gRPC poke: {}", err))?;
    //             if !response {
    //                 info!("Grpc poke not acked");
    //             }
    //         }
    //         GrpcEffect::Peek { pid, typ, path } => {
    //             let jam_bytes = nockapp
    //                 .peek(pid as i32, path)
    //                 .await
    //                 .map_err(|_err| format!("Failed to perform gRPC peek: {}", _err))?;
    //             //  [%grpc-bind result=*]
    //             //  on wire /grpc/1/pid/typ
    //             let mut payload_slab: NounSlab = NounSlab::new();
    //             let res_noun = payload_slab.cue_into(Bytes::from(jam_bytes))?;
    //             let tag_noun = "grpc-bind".to_string().to_noun(&mut payload_slab);
    //             let cause = T(&mut payload_slab, &[tag_noun, res_noun]);
    //             payload_slab.set_root(cause);

    //             let grpc_wire = WireRepr::new(
    //                 "grpc",
    //                 1,
    //                 vec![AppWireTag::Direct(pid), AppWireTag::String(typ.clone())],
    //             );
    //             let _ = nockapp.poke(grpc_wire, payload_slab).await?;
    //         }
    //     }

    // }

    //  Handle response from kernel to demo poke.
    // match nockapp.poke(SystemWire.to_wire(), poke_slab).await {
    //     Ok(effect) => {
    //         let effect_noun = unsafe { effect.root() };
    //         let grpc_effect = GrpcEffect::from_noun(&effect_noun).map_err(|err| {
    //             NockAppError::OtherError(format!(
    //                 "Failed to decode gRPC effect noun: {}",
    //                 err
    //             ))
    //         });
    //         let grpc_effect = match grpc_effect {
    //             Ok(effect) => effect,
    //             Err(_) => continue,
    //         };
    //         match grpc_effect {
    //             GrpcEffect::Poke { pid, payload } => {
    //                 let grpc_wire = create_grpc_wire();
    //                 let response = nockapp
    //                     .poke(pid as i32, grpc_wire, payload)
    //                     .await
    //                     .map_err(|err| NockAppError::OtherError(err.to_string()))?;
    //                 if !response {
    //                     info!("Grpc poke not acked");
    //                 }
    //             }
    //             GrpcEffect::Peek { pid, typ, path } => {
    //                 let jam_bytes = nockapp
    //                     .peek(pid as i32, path)
    //                     .await
    //                     .map_err(|_err| NockAppError::PeekFailed)?;
    //                 //  [%grpc-bind result=*]
    //                 //  on wire /grpc/1/pid/typ
    //                 let mut payload_slab: NounSlab = NounSlab::new();
    //                 let res_noun = payload_slab.cue_into(Bytes::from(jam_bytes))?;
    //                 let tag_noun = "grpc-bind".to_string().to_noun(&mut payload_slab);
    //                 let cause = T(&mut payload_slab, &[tag_noun, res_noun]);
    //                 payload_slab.set_root(cause);

    //                 let grpc_wire = WireRepr::new(
    //                     "grpc",
    //                     1,
    //                     vec![AppWireTag::Direct(pid), AppWireTag::String(typ.clone())],
    //                 );
    //                 let _ = handle.poke(grpc_wire, payload_slab).await?;
    //             }
    //         }

    //         // // let mut results = Vec::new();
    //         // for (_i, effect) in effects.iter().enumerate() {
    //         //     let effect_noun = unsafe { effect.root() };
    //         //     println!("{:?}", effect_noun);
    //         //     // let result_noun = poke_slab
    //         //     //     .cue_into(effect_noun);
    //         //     // println!("{:?}", result_noun);
    //         //     // if let Ok(cell) = effect_noun.as_cell() {
    //         //     //     let Ok(tail_atom) = cell.tail().as_atom() else { todo!() };
    //         //     //     let Ok(tail_string) = std::str::from_utf8(tail_atom.as_ne_bytes()) else {todo!() };
    //         //     //     results.push(tail_string.trim_end_matches('\0').to_string());
    //         //     // }
    //         // }
    //         // println!("{}", results.last().unwrap_or(&String::new()));
    //     }
    //     Err(e) => {
    //         error!("Poke failed: {}", e);
    //     }
    // }

    Ok(())
}
