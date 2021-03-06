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

 This script downloads packages for the basesystem.
" ;

source vars.sh.inc

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): starting $0"

mkdir -p "$DOWNLOADSDIR/boot"
mkdir -p "$SOURCESDIR"

if [ ! -f "$DOWNLOADSDIR/.detlfs.bootloader" ]; then
  echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): downloading Raspberry Pi's bootloader"
  FIRMWARE_URL="https://raw.githubusercontent.com/raspberrypi/firmware/master/boot"
  for f in bootcode.bin fixup.dat fixup4.dat fixup4cd.dat fixup4db.dat fixup4x.dat \
           fixup_cd.dat fixup_db.dat fixup_x.dat start.elf start4.elf \
           start4cd.elf start4db.elf start4x.elf start_cd.elf start_db.elf start_x.elf; do
    wget -nv -O "$DOWNLOADSDIR/boot/$f" "$FIRMWARE_URL/$f" &
  done
  wait
  touch "$DOWNLOADSDIR/.detlfs.bootloader"
fi

if [ ! -f "$DOWNLOADSDIR/.detlfs.busybox" ]; then
  echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): downloading busybox"
  # if you are updating to a new version of busybox, you will have to monitor the build process. the standard config_busybox file might fail.
  wget -nv --directory-prefix="$DOWNLOADSDIR" -c https://busybox.net/downloads/busybox-1.31.1.tar.bz2
  tar -xjpf "$DOWNLOADSDIR"/busybox-1.31.1.tar.bz2 -C "$SOURCESDIR"
  mv "$SOURCESDIR"/busybox-1.31.1 "$SOURCESDIR"/busybox
  touch "$DOWNLOADSDIR/.detlfs.busybox"
fi

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): finished $0"
