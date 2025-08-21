use nockapp::kernel::boot;
use nockapp::NockApp;
use nockapp::noun::slab::NounSlab;
use nockapp::wire::{SystemWire, Wire};
use nockapp::{AtomExt};
use nockvm::noun::{Atom, D, T};
use nockvm_macros::tas;
use std::error::Error;
use std::fs;
use bytes::Bytes;
use std::io::{self, Write};

fn string_to_atom(slab: &mut NounSlab, s: &str) -> Result<Atom, Box<dyn Error>> {
  let bytes = Bytes::from(s.as_bytes().to_vec());
  Ok(Atom::from_bytes(slab, &bytes))
}


async fn process_input(nockapp: &mut NockApp, input: &str) -> Result<String, Box<dyn Error>> {
  // Handle empty input
  if input.trim().is_empty() {
    return Ok(String::new());
  }

  let mut poke_slab = NounSlab::new();

  let str_atom = string_to_atom(&mut poke_slab, input)?;
  let command_noun = T(&mut poke_slab, &[D(tas!(b"command")), str_atom.as_noun()]);
  poke_slab.set_root(command_noun);

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
      Ok(results.last().unwrap_or(&String::new()).clone())
    }
    Err(_e) => {
      Ok("command failed".to_string())
    }
  }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
  let cli = boot::default_boot_cli(false);
  boot::init_default_tracing(&cli);
  let kernel = fs::read("jojo.jam").map_err(|e| format!("Failed to read jojo.jam: {}", e))?;

  let mut nockapp = boot::setup(&kernel, Some(cli), &[], "jojo", None).await?;

  loop {
    print!("jojo> ");
    io::stdout().flush().unwrap();
    let mut input = String::new();
    match io::stdin().read_line(&mut input) {
      Ok(0) => {
        break;
      }
      Ok(_) => {
        let input = input.trim();
        if let Ok(result) = process_input(&mut nockapp, input).await {
            println!("{}", result);
        }
      }
      Err(error) => {
        println!("Error reading input: {}", error);
        break;
      }
    }
  }
  Ok(())
}
