#!/bin/bash

set -e

cd /krita
git pull

mkdir -p /krita_build
cd /krita_build 
. /opt/rh/devtoolset-3/enable
cmake3 /krita \
  -DCMAKE_INSTALL_PREFIX:PATH=/krita.appdir/usr \
  -DDEFINE_NO_DEPRECATED=1 \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DPACKAGERS_BUILD=1 \
  -DBUILD_TESTING=FALSE \
  -DKDE4_BUILD_TESTS=FALSE \
  -DHAVE_MEMORY_LEAK_TRACKER=FALSE

make -j4

bash /build-image.sh
