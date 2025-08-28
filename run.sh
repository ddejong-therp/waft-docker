#!/usr/bin/env bash
set -e

mkdir -p etc
rm -rf etc/*
cp -r -L /etc/gitconfig etc/gitconfig
cp -r -L /etc/xdg/nvim etc/nvim
docker build -t waft .
echo y | docker container prune
docker run --name waft-ssh -it -p 2222:22 waft bash
#docker create --name waft-container -p 2222:22 waft-container bash || true
#docker start waft-container
#echo "Container is started. Get into it by using: \`ssh -A -p 2222 waft@localhost\`."
#docker attach waft-container
