#!/bin/bash

BINARY=$1
TARGET=$2
CHANNEL=${3:-stable}

# Get nockchain info from environment or git
NOCKCHAIN_OWNER=${NOCKCHAIN_OWNER:-sigilante}
NOCKCHAIN_REPO=${NOCKCHAIN_REPO:-nockchain}
NOCKCHAIN_COMMIT=${NOCKCHAIN_COMMIT:-$(git ls-remote https://github.com/$NOCKCHAIN_OWNER/$NOCKCHAIN_REPO.git HEAD | cut -f1)}
NOCKCHAIN_SHORT=$(echo $NOCKCHAIN_COMMIT | cut -c1-7)
DATE=$(date +%Y-%m-%d)

# Fetch the latest release info from nockchain
RELEASE_API="https://api.github.com/repos/$NOCKCHAIN_OWNER/$NOCKCHAIN_REPO/releases/latest"
RELEASE_INFO=$(curl -s "$RELEASE_API")
RELEASE_TAG=$(echo "$RELEASE_INFO" | jq -r .tag_name)

# Try to get version from the release tag, or use a default
if [ "$RELEASE_TAG" != "null" ] && [ -n "$RELEASE_TAG" ]; then
    VERSION=$(echo "$RELEASE_TAG" | sed 's/^v//')  # Remove 'v' prefix if present
else
    VERSION="0.1.0"  # Default version
fi

# Generate URL based on how nockchain releases are structured
# Adjust this based on actual nockchain release patterns
URL="https://github.com/$NOCKCHAIN_OWNER/$NOCKCHAIN_REPO/releases/download/${RELEASE_TAG}/${BINARY}-${TARGET}"

# Alternative URL patterns you might use:
# URL="https://github.com/$NOCKCHAIN_OWNER/$NOCKCHAIN_REPO/releases/download/${CHANNEL}-${NOCKCHAIN_SHORT}/${BINARY}-${TARGET}"
# URL="https://github.com/$NOCKCHAIN_OWNER/$NOCKCHAIN_REPO/releases/download/continuous/${BINARY}-${TARGET}"

# Try to fetch hash from the release assets (if checksums are published)
# This is optional - you can skip if hashes aren't available
BLAKE3_HASH="0000000000000000000000000000000000000000000000000000000000000000"  # Placeholder
SHA1_HASH="0000000000000000000000000000000000000000"  # Placeholder

# Try to download checksums if they exist
CHECKSUM_URL="https://github.com/$NOCKCHAIN_OWNER/$NOCKCHAIN_REPO/releases/download/${RELEASE_TAG}/checksums.txt"
if curl -f -s "$CHECKSUM_URL" > /tmp/checksums.txt 2>/dev/null; then
    BLAKE3_HASH=$(grep "${BINARY}-${TARGET}" /tmp/checksums.txt | grep b3sum | cut -d' ' -f1) || true
    SHA1_HASH=$(grep "${BINARY}-${TARGET}" /tmp/checksums.txt | grep sha1 | cut -d' ' -f1) || true
fi

# Create manifest directory if it doesn't exist
MANIFEST_DIR="${MANIFEST_DIR:-toolchains}"
mkdir -p "$MANIFEST_DIR"

# Generate manifest file
MANIFEST_FILE="$MANIFEST_DIR/${BINARY}-${TARGET}-${CHANNEL}.toml"

cat << EOF > "$MANIFEST_FILE"
manifest-version = "1"
date = "$DATE"
commit = "$NOCKCHAIN_COMMIT"
commit_short = "$NOCKCHAIN_SHORT"

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