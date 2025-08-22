# Nockup: the NockApp toolchain installer

*Nockup* installs the Hoon programming language and produces a basic template app for the NockApp framework.

NockApp is a general-purpose framework for building apps that run the Nock ISA.  It is particularly well-suited for use with [Nockchain](https://nockchain.org) and the Nock ZKVM.

## Installation

1. Install Nockchain and build `hoon` and `hoonc`.

    ```
    $ git clone https://github.com/zorp-corp/nockchain.git
    $ cd nockchain
    $ make install-hoonc
    $ cargo install --locked --force --path crates/hoon --bin hoon
    ```

2. Install Nockup.

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

# Start the nockup environment.
$ nockup start
🚀 Setting up nockup cache directory...
📁 Cache location: /Users/myuser/.nockup
📁 Creating cache directory structure...
✓ Created directory structure
⬇️ Downloading templates from GitHub...
Cloning into '/Users/myuser/.nockup/temp_repo'...
remote: Enumerating objects: 36, done.
remote: Counting objects: 100% (36/36), done.
remote: Compressing objects: 100% (30/30), done.
remote: Total 36 (delta 1), reused 18 (delta 0), pack-reused 0 (from 0)
Receiving objects: 100% (36/36), 45.18 KiB | 1.56 MiB/s, done.
Resolving deltas: 100% (1/1), done.
✓ Templates downloaded successfully
✅ Setup complete!
📂 Templates are now available in: /Users/myuser/.nockup/templates

# Initialize a default project.
$ cp default-manifest.toml arcadia.toml
$ nockup init arcadia 
Initializing new NockApp project 'arcadia'...
  create Cargo.toml
  create manifest.toml
  create build.rs
  create hoon/app/app.hoon
  create hoon/common/wrapper.hoon
  create hoon/lib/lib.hoon
  create README.md
  create src/main.rs
✓ New project created in ./arcadia//
To get started:
  nockup build arcadia
  nockup run arcadia

# Show project settings.
$ cd arcadia
$ ls
build.rs      Cargo.toml    manifest.toml README.md     target
Cargo.lock    hoon          out.jam       src

$ cd ..

# Build the project (wraps hoonc).
$ nockup build arcadia
🔨 Building project 'arcadia'...
    Updating crates.io index
    Updating git repository `https://github.com/zorp-corp/nockchain.git`
     Locking 486 packages to latest compatible versions
      Adding matchit v0.8.4 (available: v0.8.6)
      Adding toml v0.8.23 (available: v0.9.5)
   Compiling proc-macro2 v1.0.101
* * *
I (11:53:08) "hoonc: build succeeded, sending out write effect"
I (11:53:08) "hoonc: output written successfully to '/Users/neal/zorp/nockup/arcadia/out.jam'"
no panic!
✓ Hoon compilation completed successfully!
# Run the project (wraps hoon).
$ nockup run arcadia
🔨 Running project 'arcadia'...
    Finished `release` profile [optimized] target(s) in 0.31s
     Running `target/release/arcadia`
I (11:53:14) [no] kernel::boot: Tracy tracing is enabled
I (11:53:14) [no] kernel::boot: kernel: starting
W (11:53:15) poked: cause
I (11:53:15) Pokes awaiting implementation

✓ Run completed successfully!
```

The final product is, of course, a binary which you may run either directly or via `nockup run` (as demonstrated here).

## Uninstallation

To uninstall Nockup delete the binary and remove the installation cache:

```
$ rm -rf ~/.nockup
```

## Roadmap

* implement version index
* add self-updating support (`nockup up`)
