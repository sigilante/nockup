#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
GITHUB_REPO="sigilante/nockchain"
RELEASE_TAG="stable-build-4bb33d2a2191e61e213f3213dd151b17057be092"
VERSION="0.3.0"
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

# Function to detect platform and architecture (Replit-specific)
detect_platform() {
    local arch
    local os
    local target

    # Replit typically runs on x86_64 Linux
    case "$(uname -m)" in
        x86_64|amd64)
            arch="x86_64"
            ;;
        arm64|aarch64)
            arch="aarch64"
            ;;
        *)
            print_warning "Unsupported architecture: $(uname -m), defaulting to x86_64"
            arch="x86_64"
            ;;
    esac

    # Replit is Linux-based
    case "$(uname -s)" in
        Linux)
            os="unknown-linux-gnu"
            ;;
        *)
            print_warning "Non-Linux OS detected: $(uname -s), defaulting to Linux"
            os="unknown-linux-gnu"
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
        print_error "Neither curl nor wget found. Please install curl."
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
    local toolchain_dir="$HOME/.nockup/toolchain"
    local nockup_repo_url="https://raw.githubusercontent.com/sigilante/nockup/master/toolchain"
    
    # Create toolchain directory if it doesn't exist
    mkdir -p "$toolchain_dir"
    
    print_step "Setting up toolchain directory"
    print_info "Downloading channel manifests from: $nockup_repo_url"
    
    # Try to get directory listing from GitHub API first
    local api_url="https://api.github.com/repos/sigilante/nockup/contents/toolchain"
    local temp_listing="/tmp/toolchain_listing.json"
    
    # Attempt to get file list from GitHub API
    local toolchain_files=()
    if download_file "$api_url" "$temp_listing" 2>/dev/null; then
        # Extract .toml files from the API response
        if command_exists grep && command_exists sed; then
            readarray -t toolchain_files < <(grep '"name":' "$temp_listing" | grep '\.toml"' | sed 's/.*"name": *"\([^"]*\)".*/\1/')
        fi
        rm -f "$temp_listing"
    fi
    
    # Fallback to known files if API fails
    if [[ ${#toolchain_files[@]} -eq 0 ]]; then
        print_warning "Could not get directory listing, using fallback file list"
        toolchain_files=(
            "channel-nockup-stable.toml"
            "channel-nockup-nightly.toml"
        )
    else
        print_info "Found ${#toolchain_files[@]} toolchain files via GitHub API"
    fi
    
    # Download each toolchain file
    for file in "${toolchain_files[@]}"; do
        [[ -z "$file" ]] && continue  # Skip empty entries
        
        local file_url="${nockup_repo_url}/${file}"
        local file_path="${toolchain_dir}/${file}"
        
        if [[ -f "$file_path" ]]; then
            print_info "Toolchain file already exists: $file"
            continue
        fi
        
        print_info "Downloading toolchain file: $file"
        if download_file "$file_url" "$file_path" 2>/dev/null; then
            print_success "Downloaded: $file"
        else
            print_warning "Failed to download: $file"
            # Create minimal fallbacks for the known critical files only
            if [[ "$file" == "channel-nockup-stable.toml" ]]; then
                print_info "Creating minimal channel-nockup-stable.toml fallback"
                cat > "$file_path" << EOF
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

# Function to setup PATH for Replit (session-only)
setup_replit_path() {
    local bin_dir="$1"
    
    # Set PATH for current session
    export PATH="$bin_dir:$PATH"
    print_success "Added $bin_dir to PATH for current session"
    
    # Create activation script for manual use
    local activate_script="$HOME/.nockup/activate"
    cat > "$activate_script" << EOF
#!/bin/bash
# Nockup environment activation script for Replit
export PATH="$bin_dir:\$PATH"
echo "✅ Nockup environment activated!"
echo "📦 nockup is now available in PATH"
EOF
    chmod +x "$activate_script"
    
    print_info "Created activation script: $activate_script"
    
    # Show Replit-specific instructions
    echo ""
    print_info "📋 For persistent PATH in Replit, add this to your .replit file:"
    echo ""
    echo "[env]"
    echo "PATH = \"$bin_dir:\$PATH\""
    echo ""
    print_info "Or run this command to update your .replit file automatically:"
    echo "echo -e '\\n[env]\\nPATH = \"$bin_dir:\$PATH\"' >> .replit"
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

# Function to update .replit file automatically
update_replit_config() {
    local bin_dir="$1"
    local replit_file=".replit"
    
    # Check if .replit exists
    if [[ ! -f "$replit_file" ]]; then
        print_warning ".replit file not found in current directory"
        print_info "This might not be the root of your Replit project"
        return 1
    fi
    
    # Check if PATH is already configured
    if grep -q "PATH.*nockup" "$replit_file" 2>/dev/null; then
        print_info "PATH already configured in .replit file"
        return 0
    fi
    
    # Add [env] section if it doesn't exist
    if ! grep -q "^\[env\]" "$replit_file" 2>/dev/null; then
        echo "" >> "$replit_file"
        echo "[env]" >> "$replit_file"
    fi
    
    # Add PATH configuration
    echo "PATH = \"$bin_dir:\$PATH\"" >> "$replit_file"
    
    print_success "Updated .replit file with PATH configuration"
    print_info "nockup will be available in PATH for all future runs"
}

# Main installation function
main() {
    print_step "Starting Nockup installation for Replit"
    print_info "This installer is optimized for the Replit environment"
    echo ""
    
    # Setup config file and toolchain first
    setup_config
    setup_toolchain
    
    # Detect platform (with Replit defaults)
    local target
    target=$(detect_platform)
    print_info "Target platform: $target"

    # Create temporary directory
    local temp_dir
    temp_dir=$(create_temp_dir)
    print_info "Using temporary directory: $temp_dir"

    # Cleanup function
    cleanup() {
        rm -rf "$temp_dir"
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
        print_info "Please check your internet connection"
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

    # Setup PATH for Replit
    setup_replit_path "$install_dir"

    # Try to update .replit file automatically
    if update_replit_config "$install_dir"; then
        print_info "Automatic .replit configuration successful"
    else
        print_warning "Could not automatically update .replit file"
        print_info "You may need to add PATH configuration manually"
    fi

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
    print_success "🎉 Nockup has been successfully installed for Replit!"
    echo ""
    print_info "✅ nockup is available in your current session"
    print_info "✅ PATH has been configured for future Replit runs"
    echo ""
    print_info "🚀 Next steps:"
    print_info "  1. Verify installation: nockup --help"
    print_info "  2. Create a project: cp example-manifest.toml my-project.toml"
    print_info "  3. Initialize project: nockup start my-project.toml"
    print_info "  4. Build and run: nockup build my-project && nockup run my-project"
    echo ""
    print_info "📁 Installation directory: $install_dir"
    print_info "📄 Configuration file: $HOME/.nockup/config.toml"
    print_info "🔧 Activation script: $HOME/.nockup/activate"
}

# Check if we're being sourced or executed
if [[ "${BASH_SOURCE[0]:-$0}" == "${0}" ]]; then
    main "$@"
fi
