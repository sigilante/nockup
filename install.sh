#!/bin/bash

set -euo pipefail

: "${HOME:=$(getent passwd "$(whoami)" | cut -d: -f6)}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
GITHUB_REPO="sigilante/nockchain"
# RELEASE_TAG="stable-build-9e71fb71211fefe0f2dd5173d2ee83d6cbe73d85"
# VERSION="0.3.0"
VERSION="unknown"  # Default value, will be updated
RELEASE_TAG="unknown"  # Default value, will be updated
CHANNEL="stable"
CONFIG_URL="https://raw.githubusercontent.com/sigilante/nockup/refs/heads/master/default-config.toml"

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_step() {
    echo -e "${CYAN}🚀 $1${NC}"
}

# Function to get latest release for channel
get_latest_release() {
    local channel="$1"
    local api_url="https://api.github.com/repos/${GITHUB_REPO}/releases"
    
    print_step "Fetching latest ${channel} release information..."
    
    # Create temp file for releases
    local temp_releases
    temp_releases=$(create_temp_dir)/releases.json
    
    if ! download_file "$api_url" "$temp_releases"; then
        print_error "Failed to fetch release information from GitHub"
        return 1
    fi
    
    # Extract latest tag for this channel
    local latest_tag
    if command_exists grep && command_exists sed; then
        latest_tag=$(grep -o "\"tag_name\":\"${channel}-build-[^\"]*\"" "$temp_releases" | \
                    sed 's/"tag_name":"\([^"]*\)"/\1/' | head -1)
    fi
    
    if [[ -z "$latest_tag" ]]; then
        print_error "No ${channel} releases found"
        return 1
    fi
    
    # Extract version from release info if available, or parse from tag
    # Assuming your releases have a version field or you can parse from tag
    local version
    version=$(grep -B 2 "\"tag_name\":\"${latest_tag}\"" "$temp_releases" | \
              grep -o "\"name\":\"[^\"]*\"" | sed 's/"name":"\([^"]*\)"/\1/' | head -1)
    
    # If version not in name, extract from tag or default to a pattern
    if [[ -z "$version" ]]; then
        # Extract version pattern like 0.3.0 if it's in the tag
        version=$(echo "$latest_tag" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "latest")
    fi
    
    rm -f "$temp_releases"
    
    echo "$latest_tag|$version"
}

# Function to detect platform and architecture
detect_platform() {
    local arch
    local os
    local target

    # Detect architecture
    case "$(uname -m)" in
        x86_64|amd64)
            arch="x86_64"
            ;;
        arm64|aarch64)
            arch="aarch64"
            ;;
        *)
            print_error "Unsupported architecture: $(uname -m)"
            print_info "Supported architectures: x86_64, aarch64"
            exit 1
            ;;
    esac

    # Detect operating system
    case "$(uname -s)" in
        Linux)
            os="unknown-linux-gnu"
            ;;
        Darwin)
            os="apple-darwin"
            ;;
        *)
            print_error "Unsupported operating system: $(uname -s)"
            print_info "Supported operating systems: Linux, macOS"
            exit 1
            ;;
    esac

    target="${arch}-${os}"
    echo "$target"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to download file
download_file() {
    local url="$1"
    local output="$2"

    if command_exists curl; then
        curl -fsSL "$url" -o "$output"
    elif command_exists wget; then
        wget -q "$url" -O "$output"
    else
        print_error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi
}

# Function to create temporary directory
create_temp_dir() {
    local temp_dir
    if command_exists mktemp; then
        temp_dir=$(mktemp -d)
    else
        temp_dir="/tmp/nockup-install-$$"
        mkdir -p "$temp_dir"
    fi
    echo "$temp_dir"
}

