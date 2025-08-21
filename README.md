# Nockup: the NockApp toolchain installer

*Nockup* installs the Hoon programming language and produces a basic template app for the NockApp framework.

NockApp is a general-purpose framework for building apps that run the Nock ISA.  It is particularly well-suited for use with [Nockchain](https://nockchain.org) and the Nock ZKVM.

## Installation

```
$ git clone https://github.com/sigilante/nockup.git
$ cd nockup/
$ cargo build
```

## Usage

```
# Show basic program information.
$ nockup
nockup version 0.0.1
hoon   version 0.1.0
hoonc  version 0.2.0

# Initialize a default project.
$ cp default-manifest.toml arcadia.toml
$ nockup init arcadia
New project created in ./et-in-arcadia-ego

# Check for updates to nockup, hoon, and hoonc.
$ nockup up
Checking for updates ... no new updates.

# Show project settings.
$ cd arcadia
$ ls
build.rs
Cargo.toml
manifest.toml
README.md
src/lib.rs
src/main.rs

$ cd ..

# Build the project (wraps hoonc).
$ nockup build arcadia

# Run the project (wraps hoon).
$ nockup run arcadia
```

## Roadmap

* implement version index
* finish template project
* add build support
* add run support
* add self-updating support
