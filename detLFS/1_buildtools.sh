#!/bin/sh
# $Id: 1_buildtools.sh 78 2020-05-21 18:40:23Z dettus $

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

 The purpose of this script is to build the cross compiler to be used later.
 Hopefully, the previous scripts are finished at this point.
"

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): starting $0"

export TOOLSDIR=`pwd`/Tools
export BUILDDIR=`pwd`/Build
export SOURCESDIR=`pwd`/Sources
export DOWNLOADSDIR=`pwd`/Downloads

mkdir -p "$BUILDDIR"
mkdir -p "$TOOLSDIR"

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): installing Kernel Headers"
(
	cd "$BUILDDIR"
	cp -r --reflink=auto "$SOURCESDIR"/linux .
	cd linux
	mkdir -p "$TOOLSDIR"/usr/include/asm
	make  ARCH=arm INSTALL_HDR_PATH="$TOOLSDIR"/usr headers_install
)

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): installing glibc headers"
(
	cd "$BUILDDIR"
	mkdir glibc1 ; cd glibc1
	CC=gcc NM=nm "$SOURCESDIR"/glibc/configure --host=arm-linux-gnueabihf --prefix="$TOOLSDIR"/ --with-headers="$TOOLSDIR"/usr/include --with-fp
	make  -k cross-compiling=yes install-headers  
	mkdir -p "$TOOLSDIR"/include/gnu/
	touch "$TOOLSDIR"/include/gnu/stubs.h
)
echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): installing glibc headers"
(
	cd "$BUILDDIR"
	mkdir glibc2 ; cd glibc2
	CC=gcc NM=nm "$SOURCESDIR"/glibc/configure --host=arm-linux-gnueabihf --prefix="$TOOLSDIR"/arm-linux-gnueabihf/ --with-headers="$TOOLSDIR"/usr/include --with-fp
	make  -k cross-compiling=yes install-headers  
	mkdir -p "$TOOLSDIR"/arm-linux-gnueabihf/include/gnu/
	touch "$TOOLSDIR"/arm-linux-gnueabihf/include/gnu/stubs.h
)
echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): building binutils (cross)"
(
	cd "$BUILDDIR"
	mkdir binutils1 ; cd binutils1
	"$SOURCESDIR"/binutils/configure --target=arm-linux-gnueabihf --prefix="$TOOLSDIR" --with-sysroot --disable-nls --disable-werror
	make -j "$NUM_CPUS" && make install
)
echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): building gcc (cross)"
(
	cd "$BUILDDIR"
	mkdir gcc1 ; cd gcc1
	"$SOURCESDIR"/gcc/configure --target=arm-linux-gnueabihf --prefix="$TOOLSDIR" --disable-nls --disable-shared --enable-languages=c,c++ --with-arch=armv7-a --with-fpu=vfpv3-d16 --with-float=hard --disable-multilib --with-headers="$TOOLSDIR"/usr/include --with-build-time-tools="$TOOLSDIR" --with-build-sysroot="$TOOLSDIR"
	make -j "$NUM_CPUS" all-target-libgcc && make install-gcc && make install-target-libgcc

)

echo ">>> At this point, the cross compiler can be used to build the glibc"
export PATH="$TOOLSDIR"/bin:"$TOOLSDIR"/usr/bin:$PATH
echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): installing glibc (for real)"
(
	cd "$BUILDDIR"
	mkdir glibc3 ; cd glibc3
	"$SOURCESDIR"/glibc/configure --host=arm-linux-gnueabihf --prefix="$TOOLSDIR" --with-headers="$TOOLSDIR"/usr/include --with-fp
	make -j "$NUM_CPUS" cross-compiling=yes
	make  cross-compiling=yes  install
	make install
)

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): installing glibc (for the build)"
(
	cd "$BUILDDIR"
	mkdir glibc4 ; cd glibc4
	"$SOURCESDIR"/glibc/configure --host=arm-linux-gnueabihf --prefix="$TOOLSDIR"/arm-linux-gnueabihf/ --with-headers="$TOOLSDIR"/usr/include --with-fp
	echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): finished configure"
	make -j "$NUM_CPUS" cross-compiling=yes
	make  cross-compiling=yes  install
	make install
)
echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): building gcc (with shared)"
(
	cd "$BUILDDIR"
	mkdir gcc2 ; cd gcc2
	"$SOURCESDIR"/gcc/configure --target=arm-linux-gnueabihf --prefix="$TOOLSDIR" --disable-nls --enable-languages=c,c++ --disable-multilib --with-arch=armv7-a --with-fpu=vfpv3-d16 --with-float=hard --with-headers="$TOOLSDIR"/usr/include --with-build-time-tools="$TOOLSDIR"
	echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): finished configure"
	make -j "$NUM_CPUS" all-target-libgcc && make install-gcc && make install-target-libgcc
	make -j "$NUM_CPUS"
	make install
)


echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): Checking the Tools"
"$TOOLSDIR"/bin/arm-linux-gnueabihf-gcc -o Helloworld_shared.app helloworld.c
"$TOOLSDIR"/bin/arm-linux-gnueabihf-gcc -static -o Helloworld_static.app helloworld.c
file Helloworld_shared.app
file Helloworld_static.app

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): finished $0"
