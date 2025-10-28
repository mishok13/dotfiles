#!/bin/sh

set -exu -o pipefail

mkdir -p $HOME/nonwork

if type apt 2>&1 >/dev/null; then
    sudo apt update
    sudo apt install -qy git curl
fi

if type dnf 2>&1 >/dev/null; then
    sudo dnf install -qy git curl
fi

if [ ! -d "$HOME/nonwork/emacsen" ]; then
    git clone https://github.com/mishok13/emacsen $HOME/nonwork/emacsen
    git -C $HOME/nonwork/emacsen config remote.origin.url git@github.com:mishok13/emacsen.git
fi

if [ ! -d "$HOME/nonwork/dotfiles" ]; then
    git clone https://github.com/mishok13/dotfiles $HOME/nonwork/dotfiles/
    git -C $HOME/nonwork/dotfiles config remote.origin.url git@github.com:mishok13/dotfiles.git
fi

if ! type nix 2>&1 >/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

nix run home-manager/master -- switch --flake $HOME/nonwork/dotfiles/home-manager#mishok13
