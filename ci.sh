#!/bin/sh

set -x
set -eu

debbox_url="$1"

sudo apt-get update
sudo apt-get install -y puavo-devscripts
sudo apt-get install -y node-webkit  wmctrl gnome-themes-extras socat netcat-openbsd libnotify-bin xvfb

# XXX: Why node-webkit does not install these?
sudo apt-get install -y libgconf2.0 libnss3

Xvfb :99 -screen 0 1024x768x24 &> /cirun/xvfb.log &

puavo-build-debian-dir -v
puavo-dch
sudo puavo-install-deps

# XXX: For some random reason ci user has no permissions to write
# /home/ci/.npmrc
# Workaround by using sudo.
sudo npm set registry http://registry.npmjs.org/

export DISPLAY=:99
puavo-debuild
puavo-deb-upload "$debbox_url" ../*.deb

