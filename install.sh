#!/usr/bin/env bash

# Exit immediately if a command exits with non-zero status
set -e

# Enable debug mode with TRACE=1
[[ -n "$TRACE" ]] && set -x

# Constants
CONFIG_DIR="$HOME/.config"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Detect distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/fedora-release ]]; then
        echo "fedora"
    else
        echo "unknown"
    fi
}

DISTRO=$(detect_distro)

ensure_xserver_running() {
    # Check for Xorg or X11 socket
    if [[ -n "$DISPLAY" ]] || pgrep -x "Xorg" >/dev/null || [[ -S /tmp/.X11-unix/X* ]]; then
        echo "xserver is running. continuing..."
    else
        echo "xserver not found! Dotfiles are only applicable in X sessions."
        exit 1;
    fi
}

create_dotfiles_dir() {
     #  remove dotfiles directory if it exists
    if [[ -d "$DOTFILES_DIR" ]]; then
        rm -rf $DOTFILES_DIR
    fi
    mkdir -p $DOTFILES_DIR
    cp -r $(dirname "$0") $DOTFILES_DIR
}

backup_existing_configs() {
    mkdir -p "$BACKUP_DIR"

    local configs=(
        "$HOME/.zshrc"
        "$HOME/.tmux.conf"
        "$HOME/.Xresources"
        "$HOME/.tmux"
        "$CONFIG_DIR/nvim"
        "$CONFIG_DIR/i3"
        "$CONFIG_DIR/alacritty"
        "$CONFIG_DIR/picom"
        "$CONFIG_DIR/rofi"
        "$CONFIG_DIR/scripts"
        "$CONFIG_DIR/wallpaper"
    )

    for config in "${configs[@]}"; do
        if [[ -e "$config" ]]; then
            echo "Backing up $config to $BACKUP_DIR"
            cp -r "$config" "$BACKUP_DIR/"
        fi
    done
}

# Install packages using the appropriate package manager
install_packages() {
    case "$DISTRO" in
        debian|ubuntu|pop)
            sudo apt-get update
            sudo apt-get install -y "$@"
            ;;
        fedora)
            sudo dnf install -y "$@"
            ;;
        arch|manjaro)
            sudo pacman -Sy --noconfirm "$@"
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
}

# Required Packages
# - zsh
# - tmux
# - rofi
# - picom
# - nvim
# - i3
# - alacritty
# - lm-sensors

install_tools() {
    echo "Installing required tools..."

    # Common packages
    local common_packages=(
        git curl wget tmux zsh rofi i3 i3blocks
        alacritty picom feh python3-pip python3 xclip
        xautolock
    )

    # Distro-specific packages
    case "$DISTRO" in
        debian|ubuntu|pop)
            common_packages+=(
                lm-sensors fonts-font-awesome
            )
            ;;
        fedora)
            common_packages+=(
                lm_sensors fontawesome-fonts
            )
            ;;
        arch|manjaro)
            common_packages+=(
                lm_sensors ttf-font-awesome
            )
            ;;
    esac

    install_packages "${common_packages[@]}"
    install_neovim_latest

    # Install Node.js (for neovim plugins)
    # if ! command -v node 2>&1 >/dev/null; then
    #     curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    #    install_packages nodejs
    # fi

    # Install pip packages
    pip3 install --user pynvim
}

install_neovim_latest() {
    local MIN_VERSION="0.10.0"

    # Check if neovim is already installed
    if command -v nvim 2>&1 > /dev/null; then
        local current_version=$(nvim --version | head -n1 | grep -oP 'v\d+\.\d+\.\d+')
        current_version=${current_version#v}  # Remove 'v' prefix

        echo "Current Neovim version: $current_version"

        # Compare versions
        if [ "$(printf '%s\n' "$MIN_VERSION" "$current_version" | sort -V | head -n1)" = "$MIN_VERSION" ]; then
            echo "Neovim version $current_version meets minimum requirement ($MIN_VERSION)"
            return
        else
            echo "Neovim version $current_version is older than required ($MIN_VERSION)"
        fi
    else
        echo "Neovim not found - will install latest version"
    fi

    # Get latest stable version
    local nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
    local temp_dir=$(mktemp -d)

    # Download and extract
    echo "Downloading Neovim..."
    curl -L -o "$temp_dir/nvim.tar.gz" "$nvim_url"

    rm -rf "/$HOME/.local/nvim"
    mkdir -p "$HOME/.local"
    tar xzf "$temp_dir/nvim.tar.gz" -C "$HOME/.local/"

    # Clean up
    rm -rf "$temp_dir"

    # Add to PATH if needed
    if [[ ":$PATH:" != *":$install_dir/bin:"* ]]; then
        echo "Adding Neovim to PATH in ~/.zshrc"
        echo 'export PATH="$PATH:/$HOME/.local/nvim-linux-x86_64/bin"' >> "$HOME/.zshrc"
        export PATH="$PATH:/$HOME/.local/nvim-linux-x86_64/bin"
    fi

    echo "Neovim ${nvim_version} installed successfully"
}

install_dotfiles() {
    echo "Installing dotfiles..."

    # common dotfiles
    ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
    ln -sf "$DOTFILES_DIR/.Xresources" "$HOME/.Xresources"
    ln -sf "$DOTFILES_DIR/.tmux" "$HOME/.tmux"

    # Ensure .config directory exists
    mkdir -p "$CONFIG_DIR"

    # Install config directories
    local config_dirs=("nvim" "i3" "picom" "alacritty" "rofi" "scripts" "wallpaper")
    for dir in "${config_dirs[@]}"; do
        if [[ -d "$DOTFILES_DIR/config/$dir" ]]; then
            rm -rf "$CONFIG_DIR/$dir"
            ln -sfT "$DOTFILES_DIR/config/$dir" "$CONFIG_DIR/$dir"
        fi
    done
}

post_install() {
    # Change shell to zsh if installed
    if command -v zsh >/dev/null && [[ "$SHELL" != "$(which zsh)" ]]; then
        chsh -s "$(which zsh)"
    fi

    # Install ComicShannsMono Nerd Font
    install_nerd_font
}

install_nerd_font() {
    local font_name="ComicShannsMono"
    local font_dir="$HOME/.local/share/fonts"
    local nerd_font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/$font_name.tar.xz"

   if fc-list | grep -i "$font_name" >/dev/null 2>&1; then
        echo "$font_name Nerd Font already installed"
        return 0
    fi

    echo "Installing $font_name Nerd Font..."

    mkdir -p "$font_dir"

    # Download and install the font
    if command -v curl >/dev/null; then
        curl -L -o "/tmp/${font_name}.tar.xz" "$nerd_font_url"
    elif command -v wget >/dev/null; then
        wget -O "/tmp/${font_name}.tar.xz" "$nerd_font_url"
    else
        echo "Neither curl nor wget found. Cannot download font."
        return 1
    fi

    # Extract to fonts directory
    tar -xJf "/tmp/${font_name}.tar.xz" -C "$font_dir"

    # Clean up
    rm -f "/tmp/${font_name}.tar.xz"

    # Rebuild font cache
    if command -v fc-cache >/dev/null; then
        fc-cache -fv
    fi

    echo "Successfully installed $font_name Nerd Font."
}

# Entry Point
main() {
    echo "Running on $DISTRO distribution"

    ensure_xserver_running

    create_dotfiles_dir

    backup_existing_configs
    install_tools
    install_dotfiles

    post_install

    echo "Installation complete! Existing configs were backed up to $BACKUP_DIR"
    echo "You may need to log out and back in for all changes to take effect."
}

main "$@"
