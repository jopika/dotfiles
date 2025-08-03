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

# --- nvm Installation ---
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
else
    echo "nvm is already installed."
fi


# --- Antigen Installation ---
echo "Checking and installing Antigen..."
ANTIGEN_DIR="$HOME/.antigen"
if [ ! -d "$ANTIGEN_DIR" ]; then
    echo "Antigen not found. Installing Antigen..."
    git clone https://github.com/zsh-users/antigen.git "$ANTIGEN_DIR"
else
    echo "Antigen is already installed."
fi

###### Old, Archived way to manage OMZ Plugins, keeping for posterity ######
# # --- Oh My Zsh Plugin Installations & Configuration ---
# echo "Checking and installing Oh My Zsh plugins..."

# ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# # Function to check if a plugin is already in the .zshrc plugins array
# is_plugin_enabled() {
#     local plugin_name=$1
#     local zshrc_file="$HOME/.zshrc"

#     if [ ! -f "$zshrc_file" ]; then
#         return 1 # Not enabled if file doesn't exist
#     fi

#     # Use awk to check for the plugin inside the plugins=(...) block.
#     # This handles multi-line plugin definitions.
#     awk -v plugin="$plugin_name" '
#         /^\s*plugins=\(/ { in_plugins=1 }
#         in_plugins {
#             # Check for the plugin as a whole word
#             if ($0 ~ "\\<" plugin "\\>") {
#                 found=1
#                 exit
#             }
#         }
#         # The block can end with a ) on the same line or a new line
#         /\)/ { if (in_plugins) in_plugins=0 }
#         END { if (found) exit 0; else exit 1 }
#     ' "$zshrc_file"
# }

# # Function to enable a plugin in .zshrc
# enable_plugin() {
#     local plugin_name=$1
#     local zshrc_file="$HOME/.zshrc"

#     if [ ! -f "$zshrc_file" ]; then
#         echo ".zshrc not found. Cannot enable plugin '${plugin_name}'."
#         return
#     fi

#     if ! is_plugin_enabled "$plugin_name"; then
#         echo "Enabling plugin '${plugin_name}' in .zshrc..."
#         # Use awk to add the plugin, writing to a temp file and then moving it.
#         # This is safer than `sed -i` and works with symlinks.
#         awk -v plugin="$plugin_name" '
#             { print }
#             /^\s*plugins=\(/ {
#                 print "\t" plugin
#             }
#         ' "$zshrc_file" > "${zshrc_file}.tmp" && mv "${zshrc_file}.tmp" "$zshrc_file"
#     else
#         echo "Plugin '${plugin_name}' is already enabled in .zshrc."
#     fi
# }

# # Function to install a custom plugin from GitHub
# install_custom_plugin() {
#     local plugin_name=$1
#     local repo_user=$2
#     local repo_name=${3:-$plugin_name}
#     local plugin_path="$ZSH_CUSTOM/plugins/$plugin_name"

#     if [ ! -d "$plugin_path" ]; then
#         echo "Installing plugin '${plugin_name}'..."
#         git clone "https://github.com/${repo_user}/${repo_name}.git" "$plugin_path"
#     else
#         echo "Plugin '${plugin_name}' is already installed."
#     fi
#     enable_plugin "$plugin_name"
# }

# # Bundled plugins to enable
# enable_plugin "autoenv"
# enable_plugin "brew"

# # Custom plugins to install and enable
# install_custom_plugin "zsh-autosuggestions" "zsh-users"
# install_custom_plugin "zsh-syntax-highlighting" "zsh-users"
# install_custom_plugin "you-should-use" "MichaelAquilina" "zsh-you-should-use"
# install_custom_plugin "zsh-bat" "fdellwing"
# install_custom_plugin "zsh-history-substring-search" "zsh-users"
# install_custom_plugin "zsh-nvm" "lukechilds"


# echo "Setup complete!"
