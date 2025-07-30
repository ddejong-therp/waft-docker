# Waft ssh docker container

This is a Dockerfile and script to start a docker container that can be ssh'ed into, to use waft.

I need this solution to work with Waft builds, because Waft uses full path names, and a Nix FHS
environment messes with Git such that git-aggregator doesn't work, which Waft uses. So
unfortunately more minimal solution doesn't seem to be possible.

## TODO

Create a nix flake to manage docker.
