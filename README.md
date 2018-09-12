# Dotfiles

## Bootstrap

### Install stuff

```
yaourt direnv
sudo pacman -S zsh yaourt termite ctags tig
```

### Configure

- Change default shell: `chsh /bin/zsh jgrau`

### Set up rcm

```
yaourt rcm
```

### Clone the dotfiles directory

`git clone https://github.com/jgrau/dotfiles.git ~/.dotfiles`


## More things to do

### Swap ALT and CMD on a mac keyboard

```
echo options hid_apple swap_opt_cmd=1 | \
sudo tee -a /etc/modprobe.d/hid_apple.conf
```

Not sure, but this may need to update the initramfs which I think `sudo update-grub` does.

### Solarized colors

```
git clone git://github.com/alpha-omega/termite-colors-solarized.git
mkdir -p ~/.config/termite
cd termite-colors-solarized
cp solarized-dark ~/.config/termite/config
```

### asdf package manager

```
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
```

### Postgres

```
sudo pacman -S postgresql
# or
yaourt postgresql-9.6

sudo -u postgres -i
initdb --locale en_US.UTF-8 -E UTF8 -D '/var/lib/postgres/data'
```


### Docker

```
sudo pacman -S docker docker-compose docker-machine
sudo usermod -a -G docker jgrau
systemctl enable docker
systemctl start docker
```
