#!/bin/sh

#Needed for relative paths
START_PWD=$(pwd)

. $START_PWD/setupscripts/common.sh

FILESYSTEM="$START_PWD/tmp/fs"

if [ ! -d $FILESYSTEM ]; then
    mkdir -p $FILESYSTEM
    mkdir $FILESYSTEM/boot
fi


#Handle the arguments
while [ ! -z $1 ]
do
    case $1 in
		-e | --essentials)
            if beginswith / "$2"; then
			    RERAID_ESSENTIALS_DIR=$2
            else
                RERAID_ESSENTIALS_DIR=$START_PWD/$2
            fi
            shift
            shift
		;;
        *)
            RERAID_DIR=$START_PWD/$1
        ;;
        /*)
            RERAID_DIR=$1
        ;;
	esac
done

#Default cases if not specified
if [ -z "$RERAID_ESSENTIALS_DIR" ]; then
    RERAID_ESSENTIALS_DIR=$START_PWD/reraid_essentials
fi
if [ -z "$RERAID_DIR" ]; then
    RERAID_DIR=$START_PWD/reraid
fi

#Check if output dir exists, if not, then create it
if [ ! -d $RERAID_DIR ]; then
    mkdir -p $RERAID_DIR
fi

echo "The essentials dir is $RERAID_ESSENTIALS_DIR"
echo "The output dir is $RERAID_DIR"

#install essential packages
for f in $RERAID_ESSENTIALS_DIR/essentialsv2/*
do
	installpackage $f
done
#install init system
for f in $RERAID_ESSENTIALS_DIR/init/*
do
    installpackage $f
done

#do the same for the kernel, and prepare it for the boot device
for f in $RERAID_ESSENTIALS_DIR/kernel/*
do
    installpackage $f
    if [ -f $RERAID_DIR/boot/vmlinuz ]; then
        cp $(readlink -f $RERAID_DIR/boot/vmlinuz) $START_PWD/tmp
    fi
done

# /mnt
sudo mkdir $RERAID_DIR/mnt/boot # The mount point of the bootdrive

# Write version info
sudo tee $RERAID_DIR/etc/reraid-release <<EOF
0.2-live
EOF
#temp test
sudo tee $RERAID_DIR/init<<EOF
/bin/sh
EOF

# rm "$RERAID_DIR"/etc/motd
