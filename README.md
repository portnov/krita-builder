krita-builder README
====================

# General description

This is a dockerfile + shell script which can be used to build Krita AppImage
from krita git master at any time, so that you can get fresh appimage for
testing at any moment, without littering your working system with lots of
development packages.

I'm not sure that current implementation is the best way to achieve the
purpose, but it works.

The way it works is:

* build-appimage.sh script calls "docker build" && "docker run".
* Dockerfile contains instructions to:
    - get empty centos 6.6,
    - install all dependencies that can be installed from centos repos, 
    - clone Krita git repo,
    - build all dependencies that are shipped with Krita,
    - build Krita itself.
* So after "docker build" you have an image with all dependencies and some
  revision of Krita built. The image can be used many times.
* When "docker run" is called, it runs entrypoint.sh, which basically does the
  following:
    - git pull
    - run build-image.sh script shipped with Krita. This script also calls
      "make", so it will rebuild files changed in git repo since image was
      built.

# Dependencies

* docker

# Usage

Run

    $ ./build-appimage.sh

And wait... it gonna take lot of time, mostly for Qt build.

