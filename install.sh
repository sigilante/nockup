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
RELEASE_TAG="stable-build-862c3adb0e1403ddd1a80ed9cc9dbde50aa6ea51"
VERSION="0.0.2"
CHANNEL="stable"

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

# Function to add to PATH
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
        # Default to .bashrc
        shell_rc="$HOME/.bashrc"
    fi

    local path_entry="export PATH=\"$bin_dir:\$PATH\""
    
    # Check if already in PATH
    if [[ -f "$shell_rc" ]] && grep -q "$path_entry" "$shell_rc"; then
        print_info "PATH already configured in $shell_rc"
        return 0
    fi

    # Add to shell rc file
    echo "" >> "$shell_rc"
    echo "# Added by nockup installer" >> "$shell_rc"
    echo "$path_entry" >> "$shell_rc"
    
    print_success "Added $bin_dir to PATH in $shell_rc"
    print_warning "Please run 'source $shell_rc' or restart your shell to update PATH"
}

# Function to verify binary works
verify_binary() {
    local binary_path="$1"
    
    if [[ ! -x "$binary_path" ]]; then
        print_error "Binary is not executable: $binary_path"
        return 1
    fi

    # Try to run nockup --version or --help to verify it works
    if "$binary_path" --help >/dev/null 2>&1; then
        print_success "Binary verification successful"
        return 0
    else
        print_warning "Binary verification failed, but continuing anyway"
        return 0
    fi
}

# Main installation function
main() {
    print_step "Starting Nockup installation"
    
    # Detect platform
    local target
    target=$(detect_platform)
    print_info "Detected platform: $target"

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
    print_info "The nockup binary has been added to your PATH automatically."
    print_info "You can now use 'nockup' from any directory."
    echo ""
    print_info "Next steps:"
    print_info "  1. Restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
    print_info "  2. Verify installation: nockup --help"
    print_info "  3. Explore available templates: nockup list"
    echo ""
}

# Check if we're being sourced or executed
if [[ "${BASH_SOURCE[0]:-$0}" == "${0}" ]]; then
    main "$@"
fi
