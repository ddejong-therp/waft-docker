#!/usr/bin/env bash
set -e

mkdir -p etc
rm -rf etc/*
cp -r -L /etc/gitconfig etc/gitconfig
cp -r -L /etc/xdg/nvim etc/nvim
sudo chmod -R 777 etc
docker build -t waft .
docker run --name waft-ssh -it -p 222:22 waft bash
