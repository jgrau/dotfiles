#!/bin/bash

sudo apt --yes install \
  zsh \
  git \
  git-crypt \
  tig \
  xclip \
  software-properties-common \
  tmux \
  direnv \
  ack-grep \
  clamav-daemon \
  golang-go \
  shellcheck \
  chromium-browser \
  apt-transport-https \
  ca-certificates \
  curl \
  automake \
  autoconf \
  libreadline-dev \
  libncurses-dev \
  libssl-dev \
  libyaml-dev \
  libxslt-dev \
  libffi-dev \
  libtool \
  unixodbc-dev \
  zlib1g-dev \
  postgresql \
  postgresql-contrib \
  libpq-dev \
  g++ \
  libgtk2.0-dev \
  libgtk-3-dev \
  gtk-doc-tools \
  gnutls-bin \
  valac \
  intltool \
  libpcre2-dev \
  libglib3.0-cil-dev \
  libgnutls28-dev \
  libgirepository1.0-dev \
  libxml2-utils \
  gperf

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
  # And make Fn use F keys by default (press fn to get media keys)
  echo options hid_apple swap_opt_cmd=1 fnmode=2 | sudo tee -a /etc/modprobe.d/hid_apple.conf
  sudo update-initramfs -u
fi

# Install shfmt
go get -u mvdan.cc/sh/cmd/shfmt

if [ ! -d "$HOME"/.asdf ]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf

  "$HOME"/.asdf/bin/asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
  "$HOME"/.asdf/bin/asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  "$HOME"/.asdf/bin/asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
  "$HOME"/.asdf/bin/asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git

  bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
fi

if [ ! -d "$HOME"/src/gaest ]; then
  mkdir -p "$HOME"/src

  git clone git@github.com:gaest/gaest.git "$HOME"/src/gaest

  # Copy env examples
  cp "$HOME"/src/gaest/api/.env.example "$HOME"/src/gaest/api/.env
fi

if ! [ -x "$(command -v docker)" ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
  sudo apt-get update
  sudo apt-get install docker-ce

  sudo groupadd docker
  sudo usermod -aG docker "$USER"
  sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
  sudo chmod g+rwx "$HOME/.docker" -R
  sudo systemctl enable docker
fi

if ! [ -x "$(command -v termite)" ]; then
  mkdir -p "$HOME"/src
  cd "$HOME"/src || exit
  git clone --recursive https://github.com/thestinger/termite.git
  git clone https://github.com/thestinger/vte-ng.git

  echo export LIBRARY_PATH="/usr/include/gtk-3.0:$LIBRARY_PATH"
  cd vte-ng && ./autogen.sh && make && sudo make install
  cd ../termite && make && sudo make install
  sudo ldconfig
  sudo mkdir -p /lib/terminfo/x
  sudo ln -s \
    /usr/local/share/terminfo/x/xterm-termite \
    /lib/terminfo/x/xterm-termite

  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/termite 60
fi

if ! [ -x "$(command -v hub)" ]; then
  mkdir -p "$GOPATH"/src/github.com/github
  git clone \
    --config transfer.fsckobjects=false \
    --config receive.fsckobjects=false \
    --config fetch.fsckobjects=false \
    https://github.com/github/hub.git "$GOPATH"/src/github.com/github/hub
  cd "$GOPATH"/src/github.com/github/hub || exit
  sudo make install prefix=/usr/local
fi

if ! [ -x "$(command -v vim)" ] || [ "$(vim --version | head -n1 | cut -d ' ' -f 5)" != "8.1" ]; then
  sudo add-apt-repository ppa:jonathonf/vim
  sudo apt update
  sudo apt install vim-gtk
fi

if ! [ -x "$(command -v redis-cli)" ]; then
  sudo apt install redis-server

  # Make systemd supervise redis (https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-redis-on-ubuntu-18-04)
  sudo sed -i "s/^supervised no/supervised systemd/" redis.conf
fi

if ! [ -x "$(command -v gcloud)" ]; then
  # Create environment variable for correct distribution
  VERSION="bionic"
  CLOUD_SDK_REPO="cloud-sdk-$VERSION"

  # Add the Cloud SDK distribution URI as a package source
  echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

  # Import the Google Cloud Platform public key
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

  # Update the package list and install the Cloud SDK
  sudo apt-get update && sudo apt-get install google-cloud-sdk

  gcloud auth configure-docker
fi

if ! [ -x "$(command -v kubectl)" ]; then
  sudo apt install kubectl
fi

if ! [ -x "$(command -v helm)" ]; then
  sudo snap install helm --classic
fi
