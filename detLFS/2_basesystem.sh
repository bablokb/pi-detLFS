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
http://www.dettus.net/detLFS/detLFS_0.07.tar.bz2

 The purpose of this script is to build the linux Kernel and Busybox.
 It will also copy the init-scripts and the bootloader into the Destination
 directory. The configuration part could be performed with menuconfig, for
 the purpose of minimalism, this script is copying a generic configuration.

 Hopefully, the previous scripts are finished at this point.
"

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): starting $0"

export DETLFSROOT=`pwd`
export TOOLSDIR=`pwd`/Tools
export BUILDDIR=`pwd`/Build
export SOURCESDIR=`pwd`/Sources
export DOWNLOADSDIR=`pwd`/Downloads
export DESTINATIONDIR=`pwd`/Destination

mkdir -p "$DESTINATIONDIR"

export PATH="$TOOLSDIR"/bin:$PATH

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): building KERNEL (raspberry pi specific)"
(
	cd "$BUILDDIR"/
	rm -rf linux ; cp -r --reflink=auto "$SOURCESDIR"/linux .
	cd linux
	export KERNEL=kernel7
	convert "$DETLFSROOT"/logo/mylogo.xpm -scale \!80x80 /tmp/mylogo.png
	pngtopnm /tmp/mylogo.png | ppmquant 224 | pnmnoraw >drivers/video/logo/logo_linux_clut224.ppm
        make ARCH=arm CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf- bcm2709_defconfig
## configuration of the kernel can be done by choosing one of the three. 
##	cat "$DETLFSROOT"/config_kernel | sed -e 's?CONFIG_CROSS_COMPILE=".*"?CONFIG_CROSS_COMPILE="'$TOOLSDIR'/bin/arm-linux-gnueabihf-"?g' >.config 
#	vimdiff .config "$DETLFSROOT"/config_kernel
#	make ARCH=arm menuconfig
### pick one!
	make ARCH=arm CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf- zImage modules dtbs
	mkdir -p "$DESTINATIONDIR"/boot "$DESTINATIONDIR"/usr
	make ARCH=arm CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf- INSTALL_MOD_PATH="$DESTINATIONDIR"/ modules_install
	make ARCH=arm CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf- INSTALL_HDR_PATH="$DESTINATIONDIR"/usr/ headers_install
	cp --reflink=auto arch/arm/boot/zImage "$DESTINATIONDIR"/boot/kernel.img
	cp --reflink=auto arch/arm/boot/dts/*.dtb "$DESTINATIONDIR"/boot
	mkdir -p "$DESTINATIONDIR"/boot/overlays
	cp --reflink=auto arch/arm/boot/dts/overlays/*.dtb "$DESTINATIONDIR"/boot/overlays
	cp --reflink=auto arch/arm/boot/dts/overlays/README "$DESTINATIONDIR"/boot/overlays
)

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): building BUSYBOX"
(
	cd "$BUILDDIR"/
	rm -rf busybox ; cp --reflink=auto -r "$SOURCESDIR"/busybox . ; cd busybox
	(
		cd networking
echo "6c6,7
< 
---
> #include <limits.h>
> #include <bits/xopen_lim.h>
" | patch -p0 tls_aesgcm.c
	)
        make ARCH=arm CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf- defconfig
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
echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): copying raspberry specific bootloader files" ; date
(
	cp --reflink=auto "$DOWNLOADSDIR"/start.elf "$DOWNLOADSDIR"/bootcode.bin "$DESTINATIONDIR"/boot/
)

du -sh "$DESTINATIONDIR"

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): finished $0"
