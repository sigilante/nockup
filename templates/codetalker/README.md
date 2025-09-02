# codetalker

A NockApp project created with `nockup`.

## Description

Demonstration app for NockApps to communicate with each other via peeks and pokes.

## Building

To build this project:

```bash
nockup build codetalker
```

Or using cargo directly:

```bash
cargo build --release
```

## Running

To run this project:

```bash
nockup run codetalker
```

Or using cargo directly:

```bash
cargo run
```

## Project Structure

- `src/main.rs` - Main Rust entry point
- `src/lib.rs` - Core NockApp library code  
- `src/app.hoon` - Hoon application logic
- `manifest.toml` - NockApp configuration
- `build.rs` - Build script for compiling Hoon code
- `Cargo.toml` - Rust dependencies and configuration

## Development

This project uses both Rust and Hoon:

- **Rust** handles the runtime, VM integration, and system interfaces
- **Hoon** contains the core application logic that compiles to Nock
- The `build.rs` script automatically compiles Hoon to Nock during the build process

## Dependencies

- [NockApp](https://github.com/zorp-corp/nockchain) - Nock virtual machine
- Standard Rust crates for serialization and error handling

## License

This project is licensed under [LICENSE_NAME].
