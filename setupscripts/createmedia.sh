#!/bin/sh

START_PWD=$(pwd)

. $START_PWD/setupscripts/common.sh

DEVICE_TYPE=""
FILESYSTEM="$START_PWD/tmp/fs"

while [ ! -z $1 ]; do
    case $1 in
        -t | --type)
            # The type of the device. Two types are supported: optical, flash
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

# Check for device
if [ "$DEVICE_TYPE" = "" ]; then
    echo "You need to specify a device type. Two types are supported: optical, flash."
    exit 1
fi

if [ "$INSTALL_DEVICE" = "" ] && [ "$DEVICE_TYPE" = "flash" ]; then
    echo "You need to specify a device to install to. (WARNING: The device will be ereased, and all content will be lost, unless Re:RAID is already installed)"
    exit 1
fi

if [ "$DEVICE_TYPE" = "flash" ]; then #we use syslinux
    # Syslinux files
    mkdir $FILESYSTEM/boot/syslinux
    cp $RERAID_ESSENTIALS_DIR/syslinux/libcom32.c32 $FILESYSTEM/boot/syslinux
    cp $RERAID_ESSENTIALS_DIR/syslinux/libutil.c32 $FILESYSTEM/boot/syslinux
    cp $RERAID_ESSENTIALS_DIR/syslinux/menu.c32 $FILESYSTEM/boot/syslinux
    cp $RERAID_ESSENTIALS_DIR/syslinux/syslinux.cfg $FILESYSTEM/boot/syslinux

    # Check if device is mounted, then check for Re:RAID
    INSTALL_DEVICE_MOUNT=$(lsblk -l -o MOUNTPOINT $INSTALL_DEVICE | tail -1)
    INSTALLED_VERSION=$(cat $INSTALL_DEVICE_MOUNT/reraid-version.txt)
    echo $INSTALLED_VERSION
elif [ "$DEVICE_TYPE" = "optical" ]; then
    mkdir $FILESYSTEM/boot/isolinux
    cp $RERAID_ESSENTIALS_DIR/isolinux/libcom32.c32 $FILESYSTEM/boot/isolinux
    cp $RERAID_ESSENTIALS_DIR/isolinux/libutil.c32 $FILESYSTEM/boot/isolinux
    cp $RERAID_ESSENTIALS_DIR/isolinux/menu.c32 $FILESYSTEM/boot/isolinux
    cp $RERAID_ESSENTIALS_DIR/isolinux/ldlinux.c32 $FILESYSTEM/boot/isolinux
    cp $RERAID_ESSENTIALS_DIR/isolinux/isolinux.bin $FILESYSTEM/boot/isolinux
    cp $RERAID_ESSENTIALS_DIR/syslinux/syslinux.cfg $FILESYSTEM/boot/isolinux/isolinux.cfg

    # Create .iso file
    mkisofs -o reraid.iso \
    -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat -R \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    $FILESYSTEM
fi