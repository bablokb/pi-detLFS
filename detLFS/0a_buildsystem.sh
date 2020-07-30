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

 This script is downloading the packages prior to anything else.
 It is also unpacking them in the Sources folder, and renamining
 them. This makes upgrading the system easier, because the Version
 numbers have to be changed in here, nowhere else.

 This script downloads packages for the buildsystem.
" ;

source vars.sh.inc

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): starting $0"

mkdir -p "$DOWNLOADSDIR"
mkdir -p "$SOURCESDIR"

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

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): finished $0"
