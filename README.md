# Nockup: the NockApp channel installer

*Nockup* installs the Hoon programming language and produces a basic template app for the NockApp framework.

NockApp is a general-purpose framework for building apps that run the Nock ISA.  It is particularly well-suited for use with [Nockchain](https://nockchain.org) and the Nock ZKVM.

![](https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/RCA_Indian_Head_Test_Pattern.svg/2560px-RCA_Indian_Head_Test_Pattern.svg.png)

## Usage

Nockup supports the following `nockup` commands.

### Management

- `install`:  Initialize Nockup cache and download templates.
- `update`:  Check for updates to `nockup`, `hoon`, and `hoonc`.
- `help`:  Print this message or the help of the given subcommand(s).

### Project

- `init`:  Initialize a new NockApp project from a .toml config file.
- `build`:  Build a NockApp project.
- `run`:  Run a NockApp project.

### channel

- `channel list`: List all available channels.
- `channel set`: Set the active channel, from `stable` and `nightly`.  (Most users will prefer `stable`.)

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
    $ cargo build --release
    ```

    `nockup` builds by default in `./target/release`, so further commands to `nockup` refer to it in whatever location you have it.  `nockup install` will provide it in your `$PATH`.

    Alternatively, you may install it globally using Cargo:

    ```
    $ cargo install --path .
    ```

3. Install the GPG public key (on Linux).  Nockup **will not work** if you do not provide the public key.

    ```
    $ gpg --keyserver keyserver.ubuntu.com --recv-keys A6FFD2DB7D4C9710
    ```

4. Install `nockup` and dependencies.

    ```
    nockup install
    ```

5. Check for updates.

    ```
    $ nockup update
    ```

6. Before building, switch your `rustup` to `nightly` to satisfy `nockapp`/`nockvm` dependencies.

    ```
    rustup install nightly
    rustup override set nightly
    ```

## Usage

```
# Show basic program information.
$ nockup
nockup version 0.0.1
hoon   version 0.1.0
hoonc  version 0.2.0
current channel stable
current architecture aarch64

# Start the nockup environment.
$ nockup install
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

### Project Manifests and Templates

A project manifest is a TOML file containing sufficient information to produce a basic NockApp from a template with specified imports.

```toml
[project]
name = "Et In Arcadia Ego"
project_name = "arcadia"
version = "1.0.0"
description = "I too was in Arcadia."
author_name = "Nicolas Poussin"
author_email = "nicolas@poussin.edu"
github_username = "arcadia"
license = "MIT"
keywords = ["nockapp", "nockchain", "hoon"]
nockapp_commit_hash = "336f744b6b83448ec2b86473a3dec29b15858999"
template = "basic"
```

One of the design goals of Nockup is to avoid the need to write much, if any, Rust code to successfully deploy a NockApp.  To that end, we provide templates which by and large only expect the developer to write in Hoon or another language which targets the Nock ISA.

A project is specified by its manifest file, which includes details like the project name and the template to use.  Many projects will prefer the `basic` template, but other options are available in `/templates`.

- `basic`:  simplest NockApp template.
- `grpc`:  gRPC listener and broadcaster.
- `http-static`:  static HTTP file server.
- `http-server`:  stateful HTTP server.
- `repl`:  read-eval-print loop.
- `chain`:  Nockchain listener.
- `rollup`:  rollup bundler for NockApps to Nockchain.

### Libraries

A project manifest may optionally include a `[libraries]` section.  Conventionally, Hoon libraries are manually supplied within a desk or repository by manually copying them in.  While this solves the linked library problem by using shared nouns ([~rovnys-ricfer & ~wicdev-wisryt 2024](https://urbitsystems.tech/article/v01-i01/a-solution-to-static-vs-dynamic-linking)), no universal versioning system exists and cross-repository dependencies are difficult to automate.

A Hoon library repo should supply a `/desk` or `/hoon` directory at the top level (unless more complexity is necessary, in which case Nockup will attempt to match the proper directory).

Sequent is a good example of the simplest possible structure:

- [`jackfoxy/sequent`](https://github.com/jackfoxy/sequent) list functions

This is imported via the `configuration.toml` manifest:

```toml
[libraries]
sequent = {
    url = "https://github.com/jackfoxy/sequent",
    commit = "0f6e6777482447d4464948896b763c080dc9e559"
}
```

which supplies `/desk/lib/sequent.hoon` at `/hoon/lib/sequent.hoon` and ignores `/mar` and `/tests` (which are both Urbit-specific affordances).

A more complex structure features top-level nesting before `/desk`, such as with the Urbit numerical computing suite.

- [`urbit/numerics`](https://github.com/urbit/numerics)

```toml
[libraries]
math = {
    url = "https://github.com/urbit/numerics",
    branch = "main",
    directory = "libmath"
    commit = "7c11c48ab3f21135caa5a4e8744a9c3f828f2607"
}
lagoon = {
    url = "https://github.com/urbit/numerics",
    branch = "main",
    directory = "lagoon"
    commit = "7c11c48ab3f21135caa5a4e8744a9c3f828f2607"
}
```

which supplies `/libmath/desk/lib/math.hoon` at `/hoon/lib/libmath/lib/math.hoon` and other files along the same pattern.  (`/sur` files are also included.)

#### Multiple Targets

A Rust project (and _a fortiori_ a NockApp project) can produce more than one binary target.  This is scenario is demonstrated by the `grpc` template.

The default expectation for a single-binary project is to supply the following two files:

1. `src/main.rs` - the main Rust driver.
2. `hoon/app/app.hoon` - the Hoon kernel.

However, if you want to produce multiple binaries and kernels, you should supply the programs in this pattern:

1. `src/main1.rs` - the first Rust driver.  (This may have any name.)
2. `src/main2.rs` - the second Rust driver.  (This may have any name.)
3. `hoon/app/main1.hoon` - the first Hoon kernel.  (This should have the same name as the Rust driver `main1.rs`.)
4. `hoon/app/main2.hoon` - the second Hoon kernel.  (This should have the same name as the Rust driver `main2.rs`.)

In the `Cargo.toml` file, include both targets explicitly:

```
[[bin]]
name = "main1"
path = "src/bin/main1.rs"

[[bin]]
name = "main2"
path = "src/bin/main2.rs"
```

Nockup is opinionated here, and will match `hoon/app/main1.hoon`, etc., as kernels; that is,

```
nockup build myproject
```

will produce both `target/release/main1` and `target/release/main2`.

Projects which produce more than one binary cannot be used directly with `nockup run` since more than one process must be started.  This should be kept in mind when using templates which produce more than one binary (like `grpc`).

#### Nockchain Interactions

A Nockchain must be running locally in order to obtain chain state data.

For instance, with a NockApp based on the template `chain`, you need to connect to a running NockApp instance at port 5555:

```
nockup run chain -- --nockchain-socket=5555 get-heaviest-block
# - or -
./chain/target/release/chain --nockchain-socket=5555 get-heaviest-block
```

### Channels

Nockup can use `stable` build of `hoon` and `hoonc`.  As of this release, there is not yet a `nightly` build, but we demonstrate its support here:

```
$ ./target/debug/nockup channel list
Default channel: "stable"
Architecture: "aarch64"

$ ./target/debug/nockup channel set nightly
Set default channel to 'nightly'.

$ ./target/debug/nockup channel list
Default channel: "nightly"
Architecture: "aarch64"
```

## Uninstallation

To uninstall Nockup delete the binary and remove the installation cache:

```
$ rm -rf ~/.nockup
```

## Security

*Rustup is entirely experimental and many parts are unaudited.  We make no representations or guarantees as to the behavior of this software.*

Nockup uses HTTPS for binary downloads (overriding HTTP in the channel manifests).  The commands `nockup install` and  `nockup update` have the following security measures in place:

1. Check the Blake3 and SHA-1 checksums of the downloaded binaries against the expected index.

    You can do this manually by running:

    ```
    b3sum nockup
    sha1sum --check <file>
    ```

    and compare the answers to the expected values from the appropriate toolchain file in `~/.nockup/toolchain`.

2. Check that the binaries are appropriately signed.  Binaries are signed using the [`zorp-gpg-key`](./zorp-gpg-key.pub) for Linux and a digital certificate for Apple.

    You can do this manually by running:

    ```
    gpg --verify nockup.asc nockup
    ```

    using the `asc` signature listed in the appropriate toolchain file in `~/.nockup/toolchain`.

Code building is a general-purpose computing process, like `eval`.  You should not do it on the same machine on which you store your wallet private keys [0].

- [0]: https://semgrep.dev/blog/2025/security-alert-nx-compromised-to-steal-wallets-and-credentials/

## Roadmap

### Release Checklist

* add Apple code signing support
* update manifest files (and install/update strings) to `zorp-corp/nockchain`
* unify batch/continuous kernels via `exit` event:  `[%exit code=@]`
* replit instance with release?

### Later

* `nockup test`
* expand repertoire of templates
  * appropriate Hoon libraries
* `nockup publish`/`nockup clone` (awaiting PKI)

## Contributor's Guide

Some CLI testing has been implemented and is accessible via `cargo test`.  This can, of course, always be improved.
