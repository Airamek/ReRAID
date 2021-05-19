#!/bin/sh

if [ -z $1 ]
then
    echo "Usage: source-tree output-name"
    exit 1
fi

INITRD_SOURCE=$1 
OUTPUT_IMAGE=$2
START_PWD=$(pwd)

# (cd $INITRD_SOURCE ; find . | cpio -o -H newc | gzip -9c > $START_PWD/$OUTPUT_IMAGE)

rm "$START_PWD"/"$OUTPUT_IMAGE".cpio.gz
if [ "$?" -ne 0 ]
then
	exit $?
fi

(cd $INITRD_SOURCE ; find . -print0 | cpio --null --create --verbose --format=newc | gzip --best > $START_PWD/$OUTPUT_IMAGE.cpio.gz)
