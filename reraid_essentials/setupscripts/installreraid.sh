#!/bin/sh

RERAID_DIR=""
RERAID_ESSENTIALS_DIR=""

for arg in "$@"
do
	case $arg in
		-e | --essentials)
			RERAID_ESSENTIALS_DIR=$ARG
			echo "The essentials dir is $RERAID_ESSENTIALS_DIR"
		;;
	esac
done	

exit 0

if [ -z $1 ]; then
	RERAID_DIR="$PWD/reraid"
	ESSENTIALS_DIR=$PWD/../essentialsv2
	echo "reRAID dir is $RERAID_DIR"
else
	RERAID_DIR=$1
	echo "reRAID dir is $RERAID_DIR"
	ESSENTIALS_DIR=$PWD/essentialsv2
fi

for f in $ESSENTIALS_DIR/*
do
	tar -xpvJf "$f" -C $RERAID_DIR/
	if test -f $RERAID_DIR/install/doinst.sh; then
		chmod +x $RERAID_DIR/install/doinst.sh
		(cd $RERAID_DIR ; install/doinst.sh)
		rm -r $RERAID_DIR/install
	fi
done

mkdir $RERAID_DIR/mnt/slack

cat <<EOF > "$RERAID_DIR"/init
#!/bin/sh

# Mount the /proc and /sys filesystems.
#mount -t proc none /proc
#mount -t sysfs none /sys

# Do your stuff here.
#echo "This script just mounts and boots the rootfs, nothing else!"

# Mount the root filesystem.
#mount -o ro /dev/sda1 /mnt/root

# Clean up.
#umount /proc
#umount /sys

# Boot the real thing.
# exec switch_root /mnt/root /sbin/init

echo "Welcome to re:RAID"
/sbin/init
EOF

rm "$RERAID_DIR"/etc/motd