# Function to setup toolchain directory with channel manifests
setup_toolchain() {
    local toolchain_dir="$HOME/.nockup/toolchains"
    
    # Create toolchain directory if it doesn't exist
    mkdir -p "$toolchain_dir"
    
    print_step "Setting up toolchain directory"
    print_info "Fetching latest channel manifests from GitHub releases"
    
    # Function to get latest manifest for a channel
    get_latest_manifest() {
        local channel="$1"
        local manifest_file="${channel}-manifest.toml"
        local output_file="${toolchain_dir}/channel-nockup-${channel}.toml"
        
        print_info "Fetching latest ${channel} manifest..."
        
        # Get latest release for this channel
        local api_url="https://api.github.com/repos/sigilante/nockchain/releases"
        local temp_releases="/tmp/releases_${channel}.json"
        
        if ! download_file "$api_url" "$temp_releases" 2>/dev/null; then
            print_warning "Failed to fetch releases from GitHub API for ${channel}"
            return 1
        fi
        
        # Extract latest tag for this channel
        local latest_tag=""
        if command_exists grep && command_exists sed; then
            latest_tag=$(grep -o "\"tag_name\":\"${channel}-build-[^\"]*\"" "$temp_releases" | \
                        sed 's/"tag_name":"\([^"]*\)"/\1/' | head -1)
        fi
        
        rm -f "$temp_releases"
        
        if [[ -z "$latest_tag" ]]; then
            print_warning "No ${channel} releases found"
            return 1
        fi
        
        local manifest_url="https://github.com/sigilante/nockchain/releases/download/${latest_tag}/${manifest_file}"
        
        print_info "Downloading from: $manifest_url"
        if download_file "$manifest_url" "$output_file" 2>/dev/null; then
            print_success "Downloaded: channel-nockup-${channel}.toml"
            return 0
        else
            print_warning "Failed to download ${channel} manifest"
            return 1
        fi
    }
    
    # Download stable and nightly manifests
    local channels=("stable" "nightly")
    local success_count=0
    
    for channel in "${channels[@]}"; do
        local output_file="${toolchain_dir}/channel-nockup-${channel}.toml"
        
        if [[ -f "$output_file" ]]; then
            print_info "Toolchain file already exists: channel-nockup-${channel}.toml"
            ((success_count++))
            continue
        fi
        
        if get_latest_manifest "$channel"; then
            ((success_count++))
        else
            # Create minimal fallback for stable channel only
            if [[ "$channel" == "stable" ]]; then
                print_info "Creating minimal channel-nockup-stable.toml fallback"
                cat > "$output_file" << EOF
# Stable channel configuration for nockup
[channel]
name = "stable"
version = "$VERSION"

[binaries]
nockup = "$VERSION"
hoon = "0.1.0"
hoonc = "0.2.0"
EOF
            fi
        fi
    done
    
    print_success "Toolchain directory setup complete"
    print_info "Toolchain files location: $toolchain_dir"
}

# Function to setup config file
setup_config() {
    local config_dir="$HOME/.nockup"
    local config_file="$config_dir/config.toml"
    
    # Create config directory if it doesn't exist
    mkdir -p "$config_dir"
    
    # Check if config file already exists
    if [[ -f "$config_file" ]]; then
        print_info "Config file already exists at: $config_file"
        return 0
    fi
    
    print_step "Downloading default config file"
    print_info "Downloading from: $CONFIG_URL"
    
    # Download the default config
    if download_file "$CONFIG_URL" "$config_file"; then
        print_success "Downloaded default config to: $config_file"
    else
        print_error "Failed to download default config file"
        
        # Create a minimal config file as fallback
        print_warning "Creating minimal fallback config file"
        cat > "$config_file" << EOF
# Nockup configuration file
[default]
channel = "$CHANNEL"
version = "$VERSION"
EOF
        print_info "Created minimal config at: $config_file"
    fi
}

