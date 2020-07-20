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

 This script just calls all the other 0*.sh scripts to download everything.
 If you only want to build parts of the system, run selected individual scripts.
" ;

pgmDir="${0%/*}"

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): starting $0"

"$pgmDir/0a_buildsystem.sh"
"$pgmDir/0b_kernel.sh"
"$pgmDir/0c_basesystem.sh"
"$pgmDir/0d_other.sh"

echo ">>> $(date +'%Y-%m-%d %H:%M:%S'): finished $0"
