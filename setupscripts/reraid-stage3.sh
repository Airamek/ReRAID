#!/bin/sh

START_PWD=$(pwd)

. $START_PWD/setupscripts/common.sh

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
        OUTPUT_IMAGE="$2".cpio.xz
    else
        OUTPUT_IMAGE=$START_PWD/"$2".cpio.xz
    fi
fi

#Default cases if not specified
if [ -z "$INITRD_SOURCE" ]; then
    INITRD_SOURCE=$START_PWD/reraid
fi
if [ -z "$OUTPUT_IMAGE" ]; then
    OUTPUT_IMAGE="$START_PWD"/reraid-test.cpio.xz
fi

echo "The initrd src dir is $INITRD_SOURCE"
echo "The output img is $OUTPUT_IMAGE"

# (cd $INITRD_SOURCE ; find . | cpio -o -H newc | gzip -9c > $START_PWD/$OUTPUT_IMAGE)

#This removes the output image if it already exists
if [ -f $OUTPUT_IMAGE ]; then
    sudo rm "$OUTPUT_IMAGE"
    if [ "$?" -ne 0 ] # It checks if the remove succedded, and if not, it passes on it's exit code and exits
    then
        exit $?
    fi
fi 

#This creates the initrd, which is actually an initramfs
#(cd $INITRD_SOURCE ; find . -print0 | sudo cpio --null --create --verbose --format=newc | gzip --best > $OUTPUT_IMAGE)
(cd $INITRD_SOURCE ; find . -print0 | sudo cpio --null --create --verbose --format=newc | xz --format=lzma -v -z --fast -c -T0 > $OUTPUT_IMAGE)

sudo cp $OUTPUT_IMAGE $START_PWD/tmp/fs/