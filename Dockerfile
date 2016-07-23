FROM centos:6.6
MAINTAINER Ilya Portnov <portnov@iportnov.ru>

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_us.UTF-8
ENV LD_LIBRARY_PATH=/usr/lib64/:/usr/lib:/krita.appdir/usr/lib
ARG BRANCH=master

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

RUN git clone  --depth 1 https://github.com/probonopd/AppImageKit.git /AppImageKit

RUN . /opt/rh/devtoolset-3/enable && \
  cd /AppImageKit/ && \
  ./build.sh

RUN ln -sf /usr/share/pkgconfig /usr/lib/pkgconfig

RUN git clone --branch=$BRANCH --depth 1 https://github.com/KDE/krita.git /krita

RUN mkdir /d /b

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

RUN cd /krita && \
    git checkout rempt/update-dependencies && \
    mkdir /krita_build && \
    cd /krita_build && \
    . /opt/rh/devtoolset-3/enable && \
    cmake3 /krita \
      -DCMAKE_INSTALL_PREFIX:PATH=/krita.appdir/usr \
      -DDEFINE_NO_DEPRECATED=1 \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DPACKAGERS_BUILD=1 \
      -DBUILD_TESTING=FALSE \
      -DKDE4_BUILD_TESTS=FALSE \
      -DHAVE_MEMORY_LEAK_TRACKER=FALSE && \
    make -j4

VOLUME /out

ENTRYPOINT ["cd /krita; git pull; /krita/packaging/linux/appimage/build-image.sh"]

