#!/bin/bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install Hombrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew update
brew tap Homebrew/bundle
brew bundle
brew cleanup

# Install the rcrc config file so the real rcup command uses our rcm configuration
rcup -K rcrc
rcup

# Ruby
DEFAULT_RUBY='2.2.3'
rbenv install --skip-existing $DEFAULT_RUBY
rbenv global $DEFAULT_RUBY
rbenv rehash

# Now that we have a ruby we can install bundler
# and other global gems
gem install bundler git-up tmuxinator

source './osx'
