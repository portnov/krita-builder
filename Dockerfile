# This Dockerfile is basically a translation of 
# packaging/linux/appimage/build-deps.sh script shipped with Krita.

FROM centos:6.6
MAINTAINER Ilya Portnov <portnov@iportnov.ru>

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_us.UTF-8
ENV LD_LIBRARY_PATH=/usr/lib64/:/usr/lib:/krita.appdir/usr/lib
# Krita git repo branch which you want to build.
# Default is master. Change it by passing --build-arg BRANCH=something to docker build.
ARG BRANCH=master

# Install basic developement dependencies
RUN yum -y install epel-release && \
    yum -y update && \
    yum -y install wget tar bzip2 git libtool \
      which fuse fuse-devel libpng-devel automake \
      libtool mesa-libEGL cppunit-devel cmake3 \
      glibc-headers libstdc++-devel gcc-c++ freetype-devel \
      fontconfig-devel libxml2-devel libstdc++-devel \
      libXrender-devel patch xcb-util-keysyms-devel \
      libXi-devel mesa-libGL-devel libxcb libxcb-devel \
      xcb-util xcb-util-devel mesa-libGLU-devel

# Install Krita build dependencies
RUN yum -y install centos-release-scl-rh && \
    yum -y install devtoolset-3-gcc devtoolset-3-gcc-c++

# Clone AppImageKit repo
RUN git clone  --depth 1 https://github.com/probonopd/AppImageKit.git /AppImageKit

# Build AppImageKit
# Note: every build command has to include devtoolset-3/enable to use correct 
# G++/libs versions.
RUN . /opt/rh/devtoolset-3/enable && \
  cd /AppImageKit/ && \
  ./build.sh

# Workaround for: On CentOS 6, .pc files in /usr/lib/pkgconfig are not recognized
# However, this is where .pc files get installed when bulding libraries... (FIXME)
# I found this by comparing the output of librevenge's "make install" command
# between Ubuntu and CentOS 6
RUN ln -sf /usr/share/pkgconfig /usr/lib/pkgconfig

# Clone Krita git repo
RUN git clone --branch=$BRANCH --depth 1 https://github.com/KDE/krita.git /krita

# Make directories for downloads and dependencies
RUN mkdir /d /b

# Build 3rdparty dependencies which are shipped with krita.
RUN cd /b && \
  cmake3 /krita/3rdparty \
    -DCMAKE_INSTALL_PREFIX:PATH=/usr \
    -DINSTALL_ROOT=/usr \
    -DEXTERNALS_DOWNLOAD_DIR=/d

RUN cd /b && . /opt/rh/devtoolset-3/enable && cmake3 --build . --config RelWithDebInfo --target ext_qt
RUN cd /b && . /opt/rh/devtoolset-3/enable && cmake3 --build . --config RelWithDebInfo --target ext_boost
RUN cd /b && . /opt/rh/devtoolset-3/enable && cmake3 --build . --config RelWithDebInfo --target ext_eigen3
RUN cd /b && . /opt/rh/devtoolset-3/enable && cmake3 --build . --config RelWithDebInfo --target ext_exiv2
RUN cd /b && . /opt/rh/devtoolset-3/enable && cmake3 --build . --config RelWithDebInfo --target ext_fftw3
RUN cd /b && . /opt/rh/devtoolset-3/enable && cmake3 --build . --config RelWithDebInfo --target ext_lcms2
RUN cd /b && . /opt/rh/devtoolset-3/enable && cmake3 --build . --config RelWithDebInfo --target ext_ocio
RUN cd /b && . /opt/rh/devtoolset-3/enable && cmake3 --build . --config RelWithDebInfo --target ext_openexr
RUN cd /b && . /opt/rh/devtoolset-3/enable && cmake3 --build . --config RelWithDebInfo --target ext_vc
RUN cd /b && . /opt/rh/devtoolset-3/enable && cmake3 --build . --config RelWithDebInfo --target ext_tiff
RUN cd /b && . /opt/rh/devtoolset-3/enable && cmake3 --build . --config RelWithDebInfo --target ext_jpeg
RUN cd /b && . /opt/rh/devtoolset-3/enable && cmake3 --build . --config RelWithDebInfo --target ext_libraw
# XXX: this builds, but cmake3 never manages to find the library
#cmake3 --build . --config RelWithDebInfo --target ext_openjpeg
RUN cd /b && . /opt/rh/devtoolset-3/enable && cmake3 --build . --config RelWithDebInfo --target ext_kcrash
RUN cd /b && . /opt/rh/devtoolset-3/enable && cmake3 --build . --config RelWithDebInfo --target ext_poppler
RUN cd /b && . /opt/rh/devtoolset-3/enable && cmake3 --build . --config RelWithDebInfo --target ext_gsl

VOLUME /out
VOLUME /krita_build

# This script will be executed each time at `docker run'.
ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

