#!/bin/bash
# Copyright 2019-2020 A.D. DEBUG STATION
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#===================================#
# Update script for BuildTools v1.3 #
#===================================#

# Version of spigot generate https://www.spigotmc.org/wiki/buildtools/#versions
REV="1.15.2"

# Run BuildTools
# "force" argument or "START_BUILDTOOLS=2" will force BuildTools to run
# (Argument) ./update-bt.sh force
START_BUILDTOOLS=1

# (Optional) Call Script after running BuildTools
EXTEND_SCRIPT="extend-update-bt.sh"

cd $(dirname $0)

MAVEN_OPTS="-Xmx2G -Xms1G -XX:+UseG1GC"
BT_NAME="BuildTools"
BT_JAR_FILE="${BT_NAME}.jar"
BT_NUM_FILE="${BT_NAME}.number"
LOCAL_NUMBER=0
if [ -f "${BT_NUM_FILE}" ]; then
	LOCAL_NUMBER=$(cat "${BT_NUM_FILE}")
fi
CURRENT_NUMBER=1
CURRENT_NUMBER=$(curl --silent "https://hub.spigotmc.org/jenkins/job/BuildTools/lastStableBuild/buildNumber")
SG_REPO="craftbukkit"
LOCAL_CID_FILE="${SG_REPO}.commitid"

function event_log {
	local PID=${2:-$$}
	logger --id $PID --tag update-bt "${1}"
	return $?
}

event_log "Run it [LOCAL_NUMBER = ${LOCAL_NUMBER}, CURRENT_NUMBER = ${CURRENT_NUMBER}]"

if [ $LOCAL_NUMBER -lt $CURRENT_NUMBER ]; then
	event_log "Need to update BuildTools"
	if [ -f "${BT_JAR_FILE}" ]; then
		mv --verbose "${BT_JAR_FILE}" "${BT_JAR_FILE}.old"
	fi
	curl -o "${BT_JAR_FILE}" "https://hub.spigotmc.org/jenkins/job/BuildTools/lastStableBuild/artifact/target/BuildTools.jar" &
	PID=$!
	wait $PID
	event_log "Finish update BuildTools. Status: $?" $PID
	echo $CURRENT_NUMBER > "${BT_NUM_FILE}"
fi

RUN_BUILDTOOLS=$START_BUILDTOOLS

if [ "$1" = "force" ]; then
	RUN_BUILDTOOLS=2
fi

LOCAL_CID="0a"
if [ -f "$LOCAL_CID_FILE" ]; then
    LOCAL_CID=$(cat "${LOCAL_CID_FILE}")
fi

LAST_CID="0b"
if [ $RUN_BUILDTOOLS -gt 0 ]; then
    LAST_CID=$(curl --silent "https://hub.spigotmc.org/stash/rest/api/1.0/projects/SPIGOT/repos/${SG_REPO}/commits?limit=1" | jq -r '.values[0].id')
fi

if [ $RUN_BUILDTOOLS -eq 1 -a "$LOCAL_CID" = "$LAST_CID" ]; then
    RUN_BUILDTOOLS=0
fi

if [ $RUN_BUILDTOOLS -gt 0 ]; then
	event_log "Run BuildTools!"
	java -d64 ${MAVEN_OPTS} -jar "${BT_JAR_FILE}" --rev ${REV} &
	PID=$!
	wait $PID
	event_log "Finish build. Status: $?" $PID
	echo $LAST_CID > "${LOCAL_CID_FILE}"

	if [ -x "${EXTEND_SCRIPT}" ]; then
		source "${EXTEND_SCRIPT}"
		event_log "Extended script was run. Status: $?"
	fi
fi

exit 0
