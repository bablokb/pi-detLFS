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

source vars.sh.inc

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): starting $0"

mkdir -p "$DESTINATIONDIR"

export PATH="$TOOLSDIR"/bin:$PATH


cd "$BUILDDIR"/
rm -rf linux ; cp -r --reflink=auto "$SOURCESDIR"/linux .
cd linux

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): creating the logo"

mylogo=$(ls -1 "$DETLFSROOT"/logo/mylogo.* 2>/dev/null | head -n 1)
if [ -n "$mylogo" ]; then
  echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): using logo: $mylogo"
  convert "$DETLFSROOT"/logo/mylogo.* -scale \!80x80 /tmp/mylogo.png
       pngtopnm /tmp/mylogo.png | ppmquant 224 | \
          pnmnoraw >drivers/video/logo/logo_linux_clut224.ppm
else
  echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): using default logo"
  cp -a "$DETLFSROOT"/logo/detLFS-logo.ppm \
           drivers/video/logo/logo_linux_clut224.ppm
fi

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): KERNEL-build: target $def_config"

make -j "$NUM_CPUS" ARCH=arm CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf- "$def_config"
cp -a .config "$DETLFSROOT"/.config.defconfig

# oldconfig will probably trigger some questions, so we copy it to
# reuse it without questions on a second run
if [ -f "$DETLFSROOT"/.config ]; then
  cp -a "$DETLFSROOT"/.config "$DETLFSROOT"/.config.in
  cp -a "$DETLFSROOT"/.config .config
  if [ -z "$MENUCONFIG" ]; then
    echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): KERNEL-build: target oldconfig"
    make ARCH=arm CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf- oldconfig
  else
    echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): KERNEL-build: target menuconfig"
    make ARCH=arm CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf- menuconfig
  fi
  cp -a .config "$DETLFSROOT"/.config
fi

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): KERNEL-build: targets zImage modules dtbs"

make -j "$NUM_CPUS" ARCH=arm CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf- zImage modules dtbs

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): KERNEL-build: installing files"

mkdir -p "$DESTINATIONDIR"/boot "$DESTINATIONDIR"/usr
make ARCH=arm CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf- INSTALL_MOD_PATH="$DESTINATIONDIR"/ modules_install
make ARCH=arm CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf- INSTALL_HDR_PATH="$DESTINATIONDIR"/usr/ headers_install

cp --reflink=auto arch/arm/boot/zImage "$DESTINATIONDIR"/boot/$KERNEL.img
cp --reflink=auto arch/arm/boot/dts/*.dtb "$DESTINATIONDIR"/boot

mkdir -p "$DESTINATIONDIR"/boot/overlays
cp --reflink=auto arch/arm/boot/dts/overlays/*.dtb* "$DESTINATIONDIR"/boot/overlays
cp --reflink=auto arch/arm/boot/dts/overlays/README "$DESTINATIONDIR"/boot/overlays

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): finished $0"
