# NockApp

***DEVELOPER ALPHA***

<img align="right" src="https://zorp.io/img/nockapp.png" height="150px" alt="NockApp">

NockApps are pure-functional state machines with automatic persistence and modular IO.

The NockApp framework provides two modules, Crown and Sword:
1. Crown provides a minimal Rust interface to a Nock kernel.
2. [Sword](https://github.com/zorp-corp/nockvm) is a modern Nock runtime that achieves durable execution.

<br>

## Get Started

To test compiling a Nock kernel using the `hoonc` command-line Hoon compiler, run the following commands:

```
cargo build
cd apps/hoonc
cargo run --release bootstrap/kernel.hoon ../hoon-deps
yes | mv out.jam bootstrap/hoonc.jam
cargo run --release bootstrap/kernel.hoon ../hoon-deps
```

For large builds, the rust stack might overflow. To get around this, increase the stack size by setting: `RUST_MIN_STACK=838860`.

## Building NockApps

The `nockapp` library is the primary framework for building NockApps. It provides a simple interface to a `Kernel`: a Nock core which can make state transitions with effects (via the `poke()` method) and allow inspection of its state via the `peek()` method.

For compiling Hoon to Nock, we're also including a pre-release of `hoonc`: a NockApp for the Hoon compiler. `hoonc` can compile Hoon to Nock as a batch-mode command-line process, without the need to spin up an interactive Urbit ship. It is intended both for developer workflows and for CI. `hoonc` is also our first example NockApp. More are coming!

## Logging Configuration

### Basic Usage

```bash
# Run with default settings (production mode)
cargo run

# Use minimal log format
MINIMAL_LOG_FORMAT=true cargo run
```

### TLDR

Use `MINIMAL_LOG_FORMAT=true` for compact logging format

### Minimal Log Format Features

The minimal log format (`MINIMAL_LOG_FORMAT=true`) provides:
- Single-letter colored log levels (T, D, I, W, E)
- Simplified timestamps in HH:MM:SS format
- Abbreviated module paths (e.g., 'nockapp::kernel::boot' becomes '[cr] kernel::boot')
- Special handling for slogger messages (colored by log level)

### Environment Variables

The following environment variables can be used to configure logging:

```bash
# Set log level
RUST_LOG="nockapp::kernel=trace" cargo run

# Enable minimal log format
MINIMAL_LOG_FORMAT=true cargo run

# Combine environment variables
RUST_LOG="nockapp::kernel=trace" MINIMAL_LOG_FORMAT=true cargo run
```