#!/bin/sh

INITRD_SOURCE="" 
OUTPUT_IMAGE=""
START_PWD=$(pwd)

#Function from stackoverflow
beginswith() 
{
    case $2 in
        "$1"*) 
            true
        ;;
        *) 
            false
        ;; 
    esac 
}

usage()
{
    echo "Usage: source-tree output-name"
}

#Handle arguments
if [ ! -z $1 ]; then
    case $1 in
        -h)
            usage
            exit 0
        ;;
        *)
            INITRD_SOURCE=$START_PWD/$1
        ;;
        /*)
            INITRD_SOURCE=$1
        ;;
	esac
fi
if [ ! -z $2 ]; then
    if beginswith / $2; then
        OUTPUT_IMAGE="$2".cpio.gz
    else
        OUTPUT_IMAGE=$START_PWD/"$2".cpio.gz
    fi
fi

#Default cases if not specified
if [ "$INITRD_SOURCE" = "" ]; then
    INITRD_SOURCE=$START_PWD/reraid
fi
if [ "$OUTPUT_IMAGE" = "" ]; then
    OUTPUT_IMAGE="$START_PWD"/reraid-test.cpio.gz
fi

echo "The initrd src dir is $INITRD_SOURCE"
echo "The output img is $OUTPUT_IMAGE"

# (cd $INITRD_SOURCE ; find . | cpio -o -H newc | gzip -9c > $START_PWD/$OUTPUT_IMAGE)

#This removes the output image if it already exists
if [ -f $OUTPUT_IMAGE ]; then
    rm "$OUTPUT_IMAGE"
    if [ "$?" -ne 0 ] # It checks if the remove succedded, and if not, it passes on it's exit code and exits
    then
        exit $?
    fi
fi 

#This creates the initrd, which is actually an initramfs
(cd $INITRD_SOURCE ; find . -print0 | cpio --null --create --verbose --format=newc | gzip --best > $OUTPUT_IMAGE)
