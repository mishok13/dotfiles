#!/bin/sh

set -ex

. ~/.profile

echo "Checking status of Xcode"

if xcode-select --install >/dev/null 2>&1; then
    sleep 1
    osascript <<EOD
tell application "System Events"
    tell process "Install Command Line Developer Tools"
        keystroke return
        click button "Agree" of window "License Agreement"
    end tell
end tell
EOD
else
    echo "XCode is already installed, moving on"
fi

while ! xcode-select -p >/dev/null 2>&1; do
    echo -n "\rXCode is still being installed. Have a cuppa";
    sleep 15;
done

if ! command -v brew; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

export HOMEBREW_VERBOSE=1

if ! command -v op; then
    brew install --cask 1password/tap/1password-cli 1password
fi

eval $(op signin)

echo "Settings up ssh"
mkdir -p ~/.ssh
rm -rf ~/.1password/agent.sock
mkdir -p ~/.1password && ln -s ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ~/.1password/agent.sock
echo "Host *\nIdentityAgent "~/.1password/agent.sock"" > ~/.ssh/config

echo "Checking out dotfiles"
mkdir -p ~/nonwork
if [ ! -d ~/nonwork/dotfiles/.git ]; then
  git clone git@github.com:mishok13/dotfiles.git ~/nonwork/dotfiles
fi

if ! command -v ansible; then
  brew install ansible
fi

cd ~/nonwork/dotfiles/osx/bootstrap
ansible-playbook playbook.yaml
