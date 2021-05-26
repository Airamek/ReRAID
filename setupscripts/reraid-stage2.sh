#!/bin/sh

#Function from stackoverflow



START_PWD=$(pwd)

RERAID_ESSENTIALS_DIR=""
RERAID_IMAGE=""
RERAID_KERNEL=""
SYSLINUX_DIR=""
INSTALL_DEVICE=""
FILESYSTEM="$START_PWD/tmp/fs"

. $START_PWD/setupscripts/common.sh

while [ ! -z $1 ]; do 
    case $1 in 
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
		-e | --essentials)
            # The Re:RAID essentials dir (the install files)
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

if [ "$RERAID_ESSENTIALS_DIR" = "" ]; then
    RERAID_ESSENTIALS_DIR=$START_PWD/reraid_essentials
fi

if [ "$RERAID_KERNEL" = "" ]; then
    RERAID_KERNEL=$START_PWD/tmp/$(ls $START_PWD/tmp | grep -i vmlinuz)
fi

if [ "$SYSLINUX_DIR" = "" ]; then 
    SYSLINUX_DIR=$RERAID_ESSENTIALS_DIR/syslinux
fi



echo "The Re:RAID image is $RERAID_IMAGE"
echo "The kernel is $RERAID_KERNEL"
echo "The syslinux dir is $SYSLINUX_DIR"


# Start creation of the device filesystem
if [ ! -d $FILESYSTEM ]; then
    mkdir -p $FILESYSTEM
    mkdir $FILESYSTEM/boot
fi

# Store Re:RAID version
touch $FILESYSTEM/reraid-version.txt
echo $RERAID_VERSION > $FILESYSTEM/reraid-version.txt

# The kernel
cp $RERAID_KERNEL $FILESYSTEM/boot/vmlinuz

