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
http://github.com/bablokb/pi-detLFS

 The purpose of this script is to create an OS-image. It has
 to be run with ROOT PRIVILEDGES.

" ;

source vars.sh.inc

if [ "$UID" != "0" ]; then
  echo "error: you need to be root to run this script!" >&2
  exit 3
fi

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): starting $0"

if ! modprobe loop; then
  echo "error: could not load kernel-module loop!" >&2
  exit 3
fi

# calculate target size (use at least 512M)
tsize=$(du -s -BM "$DESTINATIONDIR")
let tsize="${tsize%%M*}"+256
[ "$tsize" -lt 512 ] && tsize=512
echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): size of image: $tsize MB"

# create sparse image
echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): creating sparse image"
dd if=/dev/zero of=detlfs.img bs=${tsize}M count=0 seek=1

# partition image:
#  1: 256M, type c
#  2: rest, type 83 (default linux)
echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): creating two partitions"
echo -e "n\np\n1\n8192\n532479\nt\nc\nn\np\n2\n532480\n\nw\n" | \
                                                fdisk detlfs.img

# create loop-device
loopdev=$(losetup --show -f -P detlfs.img)
echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): using loop-device $loopdev"

# format partitions
echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): formatting partitions"
mkfs.vfat ${loopdev}p1
mkfs.ext4 ${loopdev}p2

# mount partitions
echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): mounting partitions"
mntdir=$(mktemp -d --tmpdir detlfs.XXXXXX)
mount -t ext4 "${loopdev}p2" "$mntdir"
mkdir -p "$mntdir/boot"
mount -t vfat "${loopdev}p1" "$mntdir/boot"

# copy content
echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): copying $DESTINATIONDIR to $mntdir"

rsync -av "$DESTINATIONDIR/" "$mntdir"

# create necessary device-files
echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): creating nodes"
mknod "$mntdir/dev/console" c 5 1
mknod "$mntdir/dev/null"    c 1 3
mknod "$mntdir/dev/tty0"    c 4 0
mknod "$mntdir/dev/tty1"    c 4 1
mknod "$mntdir/dev/tty2"    c 4 2
mknod "$mntdir/dev/ttyAMA0" c 204 64
chown -R root:root "$mntdir/"
sync

# umount
echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): umounting partitions"
umount "$mntdir/boot" && umount "$mntdir" && rm -fr "$mntdir"

# cleanup loop-mounts
echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): releasing $loopdev"
losetup -d ${loopdev}

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): finished $0"