# Function to add to PATH (generic version)
add_to_path() {
    local bin_dir="$1"
    local shell_rc=""

    # Determine the appropriate shell configuration file
    if [[ -n "${BASH_VERSION:-}" ]]; then
        shell_rc="$HOME/.bashrc"
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ "$SHELL" == *"zsh"* ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_rc="$HOME/.bashrc"
    else
        # Try .profile as universal fallback
        shell_rc="$HOME/.profile"
    fi

    local path_entry="export PATH=\"$bin_dir:\$PATH\""
    
    # Check if already in shell rc
    if [[ -f "$shell_rc" ]] && grep -q "$path_entry" "$shell_rc" 2>/dev/null; then
        print_info "PATH already configured in $shell_rc"
    else
        # Try to add to shell rc file
        if [[ -w "$(dirname "$shell_rc")" ]]; then
            # Create file if it doesn't exist
            touch "$shell_rc"
            
            echo "" >> "$shell_rc"
            echo "# Added by nockup installer" >> "$shell_rc"
            echo "$path_entry" >> "$shell_rc"
            
            print_success "Added $bin_dir to PATH in $shell_rc"
        else
            print_warning "Could not modify $shell_rc (permission denied)"
            print_info "Please manually add this line to your shell configuration:"
            print_info "  $path_entry"
        fi
    fi
    
    # Create activation script
    local activate_script="$HOME/.nockup/activate.sh"
    cat > "$activate_script" << EOF
#!/bin/bash
# Nockup environment activation script
# Usage: source ~/.nockup/activate.sh
export PATH="$bin_dir:\$PATH"
echo "✅ Nockup environment activated!"
echo "📦 nockup is now available in PATH"
EOF
    chmod +x "$activate_script"
    
    print_success "Created activation script: $activate_script"
}

# Function to verify binary works
verify_binary() {
    local binary_path="$1"
    
    if [[ ! -x "$binary_path" ]]; then
        print_error "Binary is not executable: $binary_path"
        return 1
    fi

    # Try to run nockup --help to verify it works
    if "$binary_path" --help >/dev/null 2>&1; then
        print_success "Binary verification successful"
        return 0
    else
        print_warning "Binary verification failed, but continuing anyway"
        return 0
    fi
}

# Function to setup GPG key (Linux only)
setup_gpg_key() {
    # Only setup GPG on Linux systems
    if [[ "$(uname -s)" != "Linux" ]]; then
        print_info "Skipping GPG setup on non-Linux system"
        return 0
    fi
    
    # Check if GPG is available
    if ! command_exists gpg; then
        print_warning "GPG not found, skipping key verification"
        print_info "For enhanced security, consider installing gnupg"
        return 0
    fi
    
    local gpg_key="A6FFD2DB7D4C9710"
    print_step "Setting up GPG key for binary verification"
    
    # Check if key is already imported
    if gpg --list-keys "$gpg_key" >/dev/null 2>&1; then
        print_info "GPG key already imported"
        return 0
    fi
    
    # Try to import the key
    if gpg --keyserver keyserver.ubuntu.com --recv-keys "$gpg_key" >/dev/null 2>&1; then
        print_success "GPG key imported successfully"
    else
        print_warning "Failed to import GPG key"
        print_info "Binary verification will be skipped"
    fi
}

