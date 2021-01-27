#!/bin/bash
set -e

tag=latest
if [[ "$1" != "" ]]; then
  tag="$1"
fi

# Download ubuntu 18.04
echo "INFO: Collecting tmp/ubuntu18.iso"
mkdir -p tmp/
if [[ ! -f tmp/ubuntu1804.iso ]]; then
  wget http://cdimage.ubuntu.com/releases/18.04.4/release/ubuntu-18.04.5-server-amd64.iso \
    -O tmp/ubuntu1804.iso
fi

# Build the image
echo "INFO: Building image: breqwatr/pxe:$tag"
docker build -t breqwatr/pxe:$tag .
