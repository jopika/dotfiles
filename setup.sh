#!/bin/bash

# --- Color Definitions ---
# Define color codes for script output to improve readability.
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Script Configuration ---
# Exit immediately if a command exits with a non-zero status. This ensures that the script
# will stop if any of its commands fail.
set -e

# --- Helper Functions ---
# Function to check if a command-line tool is installed and available in the system's PATH.
# Usage: command_exists <command>
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo -e "${BLUE}Starting development environment setup...${NC}"

# --- OS and Package Manager Detection ---
# Determine the host operating system and set the appropriate package manager.
# Supports Debian/Ubuntu (apt) and macOS (brew).
case "$(uname -s)" in
  Linux)
    PACKAGE_MANAGER="apt"
    ;;
  Darwin)
    PACKAGE_MANAGER="brew"
    ;;
  *)
    echo -e "${RED}Unsupported OS: $(uname -s)${NC}"
    exit 1
    ;;
esac

echo -e "${BLUE}Using ${GREEN}$PACKAGE_MANAGER${BLUE} as the package manager.${NC}"

# --- macOS Specific Setup ---
# If on macOS, check for Homebrew and install it if it's not present.
if [ "$PACKAGE_MANAGER" = "brew" ]; then
    if ! command_exists brew; then
        echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo -e "${GREEN}Homebrew is already installed.${NC}"
    fi
fi

# --- Zsh Installation ---
# Check if Zsh is installed and, if not, install it using the detected package manager.
if ! command_exists zsh; then
    echo -e "${YELLOW}Zsh not found. Installing Zsh...${NC}"
    if [ "$PACKAGE_MANAGER" = "brew" ]; then
        brew install zsh
    elif [ "$PACKAGE_MANAGER" = "apt" ]; then
        sudo apt-get update
        sudo apt-get install -y zsh
    fi
else
    echo -e "${GREEN}Zsh is already installed.${NC}"
fi

# --- Set Zsh as Default Shell ---
# Change the default shell to Zsh if it isn't already.
# This requires the user to log out and back in for the change to take effect.
case "$SHELL" in
  *zsh*)
    echo -e "${GREEN}Zsh is already the default shell.${NC}"
    ;;
  *)
    echo -e "${BLUE}Setting Zsh as the default shell...${NC}"
    chsh -s "$(command -v zsh)"
    echo -e "${GREEN}Default shell changed to Zsh. Please log out and log back in for the change to take effect.${NC}"
    ;;
esac

# --- Oh My Zsh Installation ---
# Install the Oh My Zsh framework for managing Zsh configuration if it's not already installed.
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${YELLOW}Oh My Zsh not found. Installing Oh My Zsh...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo -e "${GREEN}Oh My Zsh is already installed.${NC}"
fi

# --- Core Tool Installations ---
echo -e "${BLUE}Checking and installing essential command-line tools...${NC}"

# --- GNU Stow Installation ---
# Stow is used for managing dotfiles by creating symlinks.
if ! command_exists stow; then
    echo -e "${YELLOW}Installing stow...${NC}"
    if [ "$PACKAGE_MANAGER" = "brew" ]; then
        brew install stow
    elif [ "$PACKAGE_MANAGER" = "apt" ]; then
        sudo apt-get update
        sudo apt-get install -y stow
    fi
else
    echo -e "${GREEN}stow is already installed.${NC}"
fi

# --- zoxide Installation ---
# zoxide is a smarter `cd` command that learns your habits.
if ! command_exists zoxide; then
    echo -e "${YELLOW}Installing zoxide...${NC}"
    if [ "$PACKAGE_MANAGER" = "brew" ]; then
        brew install zoxide
    elif [ "$PACKAGE_MANAGER" = "apt" ]; then
        sudo apt-get update
        sudo apt-get install -y zoxide
    fi
else
    echo -e "${GREEN}zoxide is already installed.${NC}"
fi

# --- fzf Installation --- 
# fzf is a command-line fuzzy finder for quickly searching and selecting files, commands, etc.
if ! command_exists fzf; then
    echo -e "${YELLOW}Installing fzf...${NC}"
    if [ "$PACKAGE_MANAGER" = "brew" ]; then
        brew install fzf
    elif [ "$PACKAGE_MANAGER" = "apt" ]; then
        sudo apt-get update
        sudo apt-get install -y fzf
    fi
else
    echo -e "${GREEN}fzf is already installed.${NC}"
fi

# --- bat Installation ---
# bat is a `cat` clone with syntax highlighting and Git integration.
if ! command_exists bat; then
    echo -e "${YELLOW}Installing bat...${NC}"
    if [ "$PACKAGE_MANAGER" = "brew" ]; then
        brew install bat
    elif [ "$PACKAGE_MANAGER" = "apt" ]; then
        sudo apt-get update
        sudo apt-get install -y bat
    fi
else
    echo -e "${GREEN}bat is already installed.${NC}"
fi

# --- nvm (Node Version Manager) Installation ---
# nvm allows you to manage multiple active Node.js versions.
if [ ! -d "$HOME/.nvm" ]; then
    echo -e "${YELLOW}Installing nvm...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
else
    echo -e "${GREEN}nvm is already installed.${NC}"
fi

# --- mise Installation ---
# mise is a fast polyglot version manager, replacing tools like nvm, rbenv, etc.
if ! command_exists mise; then
    echo -e "${YELLOW}Installing mise...${NC}"
    curl -fsSL https://mise.run | sh
    # Ensure mise is in PATH for immediate use within the script
    export PATH="$HOME/.local/bin:$PATH"
    # Activate mise for the current shell session to use it immediately.
    eval "$(~/.local/bin/mise activate zsh)"
    # Install the latest version of the usage tool for mise.
    mise use --global usage@latest
else
    echo -e "${GREEN}mise is already installed.${NC}"
fi

# --- Antigen Installation ---
# Antigen is a plugin manager for Zsh, which simplifies adding plugins and themes.
echo -e "${BLUE}Checking and installing Antigen...${NC}"
ANTIGEN_DIR="$HOME/.antigen"
if [ ! -d "$ANTIGEN_DIR" ]; then
    echo -e "${YELLOW}Antigen not found. Installing Antigen...${NC}"
    git clone https://github.com/zsh-users/antigen.git "$ANTIGEN_DIR"
else
    echo -e "${GREEN}Antigen is already installed.${NC}"
fi

# --- Dotfiles Symlinking ---
# Use Stow to create symlinks for all the dotfiles in this repository to the home directory.
# The `-t ~` flag specifies the target directory as the user's home.
echo -e "${BLUE}Invoking stow to create symlinks for dotfiles...${NC}"
stow . -t ~

echo -e "${GREEN}Setup complete! Your development environment is ready.${NC}"
