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

 The purpose of this script is to build the linux Kernel.

 Hopefully, the previous scripts are finished at this point.
"

if [ -z "$target" ]; then
  echo "please set 'target' to one of [pi0,pi1,pi2,pi3,pi4] and restart"
  exit 3
fi
target="${target#pi}"
if [ "$target" -lt 2 ]; then
  echo "building for Pi0/Pi0w/Pi1/CM1"
  export KERNEL="kernel" defconfig="bcmrpi_defconfig"
elif [ "$target" -lt 4 ]; then
  echo "building for Pi2/Pi3/CM3"
  export KERNEL="kernel7" defconfig="bcm2709_defconfig"
else
  echo "building for Pi4"
  export KERNEL="kernel7l" defconfig="bcm2711_defconfig"
fi

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): starting $0"

export DETLFSROOT=`pwd`
export TOOLSDIR=`pwd`/Tools
export BUILDDIR=`pwd`/Build
export SOURCESDIR=`pwd`/Sources
export DOWNLOADSDIR=`pwd`/Downloads
export DESTINATIONDIR=`pwd`/Destination

[ -z "$NUM_CPUS" ] && NUM_CPUS=$(nproc)

mkdir -p "$DESTINATIONDIR"

export PATH="$TOOLSDIR"/bin:$PATH

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): building KERNEL (raspberry pi specific)"

cd "$BUILDDIR"/
rm -rf linux ; cp -r --reflink=auto "$SOURCESDIR"/linux .
cd linux

convert "$DETLFSROOT"/logo/mylogo.xpm -scale \!80x80 /tmp/mylogo.png
pngtopnm /tmp/mylogo.png | ppmquant 224 | pnmnoraw >drivers/video/logo/logo_linux_clut224.ppm

make -j "$NUM_CPUS" ARCH=arm CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf- "$def_config"

# oldconfig will probably trigger some questions, so we copy it to
# reuse it without questions on a second run
cp -a "$DETLFSROOT"/config_kernel "$DETLFSROOT"/config_kernel.in
cp -a "$DETLFSROOT"/config_kernel .config
make ARCH=arm CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf- oldconfig
cp -a .config "$DETLFSROOT"/config_kernel


make -j "$NUM_CPUS" ARCH=arm CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf- zImage modules dtbs

mkdir -p "$DESTINATIONDIR"/boot "$DESTINATIONDIR"/usr
make ARCH=arm CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf- INSTALL_MOD_PATH="$DESTINATIONDIR"/ modules_install
make ARCH=arm CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf- INSTALL_HDR_PATH="$DESTINATIONDIR"/usr/ headers_install

cp --reflink=auto arch/arm/boot/zImage "$DESTINATIONDIR"/boot/kernel.img
cp --reflink=auto arch/arm/boot/dts/*.dtb "$DESTINATIONDIR"/boot

mkdir -p "$DESTINATIONDIR"/boot/overlays
cp --reflink=auto arch/arm/boot/dts/overlays/*.dtb* "$DESTINATIONDIR"/boot/overlays
cp --reflink=auto arch/arm/boot/dts/overlays/README "$DESTINATIONDIR"/boot/overlays

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): finished $0"
