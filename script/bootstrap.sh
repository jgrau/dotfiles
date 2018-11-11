#!/bin/bash

sudo apt update
sudo apt --yes install \
  zsh \
  vim \
  git \
  tig \
  xclip \
  software-properties-common \
  tmux \
  direnv \
  golang-go \
  shellcheck \
  chromium-browser

# Change the shell to zsh
if [ "$(getent passwd "$LOGNAME" | cut -d: -f7)" != "/bin/zsh" ]; then
  chsh -s /bin/zsh jgrau
fi

if [ ! -f "$HOME"/.ssh/id_rsa ]; then
  # Create ssh keypair
  ssh-keygen -t rsa -b 4096 -C "jonas.grau@gmail.com"

  # Add to ssh-agent
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_rsa

  # Add public key to clipboard
  xclip -sel clip <~/.ssh/id_rsa.pub

  echo "Now go add you new public key to github - it has been copied to clipboard"
  read -p "Press any key to continue or CTRL+C to quit" -r
fi

if [ ! -d "$HOME"/.dotfiles ]; then
  # Clone the dotfiles
  git clone git@github.com:jgrau/dotfiles.git ~/.dotfiles

  sudo add-apt-repository ppa:martin-frost/thoughtbot-rcm
  sudo apt-get update
  sudo apt-get install rcm

  rcup
fi

if [ ! -f /etc/modprobe.d/hid_apple.conf ]; then
  # Swap ALT and CMD on apple keyboards
  read -p "Swap <SUPER> and <ALT> keys (eg. on macbook keyboard) (requires restart to take effect) [y/n]" -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo options hid_apple swap_opt_cmd=1 | sudo tee -a /etc/modprobe.d/hid_apple.conf
    sudo update-initramfs -u
  fi
fi

# Install shfmt
go get -u mvdan.cc/sh/cmd/shfmt

if [ ! -d "$HOME"/.asdf ]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf

  "$HOME"/.asdf/bin/asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
  "$HOME"/.asdf/bin/asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  "$HOME"/.asdf/bin/asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
  "$HOME"/.asdf/bin/asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
fi

if [ ! -d "$HOME"/src/gaest ]; then
  mkdir -p "$HOME"/src

  # Clone the dotfiles
  git clone git@github.com:gaest/gaest.git "$HOME"/src/gaest
fi
