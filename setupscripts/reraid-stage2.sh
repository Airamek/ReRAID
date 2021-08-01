#!/bin/sh

START_PWD=$(pwd)
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
        -t | --type)
            DEVICE_TYPE=$2
            shift
            shift
        ;;
    esac
done

if [ -z $DEVICE_TYPE ]; then
    echo "Device type needs to be specified"
    exit 1
fi
if [ -z "$RERAID_ESSENTIALS_DIR" ]; then
    RERAID_ESSENTIALS_DIR=$START_PWD/reraid_essentials
fi

if [ -z "$RERAID_KERNEL" ]; then
    RERAID_KERNEL=$START_PWD/tmp/$(ls $START_PWD/tmp | grep -i vmlinuz)
fi

if [ -z "$RERAID_DIR" ]; then 
    RERAID_DIR=$START_PWD/reraid
fi



echo "The kernel is $RERAID_KERNEL"

# /etc/fstab creation
if [ $DEVICE_TYPE = "optical" ]; then
    sudo tee -a $RERAID_DIR/etc/fstab <<EOF
    /dev/sr0    /boot       iso9660 ro,user,auto    0 0
EOF
fi

# Store Re:RAID version
touch $FILESYSTEM/reraid-release.txt
echo $RERAID_VERSION > $FILESYSTEM/reraid-release.txt

# The kernel
sudo cp $RERAID_KERNEL $FILESYSTEM/boot/vmlinuz

# Copy config dir
cp -r $RERAID_ESSENTIALS_DIR/config $FILESYSTEM/