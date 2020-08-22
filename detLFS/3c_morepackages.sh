#!/bin/bash

#Copyright (c) 2020, Thomas Dettbarn, Bernhard Bablok
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are met:
#
#1. Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#2. Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
#ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

echo " 
       -----         -----         
      /     \\       /     \\       /
     /       \\     /       \\     /
-----         -----         -----
     \\       /     \\       /     \\
      \\     /       \\     /       \\
       -----         ----- detLFS  -
      /     \\       /     \\       /
     /       \\     /       \\     /
-----         -----         -----
https://github.com/bablokb/pi-detLFS

 The purpose of this script is to provide an example of how to 
 compile your own packages.

 Hopefully, the previous scripts are finished at this point.
"

source vars.sh.inc

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): starting $0"

export PATH="$TOOLSDIR"/bin:$PATH
export CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf-
export DESTDIR="$DESTINATIONDIR"


echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): ncurses"
(
  wget -nv --directory-prefix="$DOWNLOADSDIR" -c ftp://ftp.gnu.org/gnu/ncurses/ncurses-6.1.tar.gz
  cd "$SOURCESDIR"
  tar -xfz "$DOWNLOADSDIR"/ncurses-6.1.tar.gz
  mv ncurses-6.1 ncurses

  cd "$BUILDDIR"
  mkdir ncurses1
  cd ncurses1
  "$SOURCESDIR"/ncurses/configure --prefix=/usr --target=arm-linux-gnueabihf \
    --host=arm-linux-gnueabihf --without-sysmouse \
      --disable-ext-mouse  --enable-widec --with-shared --with-cxx-shared
  make -j "$NUM_CPUS"&& make -j "$NUM_CPUS" install -i
)

echo ">> $(date +'%Y-%m-%d %H:%M:%S'): building alsa-firmware"
(
  wget -nv --directory-prefix="$DOWNLOADSDIR" -c ftp://ftp.alsa-project.org/pub/firmware/alsa-firmware-1.0.29.tar.bz2
  cd "$SOURCESDIR"
  tar -xfj "$DOWNLOADSDIR"/alsa-firmware-1.0.29.tar.bz2
  mv alsa-firmware-1.0.29 alsa-firmware

  cd "$BUILDDIR"
  mkdir alsa-firmware1
  cd alsa-firmware1
  cp --reflink=auto -r "$SOURCESDIR"/alsa-firmware .

  # alsa firmware does not build like the others.
  cd alsa-firmware
  ./configure --prefix=/usr --target=arm-linux-gnueabihf 
  make -j "$NUM_CPUS"
  make -j "$NUM_CPUS" install
)

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): building alsa-libs"
(
  wget -nv --directory-prefix="$DOWNLOADSDIR" -c ftp://ftp.alsa-project.org/pub/lib/alsa-lib-1.1.8.tar.bz2
  cd "$SOURCESDIR"
  tar -xfj "$DOWNLOADSDIR"/alsa-lib-1.1.8.tar.bz2
  mv alsa-lib-1.1.8 alsa-lib

  cd "$BUILDDIR"
  mkdir alsa-lib1
  cd alsa-lib1
  "$SOURCESDIR"/alsa-lib/configure --target=arm-linux-gnueabihf --prefix=/usr
  make -j "$NUM_CPUS"
  make -j "$NUM_CPUS" install
)

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): finished $0"
