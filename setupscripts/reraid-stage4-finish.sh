#!/bin/sh

START_PWD=$(pwd)
FILESYSTEM="$START_PWD/tmp/fs"
. $START_PWD/setupscripts/common.sh

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


if [ "$DEVICE_TYPE" = "flash" ]; then #we use syslinux
    # Check if device is mounted, then check for Re:RAID
    INSTALL_DEVICE_MOUNT=$(lsblk -l -o MOUNTPOINT $INSTALL_DEVICE | tail -1)
    if [ -f $INSTALL_DEVICE_MOUNT/reraid-version.txt ]; then

        INSTALLED_VERSION=$(cat $INSTALL_DEVICE_MOUNT/reraid-version.txt)
        RERAID_INSTALLED=1
        sudo umount $INSTALL_DEVICE_MOUNT
    fi
    sudo mkdir /mnt/reraid
    sudo mount "$INSTALL_DEVICE"1 /mnt/reraid -o umask=000

    # Copy the files
    sudo cp -r "$FILESYSTEM"/* /mnt/reraid
    sudo umount /mnt/reraid
elif [ "$DEVICE_TYPE" = "optical" ]; then
    # Create .iso file
    mkisofs -o reraid.iso \
    -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat -R \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    $FILESYSTEM
fi

echo "Re:RAID linux installed successfully!"