#!/bin/bash

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

START_PWD=$(pwd)

RERAID_IMAGE=""
RERAID_KERNEL=""
SYSLINUX_DIR=""
INSTALL_DEVICE=""

while [ ! -z $1 ]; do 
    case $1 in 
        -i | --image)
            # The Re:RAID image for install
            if beginswith / $2; then
                RERAID_IMAGE=$2
            else
                RERAID_IMAGE=$START_PWD/$2
            fi
            shift
            shift
        ;;
        -k | --kernel)
            # The kernel to install
            if beginswith / $2; then
                RERAID_KERNEL=$2
            else
                RERAID_KERNEL=$START_PWD/$2
            fi
            shift
            shift
        ;;
        -s | -syslinux)
            # A folder with the syslinux essentials
            if beginswith / $2; then
                SYSLINUX_DIR=$2
            else
                SYSLINUX_DIR=$START_PWD/$2
            fi
            shift
            shift
        ;;
        -d | --device)
            # The block device to install Re:RAID on
            # A folder with the syslinux essentials
            if beginswith / $2; then
                INSTALL_DEVICE=$2
            else
                INSTALL_DEVICE=$START_PWD/$2
            fi
            shift
            shift
        ;;
    esac
done

# Default options
if [ $RERAID_IMAGE="" ]; then
    RERAID_IMAGE=$START_PWD/reraid-test.cpio.gz
fi

if [ $RERAID_KERNEL="" ]; then
    RERAID_KERNEL=$(ls $START_PWD/tmp | grep -i vmlinuz)
fi


echo "The Re:RAID image is $RERAID_IMAGE"
echo "The kernel is $RERAID_KERNEL"
echo "The syslinux dir is $SYSLINUX_DIR"
echo "The device is $INSTALL_DEVICE"