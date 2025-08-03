#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

echo "Starting setup..."

# Determine OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PACKAGE_MANAGER="apt"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PACKAGE_MANAGER="brew"
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

echo "Using $PACKAGE_MANAGER as package manager."

# macOS specific setup
if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
    if ! command_exists brew; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed."
    fi
fi

# Install Zsh
if ! command_exists zsh; then
    echo "Zsh not found. Installing Zsh..."
    if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
        brew install zsh
    elif [[ "$PACKAGE_MANAGER" == "apt" ]]; then
        sudo apt-get update
        sudo apt-get install -y zsh
    fi
else
    echo "Zsh is already installed."
fi

# Set Zsh as the default shell
if [[ "$SHELL" != *"zsh"* ]]; then
    echo "Setting Zsh as the default shell..."
    chsh -s "$(command -v zsh)"
    echo "Default shell changed to Zsh. Please log out and log back in for the change to take effect."
else
    echo "Zsh is already the default shell."
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh not found. Installing Oh My Zsh..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh is already installed."
fi

# --- Tool Installations ---
echo "Checking and installing command-line tools..."

# zoxide
if ! command_exists zoxide; then
    echo "Installing zoxide..."
    if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
        brew install zoxide
    elif [[ "$PACKAGE_MANAGER" == "apt" ]]; then
        sudo apt-get update
        sudo apt-get install -y zoxide
    fi
else
    echo "zoxide is already installed."
fi

# fzf
if ! command_exists fzf; then
    echo "Installing fzf..."
    if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
        brew install fzf
        # To install key bindings and fuzzy completion, but this should already be in the .zshrc
        # "$(brew --prefix)/opt/fzf/install" --all > /dev/null
    elif [[ "$PACKAGE_MANAGER" == "apt" ]]; then
        sudo apt-get update
        sudo apt-get install -y fzf
    fi
else
    echo "fzf is already installed."
fi

# bat
if ! command_exists bat; then
    echo "Installing bat..."
    if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
        brew install bat
    elif [[ "$PACKAGE_MANAGER" == "apt" ]]; then
        sudo apt-get update
        sudo apt-get install -y bat
    fi
else
    echo "bat is already installed."
fi

# nvm
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
else
    echo "nvm is already installed."
fi


# --- Oh My Zsh Plugin Installations & Configuration ---
echo "Checking and installing Oh My Zsh plugins..."

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# Function to enable a plugin in .zshrc
enable_plugin() {
    local plugin_name=$1
    # Check if .zshrc exists and if the plugin is not already in the plugins array
    if [ -f "$HOME/.zshrc" ] && ! grep -q "^\s*plugins=([^)]*\b${plugin_name}\b[^)]*)" "$HOME/.zshrc"; then
        echo "Enabling plugin '${plugin_name}' in .zshrc..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/plugins=(/plugins=(${plugin_name} /" "$HOME/.zshrc"
        else
            sed -i "s/plugins=(/plugins=(${plugin_name} /" "$HOME/.zshrc"
        fi
    else
        if [ ! -f "$HOME/.zshrc" ]; then
            echo ".zshrc not found. Cannot enable plugin '${plugin_name}'."
        else
            echo "Plugin '${plugin_name}' is already enabled in .zshrc or not found."
        fi
    fi
}

# Function to install a custom plugin from GitHub
install_custom_plugin() {
    local plugin_name=$1
    local repo_user=$2
    local repo_name=${3:-$plugin_name}
    local plugin_path="$ZSH_CUSTOM/plugins/$plugin_name"

    if [ ! -d "$plugin_path" ]; then
        echo "Installing plugin '${plugin_name}'..."
        git clone "https://github.com/${repo_user}/${repo_name}.git" "$plugin_path"
    else
        echo "Plugin '${plugin_name}' is already installed."
    fi
    enable_plugin "$plugin_name"
}

# Bundled plugins to enable
enable_plugin "autoenv"
enable_plugin "brew"

# Custom plugins to install and enable
install_custom_plugin "zsh-autosuggestions" "zsh-users"
install_custom_plugin "zsh-syntax-highlighting" "zsh-users"
install_custom_plugin "you-should-use" "MichaelAquilina" "zsh-you-should-use"
install_custom_plugin "zsh-bat" "fdellwing"
install_custom_plugin "zsh-history-substring-search" "zsh-users"
install_custom_plugin "zsh-nvm" "lukechilds"


echo "Setup complete!"
