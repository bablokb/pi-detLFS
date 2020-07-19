#!/bin/sh
# $Id: 4_mksdcard.sh 78 2020-05-21 18:40:23Z dettus $

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

 The purpose of this script is to prepare the SD Card. It has
 to be run with ROOT PRIVILEDGES and is DANGEROUS. PLEASE LOOK
 AT IT BEFORE YOU RUN IT!!!
 Hopefully, the previous scripts are finished at this point.
"
echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): starting $0"

echo "aborting now." ;  exit ## COMMENT THIS ONE OUT ONCE YOU UNDERSTAND THE SCRIPT


export DESTINATIONDIR=`pwd`/Destination
export MNTDIR=`pwd`/Mnt
export MMCCARD="/dev/sdg"

export BOOTFS=$MMCCARD"1"
export ROOTFS=$MMCCARD"2"

echo "WARNING! THIS WILL ERASE THE CONTENT OF $MMCCARD"
echo "AND CREATE boot $BOOTFS AND root $ROOTFS ON IT."
echo "YOU HAVE 30 seconds TO ABORT"

sleep 30
mkdir -p "$MNTDIR"

for I in $MMCCARD"*"
do
	umount $I
done

dd if=/dev/zero of="$MMCCARD" bs=1M count=16
echo "please create one msdos-partioni (16Mb), and one linux-partition."
echo "n - new partition"
echo "t - type"
echo "    c=msdos, 83=linux"
echo "w - write"
echo 
echo "the boot partition should be at least this big:"
du -sh "$DESTINATIONDIR"/boot
echo "and the rest:"
du -sh "$DESTINATIONDIR"/

fdisk "$MMCCARD"


echo "formatting $MMCCARD"
mkfs.vfat "$BOOTFS"
mkfs.ext4 "$ROOTFS"

echo 
mkdir -p "$MNTDIR"
mount -t ext4 "$ROOTFS" "$MNTDIR"
mkdir -p "$MNTDIR"/boot
mount -t vfat "$BOOTFS" "$MNTDIR"/boot

mount

cd "$MNTDIR"
( cd "$DESTINATIONDIR" ; tar cvf - * ) | ( tar xvf - )
mknod dev/console c 5 1
mknod dev/null c 1 3
mknod dev/tty0 c 4 0
mknod dev/tty1 c 4 1
mknod dev/tty2 c 4 2
mknod dev/ttyAMA0 c 204 64
chown -R root:root  .
cd ..


du -h "$MNTDIR"
umount "$BOOTFS"
umount "$ROOTFS"

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): finished $0"
