#!/usr/bin/env bash
docker build -t waft .
docker run --name waft-ssh -it -p 22:22 waft bash
