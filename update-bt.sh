#!/bin/bash
# Copyright 2019 A.D. DEBUG STATION
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#===================================#
# Update script for BuildTools v1.2 #
#===================================#

cd `dirname $0`

REV="1.13.2"
MAVEN_OPTS="-Xmx2G -Xms1G -XX:+UseG1GC"
START_BUILDTOOLS=1

BT_NAME="BuildTools"
BT_JARFILE="${BT_NAME}.jar"
BT_NUMFILE="${BT_NAME}.number"
LOCAL_NUMBER=0
CURRENT_NUMBER=$(curl --silent https://hub.spigotmc.org/jenkins/job/BuildTools/lastStableBuild/buildNumber)

if [ -e $BT_NUMFILE ]; then
	LOCAL_NUMBER=$(cat $BT_NUMFILE)
fi

SG_REPO="craftbukkit"
LOCAL_CID_FILE="${SG_REPO}.commitid"
LOCAL_CID="0"
LAST_CID=$(curl --silent https://hub.spigotmc.org/stash/rest/api/1.0/projects/SPIGOT/repos/${SG_REPO}/commits?limit=1 | jq -r '.values[0].id')

if [ -e $LOCAL_CID_FILE ]; then
	LOCAL_CID=$(cat $LOCAL_CID_FILE)
fi

EXTEND_SCRIPT="extend-update-bt.sh"

function event_log {
	local PID=${2}
	if [ ! ${2} ]; then
		PID=$$
	fi

	logger --id $PID --tag update-bt "${1}"
	return $?
}

event_log "I run it. [LOCAL_NUMBER = ${LOCAL_NUMBER}, CURRENT_NUMBER = ${CURRENT_NUMBER}]"

if [ $LOCAL_NUMBER -lt $CURRENT_NUMBER ]; then
	event_log "Need to update BuildTools"
	echo ${CURRENT_NUMBER} > ${BT_NUMFILE}
	if [ -e $BT_JARFILE ]; then
		mv ${BT_JARFILE} ${BT_JARFILE}.old
	fi
	curl --silent -o ${BT_JARFILE} https://hub.spigotmc.org/jenkins/job/BuildTools/lastStableBuild/artifact/target/BuildTools.jar &
	PID=$!
	wait $PID
	event_log "Finish update BuildTools. Status: $?" $PID
fi

if [ $START_BUILDTOOLS -a $LOCAL_CID != $LAST_CID ]; then
	event_log "Need to update Bukkit/Spigot. Start BuildTools!"
	echo ${LAST_CID} > ${LOCAL_CID_FILE}
	java -d64 ${MAVEN_OPTS} -jar ${BT_JARFILE} --rev ${REV} &
	PID=$!
	wait $PID
	event_log "Finish build. Status: $?" $PID
	if [ -x $EXTEND_SCRIPT ]; then
		source ${EXTEND_SCRIPT}
		event_log "Extended script was executed. Status: $?"
	fi
fi

event_log "I end."
exit 0
