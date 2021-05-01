#!/bin/sh
if [ -z $1 ]; then
	RERAID_DIR="$PWD"
	ESSENTIALS_DIR=$PWD/../essentialsv2
	echo "reRAID dir is $RERAID_DIR"
else
	RERAID_DIR=$1
	echo "reRAID dir is $RERAID_DIR"
	ESSENTIALS_DIR=$PWD/essentialsv2
fi

for f in $ESSENTIALS_DIR/*
do
	tar -xpvJf "$f" -C $RERAID_DIR/
	if test -f $RERAID_DIR/install/doinst.sh; then
		chmod +x $RERAID_DIR/install/doinst.sh
		(cd $RERAID_DIR ; install/doinst.sh)
		rm -r $RERAID_DIR/install
	fi
done
