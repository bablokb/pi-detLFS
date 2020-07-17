#!/bin/sh
# $Id: 3d_repeater.sh 78 2020-05-21 18:40:23Z dettus $

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
----         -----         -----
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


mkdir -p $BUILDDIR
mkdir -p $SOURCESDIR
mkdir -p $DOWNLOADSDIR
mkdir -p $DESTINATIONDIR


export DESTDIR=$DESTINATIONDIR		## this line will be read by the "make install"
echo ">>> wireless-tools" ; date
(
	wget --directory-prefix=$DOWNLOADSDIR -c https://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/wireless_tools.29.tar.gz
	cd $SOURCESDIR ; tar xfz $DOWNLOADSDIR/wireless_tools.29.tar.gz ; mv wireless_tools.29 wireless_tools
	cd $BUILDDIR
	mkdir wireless-tools1 ; cd wireless-tools1
	cp --reflink=auto -r $SOURCESDIR/wireless_tools/* .
	cat Makefile | sed -e "s?^CC.*=.*gcc?CC="$CROSS_COMPILE"gcc?g" | sed -e "s?PREFIX.*=.*local?PREFIX="$DESTINATIONDIR"/usr/?g" >/tmp/tmp1.txt 
	cp --reflink=auto /tmp/tmp1.txt Makefile
	make && make install
)
echo ">>> libopenssl"; date
(
	wget --directory-prefix=$DOWNLOADSDIR -c https://www.openssl.org/source/openssl-1.1.1g.tar.gz
	cd $SOURCESDIR ; tar xfz $DOWNLOADSDIR/openssl-1.1.1g.tar.gz ; mv openssl-1.1.1g openssl
	cd $BUILDDIR
	mkdir openssl1 ; cd openssl1
	cp --reflink=auto -r $SOURCESDIR/openssl/* .
	./Configure gcc --prefix=/usr 
	cat Makefile | sed -e "s?^DESTDIR=.*\$?DESTDIR="$DESTDIR"?g" >/tmp/tmp2.txt ; cp --reflink=auto /tmp/tmp2.txt Makefile
	make
	make install
)
echo ">>> libnl" ; date
(
	wget --directory-prefix=$DOWNLOADSDIR -c https://www.infradead.org/~tgr/libnl/files/libnl-3.2.25.tar.gz
	cd $SOURCESDIR ; tar xfz $DOWNLOADSDIR/libnl-3.2.25.tar.gz ; mv libnl-3.2.25 libnl
	cd $BUILDDIR
	mkdir libnl1 ; cd libnl1
	export CPPFLAGS="-DNAME_MAX=1024"
	export SYSROOT=$DESTINATIONDIR
	export LDFLAGS="-L"$DESTINATIONDIR"/lib -L"$DESTINATIONDIR"/usr/lib --sysroot="$DESTINATIONDIR
	export DESTDIR=$DESTINATIONDIR
	$SOURCESDIR/libnl/configure --host=arm-linux-gnueabihf --prefix=/usr --with-sysroot=$DESTINATIONDIR --with-pkgconfigdir=$DESTINATIONDIR/usr/lib/ --with-gnu-ld=yes --disable-silent-rules --with-pic=yes
	make && make install
)

echo ">>> wpa-supplicant" ; date
(
	export PKG_CONFIG_PATH=$DESTINATIONDIR/usr/lib/pkgconfig
	export CC=$CROSS_COMPILE"gcc"
	wget --directory-prefix=$DOWNLOADSDIR -c https://w1.fi/releases/wpa_supplicant-2.9.tar.gz
	cd $SOURCESDIR ; tar xfz $DOWNLOADSDIR/wpa_supplicant-2.9.tar.gz  ; mv wpa_supplicant-2.9 wpa_supplicant
	cd $BUILDDIR
	mkdir wpa_supplicant1 ; cd wpa_supplicant1
	cp --reflink=auto -r $SOURCESDIR/wpa_supplicant/* .
	cd wpa_supplicant
	cat defconfig | sed -e "s/CONFIG_CTRL_IFACE_DBUS_NEW=y/#CONFIG_CTRL_IFACE_DBUS_NEW=y/g" - | sed -e "s/CONFIG_CTRL_IFACE_DBUS_INTRO=y/#CONFIG_CTRL_IFACE_DBUS_INTRO=y/g" - >.config
	export LDFLAGS="-L"$DESTINATIONDIR"/lib -L"$DESTINATIONDIR"/usr/lib -L"$DESTINATIONDIR"/usr/lib --sysroot="$DESTINATIONDIR
	export EXTRA_CFLAGS="-I"$DESTINATIONDIR"/include -I"$DESTINATIONDIR"/usr/include -I"$DESTINATIONDIR"/usr/include -I"$DESTINATIONDIR"/usr/include/libnl3/"
	export    EXTRALIBS="-L"$DESTINATIONDIR"/lib -L"$DESTINATIONDIR"/usr/lib"
	export DESTDIR=$DESTINATIONDIR
	export LIBDIR=$DESTINATIONDIR/usr/lib
	export INCDIR=$DESTINATIONDIR/usr/include
	export BINDIR=$DESTINATIONDIR/usr/sbin
	make 
	export LIBDIR=/usr/lib
	export INCDIR=/usr/include
	export BINDIR=/usr/sbin
	make install
)

#echo ">>> libz" ; date
#(
#	export PKG_CONFIG_PATH=$DESTINATIONDIR/usr/lib/pkgconfig
#	export CC=$CROSS_COMPILE"gcc"
#	export CROSS_PREFIX=$CROSS_COMPILE
#	wget --directory-prefix=$DOWNLOADSDIR -c 	https://www.zlib.net/zlib-1.2.11.tar.gz
#	cd $SOURCESDIR ; tar xfz $DOWNLOADSDIR/zlib-1.2.11.tar.gz ; mv zlib-1.2.11 zlib
#	cd $BUILDDIR
#	mkdir zlib1 ; cd zlib1
#	$SOURCESDIR/zlib/configure  --prefix=/usr 	
#	make
#	make install
#
#)
#echo ">>> openssh" ; date
#(
#	export PKG_CONFIG_PATH=$DESTINATIONDIR/usr/lib/pkgconfig
#	export CC=$CROSS_COMPILE"gcc"
#	wget --directory-prefix=$DOWNLOADSDIR -c https://ftp.fau.de/pub/OpenBSD/OpenSSH/portable/openssh-8.2p1.tar.gz
#	cd $SOURCESDIR ; tar xfz $DOWNLOADSDIR/openssh-8.2p1.tar.gz ; mv openssh-8.2p1 openssh
#	cd $BUILDDIR
#	mkdir openssh1; cd openssh1
#	export SYSROOT=$DESTINATIONDIR
#	export EXTRA_LDFLAGS="-L"$DESTINATIONDIR"/lib -L"$DESTINATIONDIR"/usr/lib -L"$DESTINATIONDIR"/usr/lib --sysroot="$DESTINATIONDIR
#	export EXTRA_CFLAGS="-I"$DESTINATIONDIR"/include -I"$DESTINATIONDIR"/usr/include -I"$DESTINATIONDIR"/usr/include -I"$DESTINATIONDIR"/usr/include/libnl3/"
#	$SOURCESDIR/openssh/configure --host=arm-linux-gnueabihf --prefix=/usr 	 --with-zlib=$DESTINATIONDIR/usr/ --with-ssl-dir=$DESTINATION/usr/ --with-cflags='$EXTRA_CFLAGS' --with-ldflags='$EXTRA_LDFLAGS'
#	make
#	make install
#
#)
echo ">>> libmnl" ; date
(
	wget --directory-prefix=$DOWNLOADSDIR -c https://netfilter.org/projects/libmnl/files/libmnl-1.0.4.tar.bz2
	cd $SOURCESDIR ; tar xfj $DOWNLOADSDIR/libmnl-1.0.4.tar.bz2 ; mv libmnl-1.0.4 libmnl
	cd $BUILDDIR
	mkdir libmnl1 ; cd libmnl1
	$SOURCESDIR/libmnl/configure --prefix=/usr --target=arm-linux-gnueabihf --host=arm-linux-gnueabihf
	make && make install	
)

echo ">>> libnftnl" ; date
(
	export PKG_CONFIG_PATH=$DESTINATIONDIR/usr/lib/pkgconfig
	export LIBMNL_CFLAGS="-I"$DESTINATIONDIR"/usr/include"
	export LIBMNL_LIBS="-L"$DESTINATIONDIR"/usr/lib -L"$DESTINATIONDIR"/lib -L"$DESTINATIONDIR"/usr/lib -L"$DESTINATIONDIR"/usr/lib --sysroot="$DESTINATIONDIR
	wget --directory-prefix=$DOWNLOADSDIR -c https://netfilter.org/projects/libnftnl/files/libnftnl-1.1.6.tar.bz2
	cd $SOURCESDIR ; tar xfj $DOWNLOADSDIR/libnftnl-1.1.6.tar.bz2 ; mv libnftnl-1.1.6 libnftnl
	cd $BUILDDIR
	mkdir libnftnl1 ; cd libnftnl1
	$SOURCESDIR/libnftnl/configure --prefix=/usr --target=arm-linux-gnueabihf --host=arm-linux-gnueabihf --with-sysroot=$DESTINATIONDIR --with-pkgconfigdir=$PKG_CONFIG_PATH
	make && make install	
)

echo ">>> iptables" ; date
(
	export PKG_CONFIG_PATH=$DESTINATIONDIR/usr/lib/pkgconfig
	wget --directory-prefix=$DOWNLOADSDIR -c ftp://ftp.netfilter.org/pub/iptables/iptables-1.8.4.tar.bz2
	cd $SOURCESDIR ; tar xfj $DOWNLOADSDIR/iptables-1.8.4.tar.bz2 ; mv iptables-1.8.4 iptables
	cd $BUILDDIR 
	export CC=$CROSS_COMPILE"gcc --sysroot="$DESTINATIONDIR
	mkdir iptables1 ; cd iptables1
	export CPPFLAGS="-I"$DESTINATIONDIR"/usr/include"
##	export LIBS="-L"$DESTINATIONDIR"/lib -L"$DESTINATIONDIR"/usr/lib"
	export LT_SYS_LIBRARY_PATH=$DESTINATIONDIR"/lib:"$DESTINATIONDIR"/usr/lib"
	export LD_LIBRARY_PATH=$DESTINATIONDIR"/lib:"$DESTINATIONDIR"/usr/lib"
	export DT_RPATH=$DESTINATIONDIR"/lib:"$DESTINATIONDIR"/usr/lib"
	export SYSROOT=$DESTINATIONDIR
	$SOURCESDIR/iptables/configure --prefix=/usr --target=arm-linux-gnueabihf --host=arm-linux-gnueabihf --with-sysroot=$DESTINATIONDIR --with-pkgconfigdir=$PKG_CONFIG_PATH  --with-kernel=$BUILDDIR/linux/ --with-gnu-ld --disable-silent-rules
	make && make install
)
du -sh $TOOLSDIR
du -sh $BUILDDIR
du -sh $DESTINATIONDIR

echo ">>> done" ; date

