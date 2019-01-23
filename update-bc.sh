#!/bin/sh
cd `dirname $0`

LONGNAME="$PWD/BungeeCord.jar"

if [ -e $LONGNAME ]; then
  mv --verbose $LONGNAME $LONGNAME.old
fi

wget -O $LONGNAME https://ci.md-5.net/job/BungeeCord/lastStableBuild/artifact/bootstrap/target/BungeeCord.jar
