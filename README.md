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

# Check for updates to nockup, hoon, and hoonc.
$ nockup up
Checking for updates ... no new updates.

# Initialize a default project.
$ cp default-manifest.toml arcadia.toml
$ nockup init arcadia 
Initializing new NockApp project 'et-in-arcadia-ego'...
  create Cargo.toml
  create manifest.toml
  create build.rs
  create hoon/app/app.hoon
  create hoon/lib/lib.hoon
  create README.md
  create src/lib.rs
  create src/main.rs
✓ New project created in ./et-in-arcadia-ego//
To get started:
  cd et-in-arcadia-ego
  nockup build
  nockup run

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

The final product is, of course, a binary which you may run directly or via `nockup run`.

## Roadmap

* implement version index
* finish template project
* add run support
* add self-updating support
