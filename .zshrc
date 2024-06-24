if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]] then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if [[ -f "/opt/homebrew/bin/brew" ]] then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    helm
    ssh-agent
    macos
    kubectl
    docker
    docker-compose
)

zstyle :omz:plugins:ssh-agent quiet yes
zstyle :omz:plugins:ssh-agent lazy yes
zstyle :omz:plugins:ssh-agent agent-forwarding on
zstyle :omz:plugins:ssh-agent identities id_rsa

source $ZSH/oh-my-zsh.sh

fpath=(/usr/local/share/zsh-completions $fpath)
fpath=($fpath ~/.zsh/completion)

autoload -U colors; colors

[[ ! -f ~/.profile ]] || source ~/.profile

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null || eval "$(pyenv init -)"

export TERM="xterm-256color"

alias kx=kubectx
alias kg="kubectl get"
alias kns=kubens

alias tf=terraform
alias tg=terragrunt
alias tgr="terragrunt run-all"
alias tgrp="terragrunt run-all plan"
alias tgrs="terragrunt run-all show"

alias dc="docker compose"
alias d=docker

alias l=eza
alias lt="eza --tree"

alias c=bat

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[[ ! -f ~/work/.profile ]] || source ~/work.profile

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit
fi

eval "$(direnv hook zsh)"
eval "$(zoxide init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.config/op/plugins.sh ] && source ~/.config/op/plugins.sh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

export FZF_DEFAULT_COMMAND='fd -t f --strip-cwd-prefix --ignore-file=~/.fdignore'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd -t d . $HOME"
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"



# Force pip to always use virtualenv
export PIP_REQUIRE_VIRTUALENV=true

eval "$(/usr/bin/mise activate zsh)"
