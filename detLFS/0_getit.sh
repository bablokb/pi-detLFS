#!/bin/sh
# $Id: 0_getit.sh 78 2020-05-21 18:40:23Z dettus $

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

 This script is downloading the packages prior to anything else.
 It is also unpacking them in the Sources folder, and renamining
 them. This makes upgrading the system easier, because the Version
 numbers have to be changed in here, nowhere else.

 The kernel is being downloaded from the Raspberry Github, since
 this is the platform I plan on running everything on.
" ; date 




export DOWNLOADSDIR=`pwd`/Downloads
export SOURCESDIR=`pwd`/Sources
mkdir -p $DOWNLOADSDIR
mkdir -p $SOURCESDIR

echo ">>> downloading the kernel, specifically for the Raspberry Pi" ; date 
(
	cd $DOWNLOADSDIR
	git clone https://github.com/raspberrypi/linux
	git reset --hard git 4eda74f2dfcc8875482575c79471bde6766de3ad # this version of the kernel matches the pre-defined config file. you can use the latest version, but then you'd have to change 2_basesytem.sh as well.
	rm -rf linux/.git
	cp -r $DOWNLOADSDIR/linux $SOURCESDIR/
)
echo ">>> downloading Raspberry Pi's bootloader" ; date 
(
	wget -O $DOWNLOADSDIR/bootcode.bin  "https://raw.githubusercontent.com/raspberrypi/firmware/master/boot/bootcode.bin" 
	wget -O $DOWNLOADSDIR/start.elf "https://raw.githubusercontent.com/raspberrypi/firmware/master/boot/start.elf" 
)
echo ">>> downloading busybox" ; date 
(
	# if you are updating to a new version of busybox, you will have to monitor the build process. the standard config_busybox file might fail.
	wget --directory-prefix=$DOWNLOADSDIR -c https://busybox.net/downloads/busybox-1.31.1.tar.bz2
	cd $SOURCESDIR ; tar xfj $DOWNLOADSDIR/busybox-1.31.1.tar.bz2 ; mv busybox-1.31.1 busybox
)
echo ">>> downloading binutils" ; date 
(
	wget --directory-prefix=$DOWNLOADSDIR -c ftp://ftp.gnu.org/gnu/binutils/binutils-2.32.tar.xz
	cd $SOURCESDIR ; tar xfJ $DOWNLOADSDIR/binutils-2.32.tar.xz ; mv binutils-2.32 binutils
)
echo ">>> downloading glibc" ; date 
(
	wget --directory-prefix=$DOWNLOADSDIR -c ftp://ftp.gnu.org/gnu/glibc/glibc-2.29.tar.xz
	cd $SOURCESDIR ; tar xfJ $DOWNLOADSDIR/glibc-2.29.tar.xz ; mv glibc-2.29 glibc
)
echo ">>> downloading gcc" ; date 
(
	wget --directory-prefix=$DOWNLOADSDIR -c ftp://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz
	wget --directory-prefix=$DOWNLOADSDIR -c ftp://ftp.gnu.org/gnu/mpfr/mpfr-4.0.2.tar.xz
	wget --directory-prefix=$DOWNLOADSDIR -c ftp://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz
	wget --directory-prefix=$DOWNLOADSDIR -c ftp://ftp.gnu.org/gnu/gcc/gcc-8.3.0/gcc-8.3.0.tar.gz
	cd $SOURCESDIR ; tar xfz $DOWNLOADSDIR/gcc-8.3.0.tar.gz ; mv gcc-8.3.0 gcc
	cd gcc
	tar xfJ $DOWNLOADSDIR/gmp-6.1.2.tar.xz ; mv gmp-6.1.2 gmp
	tar xfJ $DOWNLOADSDIR/mpfr-4.0.2.tar.xz ; mv mpfr-4.0.2 mpfr
	tar xfz $DOWNLOADSDIR/mpc-1.1.0.tar.gz ; mv mpc-1.1.0 mpc

)

echo ">>> downloading make" ; date
(
	 wget --directory-prefix=$DOWNLOADSDIR -c ftp://ftp.gnu.org/gnu/make/make-4.2.1.tar.gz
	cd $SOURCESDIR ; tar xfz $DOWNLOADSDIR/make-4.2.1.tar.gz ; mv make-4.2.1 make
# fixing make/glob/glob.c to circumvent an old __alloca bug
echo "232a233
> # define __alloca     alloca" | patch -p0 make/glob/glob.c
)

echo ">>> done" ; date

