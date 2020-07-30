#!/bin/sh
# $Id: 3b_ownpackages.sh 78 2020-05-21 18:40:23Z dettus $

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

 The purpose of this script is to provide an example of how to 
 compile your own packages.

 Hopefully, the previous scripts are finished at this point.
"

source vars.sh.inc

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): starting $0"

export PATH="$TOOLSDIR"/bin:$PATH
export CROSS_COMPILE="$TOOLSDIR"/bin/arm-linux-gnueabihf-
export DESTDIR="$DESTINATIONDIR"

echo ">>> building make" ; date
(
# you should have downloaded them already in script 0_getit.sh. otherwise, comment those two lines in
#	wget --directory-prefix=Downloads/ -c ftp://ftp.gnu.org/gnu/make/make-4.2.1.tar.gz
#	cd "$SOURCESDIR" ; tar xfz "$DOWNLOADSDIR"/make-4.2.1.tar.gz ; mv make-4.2.1 make

	cd "$BUILDDIR"
	mkdir make2 ; cd make2
#note that the prefix says /usr here
	"$SOURCESDIR"/make/configure --prefix=/usr --target=arm-linux-gnueabihf --host=arm-linux-gnueabihf --without-guile
	make 
# by setting the variable DESTDIR, the make install will use a different directoy as root dir
	export DESTDIR="$DESTINATIONDIR"
	make install
)

du -sh "$TOOLSDIR"
du -sh "$BUILDDIR"
du -sh "$DESTINATIONDIR"

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): finished $0"
