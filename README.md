# Dotfiles

## Usage

```
git clone https://github.com/jgrau/legacy-dotfiles.git ~/.dotfiles
sh ~/.dotfiles/bootstrap.sh
```

## Manual steps

### Gitx

* Open `GitX`
* Go to menu `GitX` -> `Enable Terminal Usage`

### Caps Lock -> CTRL

* Open `Keyboard Preferences`
* Cick `Modifier Keys...`
* Select `^ Control` as the `Caps Lock` key

### Change Shell

* `sudo vim /etc/shells`
* Add `/usr/local/bin/zsh`
* `chsh -s /usr/local/bin/zsh`

### Autolaunch launchbar

* Open `Users & Groups preferences`
* Add `LaunchBar`

### Autolaunch slate

* Open `Slate`
* In the slate menu, click `Launch slate on login`

### Launch dropbox

So the files will start to sync

### Set solarized iterm colors

* `wget http://ethanschoonover.com/solarized/files/solarized.zip`
* Unzip
* Find `iterm-solarized`
* Open `solarized-dark.iterm`

