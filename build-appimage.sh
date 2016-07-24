#!/bin/bash

cd $(dirname $0)

docker build -t krita-builder --build-arg BRANCH=rempt/update-dependencies .
mkdir -p out build
docker run --rm -v $(pwd)/out:/out -v $(pwd)/build:/krita_build krita-builder

