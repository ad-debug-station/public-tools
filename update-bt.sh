#!/bin/bash
# Copyright 2019 A.D. DEBUG STATION
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

cd `dirname $0`

BT_NAME="BuildTools"
BT_NUMBER_FILENAME="${BT_NAME}.number"
BT_APP_FILENAME="${BT_NAME}.jar"
REV="1.13.2"
#SOURCE="${PWD}/spigot-${REV}.jar"
MAVEN_OPTS="-Xmx2G -Xms1G -XX:+UseG1GC"

if [ ! -e $BT_NUMBER_FILENAME ]; then
	echo 0 > $BT_NUMBER_FILENAME
	chmod 0600 $BT_NUMBER_FILENAME
fi

LOCAL_NUMBER=$(cat $BT_NUMBER_FILENAME)
CURRENT_NUMBER=$(curl --silent https://hub.spigotmc.org/jenkins/job/BuildTools/lastStableBuild/api/json | jq '.number')

if [ $LOCAL_NUMBER -lt $CURRENT_NUMBER ]; then
	echo "BuildTools Updating..."
	echo $CURRENT_NUMBER > $BT_NUMBER_FILENAME
	mv ${BT_APP_FILENAME} ${BT_APP_FILENAME}.old
	curl --silent -o $BT_APP_FILENAME https://hub.spigotmc.org/jenkins/job/BuildTools/lastStableBuild/artifact/target/BuildTools.jar
fi

SPIGOTMC_REPO="craftbukkit"
LOCAL_COMMIT_ID_FILENAME="${SPIGOTMC_REPO}.commitid"
if [ ! -e $LOCAL_COMMIT_ID_FILENAME ]; then
	echo 0 > $LOCAL_COMMIT_ID_FILENAME
	chmod 0600 $LOCAL_COMMIT_ID_FILENAME
fi

LOCAL_COMMIT_ID=$(cat $LOCAL_COMMIT_ID_FILENAME)
LAST_COMMIT_ID=$(curl --silent https://hub.spigotmc.org/stash/rest/api/1.0/projects/SPIGOT/repos/${SPIGOTMC_REPO}/commits?limit=2 | jq -r '.values[0].id')

if [ $LOCAL_COMMIT_ID != $LAST_COMMIT_ID ]; then
	echo "need update..."
	echo $LAST_COMMIT_ID > $LOCAL_COMMIT_ID_FILENAME
	java -d64 -Xmx2G -Xms1G -XX:+UseG1GC -jar $BT_APP_FILENAME --rev $REV
fi

echo "Good bye!!"
exit
