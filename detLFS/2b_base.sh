#!/bin/sh
# $Id: 2_basesystem.sh 78 2020-05-21 18:40:23Z dettus $

#Copyright (c) 2020, Thomas Dettbarn
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
#ANY DIRECT, INDIRECT, INCIUDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
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

 The purpose of this script is to build Busybox.

 It will also copy the init-scripts and the bootloader into the destination
 directory. The configuration part could be performed with menuconfig, for
 the purpose of minimalism, this script is copying a generic configuration.

 Hopefully, the previous scripts are finished at this point.
"

source vars.sh.inc

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): starting $0"

mkdir -p "$DESTINATIONDIR"

export PATH="$TOOLSDIR"/bin:$PATH

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): building BUSYBOX"
(
  cd "$BUILDDIR"/
  rm -rf busybox
  cp --reflink=auto -r "$SOURCESDIR"/busybox .
  cd busybox
  (
    cd networking
echo "6c6,7
< 
---
> #include <limits.h>
> #include <bits/xopen_lim.h>
" | patch -p0 tls_aesgcm.c
  )
  make -j "$NUM_CPUS" ARCH=arm CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf- defconfig
## configuration of busybox can be done by choosing one of the two
  cat "$DETLFSROOT"/config_busybox | sed -e 's?CONFIG_CROSS_COMPILER_PREFIX=".*"?CONFIG_CROSS_COMPILER_PREFIX="'$TOOLSDIR'/bin/arm-linux-gnueabihf-"?g' >.config
# 	vimdiff .config ../../../config_busybox
#   	make ARCH=arm menuconfig
### pick one!
  make ARCH=arm CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf- install
  cd _install &&	\
    (
      pwd
      tar cvf - * | ( cd "$DESTINATIONDIR" ; tar xvf - )
    )
)

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): copying skeldir/"
(
  cd "$DETLFSROOT"/skeldir
  pwd
  tar cvf - * | ( cd "$DESTINATIONDIR" ; tar xvf - )
)

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): installing glibc (for real)"
(
	cd "$BUILDDIR"
	mkdir glibc5 ; cd glibc5
	"$SOURCESDIR"/glibc/configure --host=arm-linux-gnueabihf --prefix=/usr --with-headers="$DESTINATIONDIR"/usr/include
	echo ">>>>>" ; date
	make  cross-compiling=yes
	make  cross-compiling=yes  install
	make install
)

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): installing glibc (again)"
(
	cd "$BUILDDIR"
	mkdir glibc6 ; cd glibc6
	"$SOURCESDIR"/glibc/configure --host=arm-linux-gnueabihf --prefix=/arm-linux-gnueabihf/ --with-headers="$DESTINATIONDIR"/usr/include
	echo ">>>>>" ; date
	make  cross-compiling=yes
	make  cross-compiling=yes  install
	make install
)

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): copying raspberry specific bootloader files"
(
  cp --reflink=auto "$DOWNLOADSDIR"/boot/* "$DESTINATIONDIR"/boot/
)

du -sh "$DESTINATIONDIR"

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): finished $0"
