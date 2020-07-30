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
#ANY DIRECT, INDIRECT, INCIUDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# this file is included by other scripts

[ -z "$target" ] && target="pi3"

target="${target:2:1}"   # strip first two characters

if [ "$target" -lt 2 ]; then
  export KERNEL="kernel"
  export def_config="bcmrpi_defconfig"
elif [ "$target" -lt 4 ]; then
  export KERNEL="kernel7"
  export def_config="bcm2709_defconfig"
else
  export KERNEL="kernel7l"
  export def_config="bcm2711_defconfig"
fi

export DETLFSROOT=`pwd`
export TOOLSDIR=`pwd`/Tools
export BUILDDIR=`pwd`/Build
export SOURCESDIR=`pwd`/Sources
export DOWNLOADSDIR=`pwd`/Downloads
export DESTINATIONDIR=`pwd`/Destination

[ -z "$NUM_CPUS" ] && NUM_CPUS=$(nproc)