# Main installation function
main() {
    print_step "Starting Nockup installation"
    print_info "This installer works on Linux and macOS systems"
    echo ""
    
    # Fetch latest release information FIRST
    local release_info
    release_info=$(get_latest_release "$CHANNEL")
    if [[ $? -ne 0 ]]; then
        print_error "Failed to fetch latest release information"
        exit 1
    fi
    
    # Parse release info and set VERSION
    RELEASE_TAG=$(echo "$release_info" | cut -d'|' -f1)
    VERSION=$(echo "$release_info" | cut -d'|' -f2)
    
    print_info "Latest ${CHANNEL} release: ${RELEASE_TAG}"
    print_info "Version: ${VERSION}"
    
    # NOW setup config file and toolchain (they can use VERSION)
    setup_config
    setup_toolchain
    
    # Setup GPG key if on Linux
    setup_gpg_key

    # Detect platform
    local target
    target=$(detect_platform)
    print_info "Target platform: $target"

    # Create temporary directory
    local temp_dir
    temp_dir=$(create_temp_dir)
    print_info "Using temporary directory: $temp_dir"

    # Cleanup function
    cleanup() {
        if [[ -n "${temp_dir:-}" ]]; then
            rm -rf "$temp_dir"
        fi
    }
    trap cleanup EXIT

    # Construct download URL
    local archive_name="nockup-${CHANNEL}-${VERSION}-${target}.tar.gz"
    local download_url="https://github.com/${GITHUB_REPO}/releases/download/${RELEASE_TAG}/${archive_name}"
    local archive_path="${temp_dir}/${archive_name}"

    print_step "Downloading Nockup binary"
    print_info "URL: $download_url"

    # Download the archive
    if ! download_file "$download_url" "$archive_path"; then
        print_error "Failed to download Nockup binary"
        print_info "Please check:"
        print_info "  - Your internet connection"
        print_info "  - The release exists at: $download_url"
        exit 1
    fi

    print_success "Downloaded Nockup archive"

    # Extract the archive
    print_step "Extracting Nockup binary"
    
    if ! tar -xzf "$archive_path" -C "$temp_dir"; then
        print_error "Failed to extract archive"
        exit 1
    fi

    # Find the nockup binary in the extracted files
    local nockup_binary
    nockup_binary=$(find "$temp_dir" -name "nockup" -type f | head -1)
    
    if [[ -z "$nockup_binary" ]]; then
        print_error "Could not find nockup binary in extracted archive"
        print_info "Archive contents:"
        ls -la "$temp_dir"
        exit 1
    fi

    print_success "Extracted Nockup binary: $nockup_binary"

    # Create installation directory
    local install_dir="$HOME/.nockup/bin"
    local nockup_path="$install_dir/nockup"
    
    print_step "Installing Nockup binary"
    mkdir -p "$install_dir"
    
    # Copy binary to installation directory
    cp "$nockup_binary" "$nockup_path"
    chmod +x "$nockup_path"
    
    print_success "Installed Nockup to: $nockup_path"

    # Verify the binary works
    verify_binary "$nockup_path"

    # Add to PATH
    add_to_path "$install_dir"

    # Set channel and run install
    print_step "Setting channel to $CHANNEL and running installation"
    if "$nockup_path" channel set "$CHANNEL" && "$nockup_path" install; then
        print_success "Nockup installation completed successfully!"
    else
        print_error "Installation failed"
        print_info "You can try running manually:"
        print_info "  $nockup_path channel set $CHANNEL"
        print_info "  $nockup_path install"
        exit 1
    fi

    # Final instructions
    echo ""
    print_success "🎉 Nockup has been successfully installed!"
    echo ""
    
    # Provide command to activate PATH immediately
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}To use nockup immediately in this terminal, run:${NC}"
    echo ""
    echo -e "  ${CYAN}export PATH=\"$install_dir:\$PATH\"${NC}"
    echo ""
    echo -e "${GREEN}Or copy and run this command:${NC}"
    echo ""
    echo -e "  ${CYAN}eval 'export PATH=\"$install_dir:\$PATH\"'${NC}"
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    print_info "Next steps:"
    print_info "  1. Run the export command above to use nockup immediately, OR"
    print_info "  2. Restart your shell to automatically load the updated PATH"
    print_info "  3. Verify installation: nockup --help"
    print_info "  4. Create a project: nockup start <project-name>"
    print_info "  5. Build and run: nockup build <project> && nockup run <project>"
    echo ""
    print_info "Installation directory: $install_dir"
    print_info "Configuration file: $HOME/.nockup/config.toml"
    print_info "Activation script: source $HOME/.nockup/activate.sh"
    echo ""
    
    # Write the export command to a temp file for easy copy
    local export_cmd_file="$HOME/.nockup/.last_install_export"
    echo "export PATH=\"$install_dir:\$PATH\"" > "$export_cmd_file"
    chmod +x "$export_cmd_file"
}

# Check if we're being sourced or executed
if [[ "${BASH_SOURCE[0]:-$0}" == "${0}" ]]; then
    main "$@"
fi