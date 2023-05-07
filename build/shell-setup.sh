#!/bin/bash

# Change default shell to zsh
chsh -s $(which zsh)

# Install ohmyzsh
# https://github.com/ohmyzsh/ohmyzsh
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install starship
# https://github.com/starship/starship
wget https://starship.rs/install.sh
sh install.sh -y
rm install.sh
