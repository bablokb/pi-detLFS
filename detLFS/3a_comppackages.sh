#!/bin/sh
# $Id: 3a_comppackages.sh 78 2020-05-21 18:40:23Z dettus $

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

 The purpose of this script is to build the packages.

 Hopefully, the previous scripts are finished at this point.
"

source vars.sh.inc

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): starting $0"

export PATH="$TOOLSDIR"/bin:$PATH
export CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf-
export DESTDIR="$DESTINATIONDIR"


echo ">>> building BINUTILS" ; date
(
	cd "$BUILDDIR"
	mkdir binutils2/ ; cd binutils2
	export CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf-
	"$SOURCESDIR"/binutils/configure --target=arm-linux-gnueabihf --host=arm-linux-gnueabihf --prefix=/usr --with-sysroot --disable-nls --disable-werror
	echo ">>>>>" ; date
	make 
	make install
)

echo ">>> installing glibc (for real)" ; date
(
	cd "$BUILDDIR"
	mkdir glibc5 ; cd glibc5
	"$SOURCESDIR"/glibc/configure --host=arm-linux-gnueabihf --prefix=/usr --with-headers="$DESTINATIONDIR"/usr/include
	echo ">>>>>" ; date
	make  cross-compiling=yes
	make  cross-compiling=yes  install
	make install
)

echo ">>> installing glibc (again)" ; date
(
	cd "$BUILDDIR"
	mkdir glibc6 ; cd glibc6
	"$SOURCESDIR"/glibc/configure --host=arm-linux-gnueabihf --prefix=/arm-linux-gnueabihf/ --with-headers="$DESTINATIONDIR"/usr/include
	echo ">>>>>" ; date
	make  cross-compiling=yes
	make  cross-compiling=yes  install
	make install
)

echo ">>> building gcc (arm->arm)" ; date
(
	cd "$BUILDDIR"
	mkdir gcc3 ; cd gcc3
	"$SOURCESDIR"/gcc/configure --prefix=/usr --target=arm-linux-gnueabihf --host=arm-linux-gnueabihf --disable-nls --enable-languages=c,c++ --disable-multilib --with-arch=armv7 --with-fpu=vfpv3-d16 --with-float=hard --with-build-sysroot="$DESTINATIONDIR"
	echo ">>>>>" ; date
	make  all-target-libgcc && make install-gcc && make install-target-libgcc
	make 
	make install
)

echo ">>> building make" ; date
(
	cd "$BUILDDIR"
	mkdir make1 ; cd make1
	"$SOURCESDIR"/make/configure --prefix=/usr --target=arm-linux-gnueabihf --host=arm-linux-gnueabihf  --without-guile
	make 
	make install
)

du -sh "$TOOLSDIR"
du -sh "$BUILDDIR"
du -sh "$DESTINATIONDIR"
du -sh "$DESTINATIONDIR"/boot

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): finished $0"
