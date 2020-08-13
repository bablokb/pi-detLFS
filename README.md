Simple LFS Scripts for the Raspberry Pi
=======================================

LFS (Linux from Scratch) tries to setup a Linux-system from scratch, i.e.
build it from source code. The scripts of this projekt are a sample implementation
for a minimal Linux-system for the Raspberry Pi.

This project is a fork of the orignal detLFS-project from
[http://www.dettus.net/detLFS/](http://www.dettus.net/detLFS/). You should fetch
the "Getting-Started"-guide from there since it contains very important
information.

The `detLFS`-directory of this repository contains my modified versions
of the original files. The file `bsd_twoclause.txt` has been moved as file
`LICENSE` to the top-level directory.


Overview
--------

The main goal of the modifications where:

  - download only what is necessary
  - fix multiple bugs
  - speedup builds on multi-core systems
  - support arbitrary hardware and kernel-versions
  - split scripts to allow selective use (e.g. only for a kernel cross-compile)

The recommandation is to build an run the scripts from a filesystem on a SSD
formatted with XFS or BTRFS. The latter two filesystems support copy-on-write
thus saving disk-io while copying the source-code around.


Choosing the kernel-version
---------------------------

This fork does not supply a specific kernel-configuration anymore. Instead
you have three options to supply the kernel-version:

  1. put a kernel-config file `.config` in the root-directory of the scripts
     (see below)
  2. set the branch manually: `export BRANCH=rpi-4.19.y`. This must be
     an existing branch in the Github kernel-repository of the Foundation
  3. use the current default branch (hardcoded in the script `0b_kernel.sh`).

To extract the kernel configuration from a running kernel, you need two commands:

    sudo modprobe configs
    zcat /proc/config.gz > .config

Then copy the newly created file `.config` to the directory with the
detLFS-scripts.

If you `export MENUCONFIG=x` (the value does not matter as long as it
not empty) prior to running the scripts, the kernel-build will call
`make menuconfig` and let you change all settings interactivly.


Selecting the target hardware
-----------------------------

Use

    export target=pi0

to select the pi0-hardware-family. Replace /pi0/ with one of
/pi1/, /p2/, /p3/, /p4/, /cm1/ or /cm3/. Note that there are currently
only four hardware-families, so p1 is a synonym for p0 and cm1 (and
likewise for the other families).


Modifications
-------------

**Note that this is still work in progress!**

  - minor cosmetic changes, like
    - quoting of all variables
    - adding datetime to messages
    - removing some unnecessary cd-commands (unix-users usually stay at $HOME)
  - all: use `cp --reflink=auto` to minimize IO with BTRFS/XFS
  - `0_getit.sh`: only download sources not already downloaded
  - `0_getit.sh`: download a single kernel-branch based on the
    version as described above instead of the whole kernel-repository
  - `0_getit.sh`: split up into sub-scripts `0?_*.sh` (useful if you only
    want to download/update parts of the system). The script is still there
    but just calls all the sub-scripts
  - download all firmware files, not only `bootcode.bin` and `start.elf`
  - all: add `-j`-parameter to (some) make commands. This speeds up the build
    dramatically on multicore systems
  - `1_buildtools.sh`: build with armv6-architecture to support all pi-models
  - `2_basesystem.sh`: bugfix (overlays were not copied)
  - `2_basesystem.sh`: split up into sub-scripts `2?_*.sh` (useful if you only
    want to build parts of the system). The script is still there
    but just calls all the sub-scripts.
  - '3a_comppackages.sh': move glibc-installation to `2b_base.sh`, since glibc is
    not optional
  - `4_mkimg.sh`: (new) creates an installable image (similar to the official images)
  - `skeldir/root`: add german keymap (load with `loadkeys < de.bmap`)
