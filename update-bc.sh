#!/bin/bash
# Copyright 2019 A.D. DEBUG STATION
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#===================================#
# Update script for BungeeCord v1.2 #
#===================================#

cd `dirname $0`

BC_JARFILE="BungeeCord.jar"
BC_NUMFILE="BungeeCord.number"
LOCAL_NUMBER=0
CURRENT_NUMBER=$(curl --silent https://ci.md-5.net/job/BungeeCord/lastStableBuild/buildNumber)

if [ -e $BC_NUMFILE ]; then
	LOCAL_NUMBER=$(cat $BC_NUMFILE)
fi

if [ $LOCAL_NUMBER -lt $CURRENT_NUMBER ]; then
	echo ${CURRENT_NUMBER} > ${BC_NUMFILE}
	if [ -e $BC_JARFILE ]; then
		mv --verbose ${BC_JARFILE} ${BC_JARFILE}.old
	fi
	curl --silent -o ${BC_JARFILE} https://ci.md-5.net/job/BungeeCord/lastStableBuild/artifact/bootstrap/target/BungeeCord.jar
fi

exit 0
