krita-builder README
====================

# General description

This is a dockerfile + shell script which can be used to build Krita AppImage
from krita git master at any time, so that you can get fresh appimage for
testing at any moment, without littering your working system with lots of
development packages.
The script is mainly intended for Krita enthusiasts, testers and other
people who want to run the very last version of Krita.

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
* So after "docker build" you have an image with all dependencies. The image
  can be used many times.
* When "docker run" is called, it runs entrypoint.sh, which basically does the
  following:
    - git pull
    - build last version of Krita.
    - run build-image.sh script shipped with Krita. This script also calls
      "make", so it will rebuild files changed in git repo since image was
      built.

Built binary files for Krita are put under "build/" directory. They are stored
usage in subsequent compilations. If you want to place them in another
directory, or do not save them at all, you will need to tweak build-appimage.sh
script.

# Dependencies

* docker

# Usage

Run

    $ ./build-appimage.sh

And wait... it gonna take a lot of time, mostly for Qt build.

After script finishes, you will find krita*.appimage file under out/ directory.

If you want to obtain the last version of Krita, just run the same script
again. For the second and all other times, it will run much faster - since
you already have all dependencies and some version of Krita built.
