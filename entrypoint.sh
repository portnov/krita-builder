#!/bin/bash

cd /krita
git pull

cd packaging/linux/appimage

bash build-image.sh
