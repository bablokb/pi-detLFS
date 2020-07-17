#!/bin/sh
# $Id: 3c_morepackages.sh 78 2020-05-21 18:40:23Z dettus $

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
" ; date

export DETLFSROOT=`pwd`
export TOOLSDIR=`pwd`/Tools
export BUILDDIR=`pwd`/Build
export SOURCESDIR=`pwd`/Sources
export DOWNLOADSDIR=`pwd`/Downloads
export DESTINATIONDIR=`pwd`/Destination


export PATH=$TOOLSDIR/bin:$PATH
export CROSS_COMPILE=$TOOLSDIR/bin/arm-linux-gnueabihf-
export DESTDIR=$DESTINATIONDIR


echo ">>> ncurses" ; date
(
	wget --directory-prefix=$DOWNLOADSDIR -c ftp://ftp.gnu.org/gnu/ncurses/ncurses-6.1.tar.gz
	cd $SOURCESDIR ; tar xfz $DOWNLOADSDIR/ncurses-6.1.tar.gz ; mv ncurses-6.1 ncurses
	cd $BUILDDIR
	mkdir ncurses1 ; cd ncurses1
	$SOURCESDIR/ncurses/configure --prefix=/usr --target=arm-linux-gnueabihf --host=arm-linux-gnueabihf --without-sysmouse   --disable-ext-mouse  --enable-widec --with-shared --with-cxx-shared

	make  && make install -i
)


echo ">> building alsa-firmware"
(
	wget --directory-prefix=$DOWNLOADSDIR -c ftp://ftp.alsa-project.org/pub/firmware/alsa-firmware-1.0.29.tar.bz2
	cd $SOURCESDIR ; tar xvfj $DOWNLOADSDIR/alsa-firmware-1.0.29.tar.bz2 ; mv alsa-firmware-1.0.29/ alsa-firmware/

	cd $BUILDDIR
	mkdir alsa-firmware1 ; cd alsa-firmware1
	cp --reflink=auto -r  $SOURCESDIR/alsa-firmware .	# alsa firmware does not build like the others.
	cd alsa-firmware
	./configure --prefix=/usr --target=arm-linux-gnueabihf 
	make	 
	make install

)

echo ">>> building alsa-libs"
(
	wget --directory-prefix=$DOWNLOADSDIR -c ftp://ftp.alsa-project.org/pub/lib/alsa-lib-1.1.8.tar.bz2
	cd $SOURCESDIR ; tar xvfj $DOWNLOADSDIR/alsa-lib-1.1.8.tar.bz2 ; mv alsa-lib-1.1.8 alsa-lib
	cd $BUILDDIR
	mkdir alsa-lib1 ; cd alsa-lib1
	$SOURCESDIR/alsa-lib/configure --target=arm-linux-gnueabihf --prefix=/usr
	make 
	make install
)
####
####echo ">>> building wget"
####(
####	wget --directory-prefix=$DOWNLOADSDIR -c ftp://ftp.gnu.org/gnu/wget/wget-1.19.1.tar.xz
####	cd $SOURCESDIR ; tar xvfJ $DOWNLOADSDIR/wget-1.19.1.tar.xz ; mv wget-1.19.1/ wget
####
####	cd $BUILDDIR
####	mkdir wget1 ; cd wget1
####	cp --reflink=auto -r  $SOURCESDIR/wget .
####	cd wget
####	./configure --prefix=/usr --target=arm-linux-gnueabihf  --host=arm-linux-gnueabihf --disable-iri --without-zlib --without-libgnutls-prefix
####	make	 
####	make install
####)
####
####
du -sh $TOOLSDIR
du -sh $BUILDDIR
du -sh $DESTINATIONDIR

echo ">>> done" ; date

