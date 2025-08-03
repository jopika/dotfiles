#!/bin/bash

# Color Definitions
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

echo -e "${BLUE}Starting setup...${NC}"

# Determine OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PACKAGE_MANAGER="apt"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PACKAGE_MANAGER="brew"
else
    echo -e "${RED}Unsupported OS: $OSTYPE${NC}"
    exit 1
fi

echo -e "${BLUE}Using ${GREEN}$PACKAGE_MANAGER${BLUE} as package manager.${NC}"

# macOS specific setup
if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
    if ! command_exists brew; then
        echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo -e "${GREEN}Homebrew is already installed.${NC}"
    fi
fi

# Install Zsh
if ! command_exists zsh; then
    echo -e "${YELLOW}Zsh not found. Installing Zsh...${NC}"
    if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
        brew install zsh
    elif [[ "$PACKAGE_MANAGER" == "apt" ]]; then
        sudo apt-get update
        sudo apt-get install -y zsh
    fi
else
    echo -e "${GREEN}Zsh is already installed.${NC}"
fi

# Set Zsh as the default shell
if [[ "$SHELL" != *"zsh"* ]]; then
    echo -e "${BLUE}Setting Zsh as the default shell...${NC}"
    chsh -s "$(command -v zsh)"
    echo -e "${GREEN}Default shell changed to Zsh. Please log out and log back in for the change to take effect.${NC}"
else
    echo -e "${GREEN}Zsh is already the default shell.${NC}"
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${YELLOW}Oh My Zsh not found. Installing Oh My Zsh...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo -e "${GREEN}Oh My Zsh is already installed.${NC}"
fi

# --- Tool Installations ---
echo -e "${BLUE}Checking and installing command-line tools...${NC}"

# zoxide
if ! command_exists zoxide; then
    echo -e "${YELLOW}Installing zoxide...${NC}"
    if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
        brew install zoxide
    elif [[ "$PACKAGE_MANAGER" == "apt" ]]; then
        sudo apt-get update
        sudo apt-get install -y zoxide
    fi
else
    echo -e "${GREEN}zoxide is already installed.${NC}"
fi

# fzf
if ! command_exists fzf; then
    echo -e "${YELLOW}Installing fzf...${NC}"
    if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
        brew install fzf
        # To install key bindings and fuzzy completion, but this should already be in the .zshrc
        # "$(brew --prefix)/opt/fzf/install" --all > /dev/null
    elif [[ "$PACKAGE_MANAGER" == "apt" ]]; then
        sudo apt-get update
        sudo apt-get install -y fzf
    fi
else
    echo -e "${GREEN}fzf is already installed.${NC}"
fi

# bat
if ! command_exists bat; then
    echo -e "${YELLOW}Installing bat...${NC}"
    if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
        brew install bat
    elif [[ "$PACKAGE_MANAGER" == "apt" ]]; then
        sudo apt-get update
        sudo apt-get install -y bat
    fi
else
    echo -e "${GREEN}bat is already installed.${NC}"
fi

# --- nvm Installation ---
if [ ! -d "$HOME/.nvm" ]; then
    echo -e "${YELLOW}Installing nvm...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
else
    echo -e "${GREEN}nvm is already installed.${NC}"
fi


# --- Antigen Installation ---
echo -e "${BLUE}Checking and installing Antigen...${NC}"
ANTIGEN_DIR="$HOME/.antigen"
if [ ! -d "$ANTIGEN_DIR" ]; then
    echo -e "${YELLOW}Antigen not found. Installing Antigen...${NC}"
    git clone https://github.com/zsh-users/antigen.git "$ANTIGEN_DIR"
else
    echo -e "${GREEN}Antigen is already installed.${NC}"
fi

echo -e "${GREEN}Setup complete!${NC}"

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
