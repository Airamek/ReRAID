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

if [ -z "$RERAID_ESSENTIALS_DIR" ]; then
    RERAID_ESSENTIALS_DIR=$START_PWD/reraid_essentials
fi

case $DEVICE_TYPE in
    flash)
        mkdir $FILESYSTEM/syslinux
        cp $RERAID_ESSENTIALS_DIR/syslinux/libcom32.c32 $FILESYSTEM/syslinux
        cp $RERAID_ESSENTIALS_DIR/syslinux/libutil.c32 $FILESYSTEM/syslinux
        cp $RERAID_ESSENTIALS_DIR/syslinux/menu.c32 $FILESYSTEM/syslinux
        cp $RERAID_ESSENTIALS_DIR/syslinux/syslinux.cfg $FILESYSTEM/syslinux

        if [ ! "$(ls /dev/disk/by-label | grep RERAID)" = "RERAID" ]; then
            echo "You need to give your device the LABEL \"RERAID\" to use it with this installer!"
            exit 1
        else 
            INSTALL_DEVICE=$(readlink -f /dev/disk/by-label/RERAID)
        fi
        
        # Check if device is mounted, then unmount it
        INSTALL_DEVICE_MOUNT=$(lsblk -l -o MOUNTPOINT $INSTALL_DEVICE | tail -1)
        [ -z $INSTALL_DEVICE_MOUNT ] && sudo umount $INSTALL_DEVICE_MOUNT

        # Set new mountpoint
        INSTALL_DEVICE_MOUNT=/mnt/reraid

        # Install syslinux
        #sudo dd bs=440 count=1 conv=notrunc if=$RERAID_ESSENTIALS_DIR/syslinux/mbr.bin of=/dev/$(lsblk -no pkname $INSTALL_DEVICE)
        #sudo syslinux -d /syslinux --install $INSTALL_DEVICE

        [ -d $INSTALL_DEVICE_MOUNT ] || sudo mkdir $INSTALL_DEVICE_MOUNT
        mountpoint $INSTALL_DEVICE_MOUNT && sudo umount $INSTALL_DEVICE_MOUNT
        sudo mount $INSTALL_DEVICE /mnt/reraid -o umask=000
        mountpoint $INSTALL_DEVICE_MOUNT || exit 1
        # Copy the files
        sudo cp -r $FILESYSTEM/* $INSTALL_DEVICE_MOUNT/
        echo "Files copied successfully!"
        sudo umount $INSTALL_DEVICE
        sudo rm -r /mnt/reraid
    ;;
    devboot)
        mkdir $FILESYSTEM/syslinux
        cp $RERAID_ESSENTIALS_DIR/syslinux/libcom32.c32 $FILESYSTEM/syslinux
        cp $RERAID_ESSENTIALS_DIR/syslinux/libutil.c32 $FILESYSTEM/syslinux
        cp $RERAID_ESSENTIALS_DIR/syslinux/menu.c32 $FILESYSTEM/syslinux
        cp $RERAID_ESSENTIALS_DIR/syslinux/syslinux.cfg $FILESYSTEM/syslinux
        # Create 512mb reraid-live virtual hdd
        if [ ! -f $START_PWD/reraid-live.img ]; then
            [ -d /mnt/reraid ] || sudo mkdir /mnt/reraid
            dd if=/dev/zero bs=4k count=262144 of=$START_PWD/reraid-live.img
            parted -s $START_PWD/reraid-live.img mklabel msdos
            parted -s -a none $START_PWD/reraid-live.img mkpart primary fat32 0% 100%
            parted -s $START_PWD/reraid-live.img set 1 boot on

            # Set up a loopdevice to format partition
            sudo losetup -d /dev/loop0
            sudo losetup -P /dev/loop0 $START_PWD/reraid-live.img || exit 1
            sudo mkfs.vfat -a -F 32 -n RERAID /dev/loop0p1
            NEED_TO_INSTALL_SYSLINUX=1
        fi

        [ -d /mnt/reraid ] || sudo mkdir /mnt/reraid
        sudo losetup -d /dev/loop0
        sudo losetup -P /dev/loop0 $START_PWD/reraid-live.img || exit 1
        sudo mount -t vfat /dev/loop0p1 /mnt/reraid || exit 1
        
        #Copy the files
        sudo cp -r $FILESYSTEM/* /mnt/reraid
        echo "Files copied successfully!"
        sudo umount /dev/loop0p1 || exit 1
        sudo rm -r /mnt/reraid

        # Install syslinux 
        if [ $NEED_TO_INSTALL_SYSLINUX ]; then
            sudo dd bs=440 count=1 conv=notrunc if=$RERAID_ESSENTIALS_DIR/syslinux/mbr.bin of=/dev/loop0
            sudo syslinux -d /boot/syslinux --install /dev/loop0p1
        fi
        sudo losetup -d /dev/loop0
    ;;
    nodev)

    ;;
    *)
        echo "You need to specify a device type. Supported types are: devboot, flash, nodev, test-fullins."
        exit 1
    ;;
esac
echo "Re:RAID linux installed successfully!"