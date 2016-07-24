#!/bin/bash

cd $(dirname $0)

docker build -t krita-builder --build-arg BRANCH=rempt/update-dependencies .

docker run --rm -v $(pwd)/out krita-builder

