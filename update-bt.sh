#!/bin/bash
# Copyright 2019-2020 A.D. DEBUG STATION
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#===================================#
# Update script for BuildTools v1.4 #
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
BT_LOCAL_NUMBER=0
if [ -f "${BT_NUM_FILE}" ]; then
	BT_LOCAL_NUMBER=$(cat "${BT_NUM_FILE}")
fi
BT_LAST_NUMBER=1
BT_LAST_NUMBER=$(curl --silent "https://hub.spigotmc.org/jenkins/job/BuildTools/lastStableBuild/buildNumber")
SG_LOCAL_NUMBER_FILE="spigot.number"

function event_log {
	local PSID=${2:-$$}
	logger --id $PSID --tag update-bt "${1}"
	return $?
}

event_log "Run it [BT_LOCAL_NUMBER = ${BT_LOCAL_NUMBER}, BT_LAST_NUMBER = ${BT_LAST_NUMBER}]"

if [ $BT_LOCAL_NUMBER -lt $BT_LAST_NUMBER ]; then
	event_log "Need to update BuildTools"
	if [ -f "${BT_JAR_FILE}" ]; then
		mv --verbose "${BT_JAR_FILE}" "${BT_JAR_FILE}.old"
	fi
	curl -o "${BT_JAR_FILE}" "https://hub.spigotmc.org/jenkins/job/BuildTools/lastStableBuild/artifact/target/BuildTools.jar" &
	PSID=$!
	wait $PSID
	event_log "Finish update BuildTools. Status: $?" $PSID
	echo $BT_LAST_NUMBER > "${BT_NUM_FILE}"
fi

RUN_BUILDTOOLS=$START_BUILDTOOLS

if [ "$1" = "force" ]; then
	RUN_BUILDTOOLS=2
fi

SG_LOCAL_NUMBER=0
if [ -f "$SG_LOCAL_NUMBER_FILE" ]; then
    SG_LOCAL_NUMBER=$(cat "${SG_LOCAL_NUMBER_FILE}")
fi

SG_LAST_NUMBER=1
if [ $RUN_BUILDTOOLS -gt 0 ]; then
    SG_LAST_NUMBER=$(curl --silent "https://hub.spigotmc.org/versions/${REV}.json" | jq -r '.name')
fi

if [ $RUN_BUILDTOOLS -eq 1 -a $SG_LOCAL_NUMBER -eq $SG_LAST_NUMBER ]; then
    RUN_BUILDTOOLS=0
fi

if [ $RUN_BUILDTOOLS -gt 0 ]; then
	event_log "Run BuildTools!"
	java -d64 ${MAVEN_OPTS} -jar "${BT_JAR_FILE}" --rev ${REV} &
	PSID=$!
	wait $PSID
	event_log "Finish build. Status: $?" $PSID
	echo $SG_LAST_NUMBER > "${SG_LOCAL_NUMBER_FILE}"

	if [ -x "${EXTEND_SCRIPT}" ]; then
		source "${EXTEND_SCRIPT}"
		event_log "Extended script was run. Status: $?"
	fi
fi

exit 0
