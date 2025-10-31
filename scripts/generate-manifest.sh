#!/bin/bash

BINARY=$1
TARGET=$2
CHANNEL=${3:-stable}
COMMIT_SHA=${GITHUB_SHA:-$(git rev-parse HEAD)}
DATE=$(date +%Y-%m-%d)

# Get version from Cargo.toml using cargo metadata
VERSION=$(cargo metadata --format-version 1 --no-deps | jq -r ".packages[] | select(.name == \"$BINARY\") | .version")

# Fallback if jq isn't available - parse Cargo.toml directly
if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
    # For workspace projects, you might need to specify the package path
    if [ -f "crates/$BINARY/Cargo.toml" ]; then
        VERSION=$(grep "^version" "crates/$BINARY/Cargo.toml" | sed 's/version = "\(.*\)"/\1/')
    elif [ -f "$BINARY/Cargo.toml" ]; then
        VERSION=$(grep "^version" "$BINARY/Cargo.toml" | sed 's/version = "\(.*\)"/\1/')
    else
        VERSION=$(grep "^version" "Cargo.toml" | head -1 | sed 's/version = "\(.*\)"/\1/')
    fi
fi

# Calculate hashes
BINARY_PATH="target/$TARGET/release/$BINARY"
if [ ! -f "$BINARY_PATH" ]; then
    echo "Error: Binary not found at $BINARY_PATH" >&2
    exit 1
fi

BLAKE3_HASH=$(b3sum "$BINARY_PATH" | cut -d' ' -f1)
SHA1_HASH=$(sha1sum "$BINARY_PATH" | cut -d' ' -f1)

# Generate URL
URL="https://github.com/sigilante/nockchain/releases/download/$CHANNEL-build-$COMMIT_SHA/$BINARY-$CHANNEL-$VERSION-$TARGET.tar.gz"

# Generate manifest
cat << EOF
manifest-version = "1"
date = "$DATE"

[pkg.$BINARY]
version = "$VERSION"
components = ["core"]

[pkg.$BINARY.target.$TARGET]
available = true
url = "$URL"
hash_blake3 = "$BLAKE3_HASH"
hash_sha1 = "$SHA1_HASH"
EOF