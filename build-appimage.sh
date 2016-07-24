#!/bin/bash

cd $(dirname $0)

# Build the image.
# Docker will store it for later usage. So if nothing changed since previous build, this line will take almost no time.
docker build -t krita-builder --build-arg BRANCH=rempt/update-dependencies .

# Make directories for output appimage and krita built files
mkdir -p out build

# Run the appimage build script inside container.
# This will call git pull && make each time.
# Remove the line mounting /krita_build directory if you do not want to store
# built files, i.e. to build krita from scratch every time, for example to have
# reproduceable builds on CI server.
docker run --rm \
  -v $(pwd)/out:/out \
  -v $(pwd)/build:/krita_build \
  krita-builder

