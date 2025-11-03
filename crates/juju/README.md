# Juju

A Noun Protocol Communication (NPC) command line.  Juju allows you to communicate with NPC-compatible processes by Unix PID.

## Setup

### Generate New Key Pair

```bash
# Generate a new key pair with random entropy
nockchain-wallet keygen
```

### Importing and Exporting Keys

The wallet supports importing and exporting keys:

```bash
# Export all wallet keys to a file (default: keys.export)
nockchain-wallet export-keys

# Import keys from the exported file
nockchain-wallet import-keys --input keys.export

# Import a master public key and chain code
nockchain-wallet import-master-pubkey --key <base58-key> --chain-code <base58-chain-code>
```

The exported keys file contains all wallet keys as a `jam` file that can be imported on another instance.

Can be used for:
- Backing up your wallet
- Migrating to a new device
- Sharing public keys with other users

### Connecting to Nockchain

The wallet needs to connect to a running nockchain instance to perform operations like checking balances, broadcasting transactions, etc.

```bash
# Connect to nockchain using a Unix domain socket
nockchain-wallet --nockchain-socket ./nockchain.sock <command>
```

Note: Make sure nockchain is running and the socket path matches your nockchain configuration.



# Advanced Options


### Generate Master Private Key from Seed Phrase

```bash
nockchain-wallet gen-master-privkey --seedphrase "your seed phrase here"
```

Creates a master private key deterministically from a BIP39-style seed phrase.

### Generate Master Public Key from Private Key

```bash
nockchain-wallet gen-master-pubkey --master-privkey <private-key>
```

Derives the master public key from a master private key.

### Derive Child Key

```bash
nockchain-wallet derive-child --key-type <pub|priv> --index <0-255>
```

Derives a child public or private key at the given index from the current master key.




## Listing Notes

### List All Notes

```bash
nockchain-wallet list-notes
```

Displays all notes (UTXOs) currently managed by the wallet, sorted by assets.

### List Notes by Public Key

```bash
nockchain-wallet list-notes-by-pubkey --pubkey <public-key>
```

Shows only the notes associated with the specified public key. Useful for filtering wallet contents by address or for multisig scenarios.


## Transaction Creation

#### Components of transaction creation

1. **Seeds**: Define where funds are going and how much
2. **Inputs**: Specify which notes (UTXOs) to spend
3. **Draft**: Combine inputs into a complete transaction
4. **Sign**: Authorize the transaction with private keys
5. **Make Transaction**: Create the final transaction for broadcasting

### What is a draft?

A draft represents a transaction that is being prepared for submission to the network. It is a collection of partially assembled `seeds` and `inputs` that can be persisted to disk and later signed and submitted.

### Create a Draft

```bash
# Create a draft using simple-spend
nockchain-wallet simple-spend \
  --names "[first1 last1],[first2 last2]" \
  --recipients "[1 pk1],[2 pk2,pk3]" \
  --gifts "100,200" \
  --fee 10
```

### Make Transaction from Draft

```bash
# Sign the transaction
nockchain-wallet sign-tx --draft path/to/draft.draft

# Make and broadcast the signed transaction
nockchain-wallet send-tx --draft path/to/draft.draft
```

Note: The draft file will be saved in `./drafts/` directory with a `.draft` extension.
