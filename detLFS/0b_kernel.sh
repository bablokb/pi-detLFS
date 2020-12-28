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

 The kernel is being downloaded from the Raspberry Github, since
 this is the platform I plan on running everything on.
" ;

source vars.sh.inc

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): starting $0"

mkdir -p "$DOWNLOADSDIR"
mkdir -p "$SOURCESDIR"

if [ ! -f "$DOWNLOADSDIR/.detlfs.kernel" ]; then
  echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): cloning the kernel-source"

  # get kernel-version
  if [ -f ".config" ]; then
    kversion=$(sed -n '/Kernel Configuration/s/[^0-9]* \([^ ]*\).*/\1/p' .config)
    kbranch="rpi-${kversion%.*}.y"
  elif [ -n "$BRANCH" ]; then
    kbranch="$BRANCH"
  else
    kbranch=""
  fi
  echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): using branch ${kbranch:-default}"

  rm -fr "$DOWNLOADSDIR"/linux
  git clone --depth=1 ${kbranch:+--branch $kbranch} \
               https://github.com/raspberrypi/linux "$DOWNLOADSDIR"/linux
  rm -rf "$DOWNLOADSDIR/linux/.git"
  touch "$DOWNLOADSDIR/.detlfs.kernel"

  rm -fr "$SOURCESDIR"/linux
  cp --reflink=auto -r "$DOWNLOADSDIR"/linux "$SOURCESDIR"/
fi

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): finished $0"
