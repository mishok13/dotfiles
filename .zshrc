# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(
    git
    helm
    ssh-agent
    macos
    kubectl
    docker
    docker-compose
)

zstyle :omz:plugins:ssh-agent lazy yes
zstyle :omz:plugins:ssh-agent agent-forwarding on
zstyle :omz:plugins:ssh-agent identities id_rsa

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

fpath=(/usr/local/share/zsh-completions $fpath)
fpath=($fpath ~/.zsh/completion)

autoload -U colors; colors
# source /usr/local/etc/zsh-kubectl-prompt/kubectl.zsh
# RPROMPT='%{$fg[cyan]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}'

if [ -f $HOME/.profile ]; then
    . $HOME/.profile
fi

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export TERM="xterm-256color"

alias kx=kubectx
alias kg="kubectl get"
alias kns=kubens

alias tf=terraform
alias tg=terragrunt

# alias tg=terragrunt
alias dc=docker-compose
alias d=docker

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# export NVM_DIR="$HOME/.nvm"
# [ -s "/usr/local/opt/nvm/nvm.sh" ] && source "/usr/local/opt/nvm/nvm.sh"

eval "$(op completion zsh)"; compdef _op op


function dauth_acc {
    curl -s -X POST -d "grant_type=password&username=mishk500&password=$(op item get ixp54ndrrk5afvw2jlpairykcy --fields password)&scope=openid profile email groups" -u "277447:" https://d-auth-acceptance.tcloud-acc1.np.aws.kpn.org/openid/token/ | jq '("Bearer " + .access_token)' -r
}

function keepass_auth {
    op read op://KPN/Keepass/password
}

VAULT_ADDRESS_PROD=https://de-vault-production.tcloud-de-prd1.prod.aws.kpn.org/
VAULT_ADDRESS_ACC=https://de-vault-acceptance.tcloud-de-acc1.np.aws.kpn.org/
VAULT_ADDRESS_DEV=https://de-vault-tst.tcloud-de-dev1.np.aws.kpn.org/

function vault_login {
    printf "Logging into vault($1)\n" 1>&2
    case $1 in
        prod)
            export VAULT_ADDR=$VAULT_ADDRESS_PROD
            ;;
        acc)
            export VAULT_ADDR=$VAULT_ADDRESS_ACC
            ;;
        dev)
            export VAULT_ADDR=$VAULT_ADDRESS_DEV
            ;;
        *)
            echo "Unknown environment"
            ;;
    esac
    password=`op item get ixp54ndrrk5afvw2jlpairykcy --fields password`
    export VAULT_TOKEN=`vault login -token-only -address $VAULT_ADDR -method ldap username=mishk500 password=$password`
    unset password
}

function vault_prod {
    vault_login prod
}

function vault_acc {
    vault_login acc
}

function vault_dev {
    vault_login dev
}

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi

eval "$(direnv hook zsh)"

export AWS_PAGER=""

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
source /Users/andriimishkovskyi/.config/op/plugins.sh

export DOCKER_HOST=unix:///Users/andriimishkovskyi/.colima/default/docker.sock

function zipped_creds {
    env=$1
    app=$2
    zip_path=$2-$1.zip
    printf "Zipping credentials for application $app in $env\n" 1>&2
    vault_login $env
    client_id=`vault kv get -field client_id secret/conductor-external-apps/$app-credentials`
    passphrase=`openssl rand -hex 32`
    printf "Client id is ${client_id} Password is: ${passphrase}  \n"
    rm -rf client_secret.txt
    mkfifo client_secret.txt
    vault kv get -field client_secret secret/conductor-external-apps/$app-credentials >client_secret.txt&
    zip -e -FI $zip_path client_secret.txt
    rm -rf client_secret.txt
    printf "File has been written to $zip_path\n"
}

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
export FZF_DEFAULT_COMMAND='fd -t f .'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd -t d . $HOME"
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
