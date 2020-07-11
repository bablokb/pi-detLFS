
       -----         -----         
      /     \       /     \       /
     /       \     /       \     /
-----         -----         -----
     \       /     \       /     \
      \     /       \     /       \
       -----         ----- detLFS  -
      /     \       /     \       /
     /       \     /       \     /
-----         -----         -----
http://www.dettus.net/detLFS/detLFS_0.07.tar.bz2


0. Introduction
===============
The goal of det_lfs is to provide a selection of minimalistic shell scripts,
which are easy to understand, but also capable of setting up a full blown
Linux environment on the Raspberry Pi 2.

Those scripts are numbered, so that one knows how to run them in which order.

Temporary folders will be given an Upper case name, to spot them easily.

USE AT YOUR OWN RISK!!!!

Just run (in that order)
 sh 0_getit.sh
 sh 1_buildtools.sh
 sh 2_basesystem.sh

 sh 3a_comppackages.sh (optional, but it will give you a gcc on the raspberry)
 sh 3b_ownpackages.sh (optional)
 sh 3c_morepackags.sh (even more optional)

edit 4_mksdcard.sh and run it as root.
If you want to personalize your system BEFORE running the scripts, please 
read on.


1. Updating the system
======================
If you think a package is rather old or too unstable, just edit 0_getit.sh and 
enter the new version number right there. You will not have to change it 
anywhere else.

2. Changing the boot logo
=========================
When booting the system, you will notice the hexagon pattern. If you want to 
change it, overwrite logo/mylogo.xpm. You can replace it with any 80x80 pixel
file, as long as it has no more than 224 colors.

3. Changing the root password
=============================
The default root password is root. If you want to change it, edit the file
/etc/skeldir/shadow, and replace the hash with something you can create with
perl's script() function, for example:

 % perl -e ’printf("%s\n", crypt("abcde","12"));’
 12yYR42qdsGFc

4. Changing the hostname
========================
The hostname 'detlfs' is stored in skeldir/etc/hostname.

5. Changing the login prompt
============================
The login prompt is stored in skeldir/etc/issue

6. Running specific programs at system init (sysinit)
=====================================================
Just add them to skeldir/etc/rcS

7. Extending the base system
============================
Just look at 3b_ownpackages.sh, understand it, and just add whatever you need.
Do the same with 3c_morepackages.sh. It helps! :)



Be sure to get the latest version of the scripts and the documentation from
http://www.dettus.net/detLFS/

*** ENJOY ***
$Id: readme.txt 57 2020-04-20 06:44:10Z dettus $
