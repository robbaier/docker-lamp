# Path to your oh-my-zsh installation.
export ZSH="~/.oh-my-zsh"

ZSH_THEME="daivasmara"

plugins=(git node npm nvm ansible drush wp-cli yarn bundler macos gulp ruby python)

source $ZSH/oh-my-zsh.sh

if [ -f ~/.zsh_aliases ]; then
. ~/.zsh_aliases
fi

export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

# Enable starship
eval "$(starship init zsh)"

eval "$(direnv hook zsh)"
