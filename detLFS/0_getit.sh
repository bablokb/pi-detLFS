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
" ;

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): starting $0"

export DOWNLOADSDIR=`pwd`/Downloads
export SOURCESDIR=`pwd`/Sources
mkdir -p "$DOWNLOADSDIR"
mkdir -p "$SOURCESDIR"

if [ ! -f "$DOWNLOADSDIR/.detlfs.kernel" ]; then
  echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): downloading the kernel, specifically for the Raspberry Pi"
  # get kernel-version from config_kernel
  kversion=$(sed -n '/Kernel Configuration/s/[^0-9]* \([^ ]*\).*/\1/p' config_kernel)
  kbranch="rpi-${kversion%.*}.y"
  echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): using branch $kbranch"
  git clone --depth=1 --branch "$kbranch" https://github.com/raspberrypi/linux "$DOWNLOADSDIR"/linux
  rm -rf "$DOWNLOADSDIR/linux/.git"
  touch "$DOWNLOADSDIR/.detlfs.kernel"
  cp --reflink=auto -r "$DOWNLOADSDIR"/linux "$SOURCESDIR"/
fi

if [ ! -f "$DOWNLOADSDIR/.detlfs.bootloader" ]; then
  echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): downloading Raspberry Pi's bootloader"
  wget -O "$DOWNLOADSDIR"/bootcode.bin  "https://raw.githubusercontent.com/raspberrypi/firmware/master/boot/bootcode.bin"
  wget -O "$DOWNLOADSDIR"/start.elf "https://raw.githubusercontent.com/raspberrypi/firmware/master/boot/start.elf"
  touch "$DOWNLOADSDIR/.detlfs.bootloader"
fi

if [ ! -f "$DOWNLOADSDIR/.detlfs.busybox" ]; then
  echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): downloading busybox"
  # if you are updating to a new version of busybox, you will have to monitor the build process. the standard config_busybox file might fail.
  wget --directory-prefix="$DOWNLOADSDIR" -c https://busybox.net/downloads/busybox-1.31.1.tar.bz2
  tar -xjpf "$DOWNLOADSDIR"/busybox-1.31.1.tar.bz2 -C "$SOURCESDIR"
  mv "$SOURCESDIR"/busybox-1.31.1 "$SOURCESDIR"/busybox
  touch "$DOWNLOADSDIR/.detlfs.busybox"
fi

if [ ! -f "$DOWNLOADSDIR/.detlfs.binutils" ]; then
  echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): downloading binutils"
  wget --directory-prefix="$DOWNLOADSDIR" -c ftp://ftp.gnu.org/gnu/binutils/binutils-2.32.tar.xz
  tar -xpJf "$DOWNLOADSDIR"/binutils-2.32.tar.xz -C "$SOURCESDIR"
  mv "$SOURCESDIR"/binutils-2.32 "$SOURCESDIR"/binutils
  touch "$DOWNLOADSDIR/.detlfs.binutils"
fi

if [ ! -f "$DOWNLOADSDIR/.detlfs.glibc" ]; then
  echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): downloading glibc"
  wget --directory-prefix="$DOWNLOADSDIR" -c ftp://ftp.gnu.org/gnu/glibc/glibc-2.29.tar.xz
  tar -xpJf "$DOWNLOADSDIR"/glibc-2.29.tar.xz -C "$SOURCESDIR"
  mv "$SOURCESDIR"/glibc-2.29 "$SOURCESDIR"/glibc
  touch "$DOWNLOADSDIR/.detlfs.glibc"
fi

if [ ! -f "$DOWNLOADSDIR/.detlfs.gcc" ]; then
  echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): downloading gcc"
  wget --directory-prefix="$DOWNLOADSDIR" -c ftp://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz
  wget --directory-prefix="$DOWNLOADSDIR" -c ftp://ftp.gnu.org/gnu/mpfr/mpfr-4.0.2.tar.xz
  wget --directory-prefix="$DOWNLOADSDIR" -c ftp://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz
  wget --directory-prefix="$DOWNLOADSDIR" -c ftp://ftp.gnu.org/gnu/gcc/gcc-8.3.0/gcc-8.3.0.tar.gz
  tar -xpzf "$DOWNLOADSDIR"/gcc-8.3.0.tar.gz -C "$SOURCESDIR"
  mv "$SOURCESDIR"/gcc-8.3.0 "$SOURCESDIR"/gcc
  tar -xpJf "$DOWNLOADSDIR"/gmp-6.1.2.tar.xz -C "$SOURCESDIR"/gcc
  mv "$SOURCESDIR"/gcc/gmp-6.1.2 "$SOURCESDIR"/gcc/gmp
  tar -xpJf "$DOWNLOADSDIR"/mpfr-4.0.2.tar.xz -C "$SOURCESDIR"/gcc
  mv "$SOURCESDIR"/gcc/mpfr-4.0.2 "$SOURCESDIR"/gcc/mpfr
  tar -xpzf "$DOWNLOADSDIR"/mpc-1.1.0.tar.gz -C "$SOURCESDIR"/gcc
  mv "$SOURCESDIR"/gcc/mpc-1.1.0 "$SOURCESDIR"/gcc/mpc
  touch "$DOWNLOADSDIR/.detlfs.gcc"
fi

if [ ! -f "$DOWNLOADSDIR/.detlfs.make" ]; then
  echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): downloading make"
  wget --directory-prefix="$DOWNLOADSDIR" -c ftp://ftp.gnu.org/gnu/make/make-4.2.1.tar.gz
  tar -xzpf "$DOWNLOADSDIR"/make-4.2.1.tar.gz -C "$SOURCESDIR"
  mv "$SOURCESDIR"/make-4.2.1 "$SOURCESDIR"/make
  # fixing make/glob/glob.c to circumvent an old __alloca bug
  echo "232a233
> # define __alloca     alloca" | patch -p0 "$SOURCESDIR"/make/glob/glob.c
  touch "$DOWNLOADSDIR/.detlfs.make"
fi

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): finished $0"
