# dotfiles
Contains the dotfiles used to manage *nix environments 

# Requirements
Make sure `git` is installed on your system.
- Git
- curl
- sudo

## MacOS
You can install a easy configuration with x-code (this may take a while)
```
xcode-select --install
```

## Debian
```
sudo apt install git
```

# How to use
- Make sure `git` is installed
- Check out this repo `git clone https://github.com/jopika/dotfiles.git`
- Navigate to the folder
- Run `sh setup.sh`, this should install and set the packages and environments as needed
- While the script should handle it, you can also run `stow` manually by invoking `stow . -t ~` in the folder