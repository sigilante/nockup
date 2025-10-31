#!/bin/bash

BINARY=$1
PLATFORM=$2  # linux64 or darwin64
CHANNEL=${3:-stable}

# Get nockchain info from environment or git
NOCKCHAIN_OWNER=${NOCKCHAIN_OWNER:-sigilante}
NOCKCHAIN_REPO=${NOCKCHAIN_REPO:-nockchain}
NOCKCHAIN_COMMIT=${NOCKCHAIN_COMMIT:-$(git ls-remote https://github.com/$NOCKCHAIN_OWNER/$NOCKCHAIN_REPO.git HEAD | cut -f1)}
NOCKCHAIN_SHORT=$(echo $NOCKCHAIN_COMMIT | cut -c1-7)
DATE=$(date +%Y-%m-%d)

# Map platform to Rust target triple
case "$PLATFORM" in
    linux64)
        TARGET="x86_64-unknown-linux-gnu"
        ;;
    darwin64)
        TARGET="x86_64-apple-darwin"
        ;;
    *)
        echo "Unknown platform: $PLATFORM" >&2
        exit 1
        ;;
esac

# Fetch the latest release info from nockchain to get version
# Or just hardcode it for now
VERSION="0.1.0"

# Try to get actual version from releases
RELEASE_API="https://api.github.com/repos/$NOCKCHAIN_OWNER/$NOCKCHAIN_REPO/releases"
RELEASES=$(curl -s "$RELEASE_API")
LATEST_STABLE_RELEASE=$(echo "$RELEASES" | jq -r '.[] | select(.tag_name | startswith("stable-build-")) | .tag_name' | head -1)

if [ -n "$LATEST_STABLE_RELEASE" ]; then
    # Extract version from existing release if we can find it in the asset names
    VERSION_FROM_RELEASE=$(echo "$RELEASES" | jq -r '.[] | select(.tag_name == "'$LATEST_STABLE_RELEASE'") | .assets[].name' | grep -oP '\d+\.\d+\.\d+' | head -1)
    if [ -n "$VERSION_FROM_RELEASE" ]; then
        VERSION="$VERSION_FROM_RELEASE"
    fi
fi

# Generate the release tag and URL following the exact pattern
RELEASE_TAG="${CHANNEL}-build-${NOCKCHAIN_COMMIT}"
URL="https://github.com/$NOCKCHAIN_OWNER/$NOCKCHAIN_REPO/releases/download/${RELEASE_TAG}/${BINARY}-${CHANNEL}-${VERSION}-${TARGET}.tar.gz"

# Create manifest directory if it doesn't exist
MANIFEST_DIR="${MANIFEST_DIR:-toolchains}"
mkdir -p "$MANIFEST_DIR"

# For hashes, we'd need to download the actual files or have them provided
# For now, use placeholders
BLAKE3_HASH="0000000000000000000000000000000000000000000000000000000000000000"
SHA1_HASH="0000000000000000000000000000000000000000"

# Generate manifest file
MANIFEST_FILE="$MANIFEST_DIR/${BINARY}-${TARGET}-${CHANNEL}.toml"

cat << EOF > "$MANIFEST_FILE"
manifest-version = "1"
date = "$DATE"
commit = "$NOCKCHAIN_COMMIT"
commit_short = "$NOCKCHAIN_SHORT"
release_tag = "$RELEASE_TAG"

[pkg.$BINARY]
version = "$VERSION"
components = ["core"]

[pkg.$BINARY.target.$TARGET]
available = true
url = "$URL"
hash_blake3 = "$BLAKE3_HASH"
hash_sha1 = "$SHA1_HASH"
EOF

echo "Generated manifest: $MANIFEST_FILE"
echo "URL: $URL"
