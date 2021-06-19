#!/bin/sh

# Prepares install media

START_PWD=$(pwd)
FILESYSTEM="$START_PWD/tmp/fs"

. $START_PWD/setupscripts/common.sh

while [ ! -z $1 ]; do
    case $1 in
        -t | --type)
            # The type of the device. Three types are supported: optical, flash, nodev
            DEVICE_TYPE=$2
            shift
            shift
        ;;
        -d | --device)
            # The block device to install Re:RAID on
            if beginswith / $2; then
                INSTALL_DEVICE=$2
            else
                INSTALL_DEVICE=$START_PWD/$2
            fi
            shift
            shift
        ;;
        -e | --essentials)
            if beginswith / "$2"; then
			    RERAID_ESSENTIALS_DIR=$2
            else
                RERAID_ESSENTIALS_DIR=$START_PWD/$2
            fi
            shift
            shift
        ;;
    esac
done 

# Default case
if [ "$RERAID_ESSENTIALS_DIR" = "" ]; then
    RERAID_ESSENTIALS_DIR=$START_PWD/reraid_essentials
fi

# Start creation of the device filesystem
if [ ! -d $FILESYSTEM ]; then
    mkdir -p $FILESYSTEM
    mkdir $FILESYSTEM/boot
fi
# Check for device
if [ -z "$DEVICE_TYPE" ]; then
    echo "You need to specify a device type. Two types are supported: optical, flash."
    exit 1
fi

if [ -z "$INSTALL_DEVICE" ] && [ "$DEVICE_TYPE" = "flash" ]; then
    echo "You need to specify a device to install to. (WARNING: The device will be ereased, and all content will be lost, unless Re:RAID is already installed)"
    exit 1
fi

case $DEVICE_TYPE in
    nodev) # do nothing
        exit 0
    ;;
    flash) #we use syslinux
        # Syslinux files
        mkdir $FILESYSTEM/boot/syslinux
        cp $RERAID_ESSENTIALS_DIR/syslinux/libcom32.c32 $FILESYSTEM/boot/syslinux
        cp $RERAID_ESSENTIALS_DIR/syslinux/libutil.c32 $FILESYSTEM/boot/syslinux
        cp $RERAID_ESSENTIALS_DIR/syslinux/menu.c32 $FILESYSTEM/boot/syslinux
        cp $RERAID_ESSENTIALS_DIR/syslinux/syslinux.cfg $FILESYSTEM/boot/syslinux

        # Check if device is mounted, then check for Re:RAID
        INSTALL_DEVICE_MOUNT=$(lsblk -l -o MOUNTPOINT $INSTALL_DEVICE | tail -1)
        if [ -f $INSTALL_DEVICE_MOUNT/reraid-version.txt ]; then

            INSTALLED_VERSION=$(cat $INSTALL_DEVICE_MOUNT/reraid-version.txt)
            RERAID_INSTALLED=1
            sudo umount $INSTALL_DEVICE_MOUNT
        else # Format the device
            sudo umount $INSTALL_DEVICE_MOUNT 
            lsblk $INSTALL_DEVICE
            echo "Your device needs to be formatted! Continue? [y/n]"
            read FORMAT_PROMPT
            if [ "$FORMAT_PROMPT" = "y" ]; then
                sudo parted -s $INSTALL_DEVICE mklabel msdos
                sudo parted -s -a optimal $INSTALL_DEVICE mkpart primary fat32 0% 100%
                sudo parted -s $INSTALL_DEVICE set 1 boot on
                sudo mkfs.vfat -F 32 -n RERAID "$INSTALL_DEVICE"1
                sudo dd bs=440 count=1 conv=notrunc if=$RERAID_ESSENTIALS_DIR/syslinux/mbr.bin of=$INSTALL_DEVICE
                sudo syslinux -d /boot/syslinux --install "$INSTALL_DEVICE"1 
            else
                exit 1
            fi
        fi
        #Mount the device
        if [ -d /mnt/reraid ]; then
                sudo umount /mnt/reraid
                # if [ ! $? -eq 0 ]; then
                #     exit $?
                # fi 
                sudo rm -rf /mnt/reraid
        fi
    ;;
    optical)
        mkdir $FILESYSTEM/boot/isolinux
        cp $RERAID_ESSENTIALS_DIR/isolinux/libcom32.c32 $FILESYSTEM/boot/isolinux
        cp $RERAID_ESSENTIALS_DIR/isolinux/libutil.c32 $FILESYSTEM/boot/isolinux
        cp $RERAID_ESSENTIALS_DIR/isolinux/menu.c32 $FILESYSTEM/boot/isolinux
        cp $RERAID_ESSENTIALS_DIR/isolinux/ldlinux.c32 $FILESYSTEM/boot/isolinux
        cp $RERAID_ESSENTIALS_DIR/isolinux/isolinux.bin $FILESYSTEM/boot/isolinux
        cp $RERAID_ESSENTIALS_DIR/syslinux/syslinux.cfg $FILESYSTEM/boot/isolinux/isolinux.cfg
    ;;
esac