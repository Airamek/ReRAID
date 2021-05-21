#!/bin/sh

#Needed for relative paths
START_PWD=$(pwd)

. $START_PWD/setupscripts/common.sh

#make tmp dir
if [ -d $START_PWD/tmp ]; then
    rm -rf $START_PWD/tmp/*
else
    mkdir -p $START_PWD/tmp
fi

RERAID_ESSENTIALS_DIR=""
STAGEONE_OUTPUT_DIR=""

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
            STAGEONE_OUTPUT_DIR=$START_PWD/$1
        ;;
        /*)
            STAGEONE_OUTPUT_DIR=$1
        ;;
	esac
done

#Default cases if not specified
if [ "$RERAID_ESSENTIALS_DIR" = "" ]; then
    RERAID_ESSENTIALS_DIR=$START_PWD/reraid_essentials
fi
if [ "$STAGEONE_OUTPUT_DIR" = "" ]; then
    STAGEONE_OUTPUT_DIR=$START_PWD/reraid
fi

#Check if output dir exists, if not, then create it
if [ ! -d $STAGEONE_OUTPUT_DIR ]; then
    mkdir -p $STAGEONE_OUTPUT_DIR
fi

echo "The essentials dir is $RERAID_ESSENTIALS_DIR"
echo "The output dir is $STAGEONE_OUTPUT_DIR"

#install essential packages
for f in $RERAID_ESSENTIALS_DIR/essentialsv2/*
do
	sudo tar -xpvJf "$f" -C $STAGEONE_OUTPUT_DIR/
	if [ -f $STAGEONE_OUTPUT_DIR/install/doinst.sh ]; then
		sudo chmod +x $STAGEONE_OUTPUT_DIR/install/doinst.sh
		(cd $STAGEONE_OUTPUT_DIR ; sudo install/doinst.sh)
		sudo rm -r $STAGEONE_OUTPUT_DIR/install
	fi
done
#install init system
# for f in $RERAID_ESSENTIALS_DIR/init/*
# do
# 	tar -xpvJf "$f" -C $STAGEONE_OUTPUT_DIR/
# 	if [ -f $STAGEONE_OUTPUT_DIR/install/doinst.sh ]; then
# 		chmod +x $STAGEONE_OUTPUT_DIR/install/doinst.sh
# 		(cd $STAGEONE_OUTPUT_DIR ; install/doinst.sh)
# 		rm -r $STAGEONE_OUTPUT_DIR/install
# 	fi
# done

#do the same for the kernel, and prepare it for the boot device
for f in $RERAID_ESSENTIALS_DIR/kernel/*
do
	sudo tar -xpvJf "$f" -C $STAGEONE_OUTPUT_DIR/
	if [ -f $STAGEONE_OUTPUT_DIR/install/doinst.sh ]; then
		sudo chmod +x $STAGEONE_OUTPUT_DIR/install/doinst.sh
		(cd $STAGEONE_OUTPUT_DIR ; sudo install/doinst.sh)
		sudo rm -r $STAGEONE_OUTPUT_DIR/install
	fi
    if [ -f $STAGEONE_OUTPUT_DIR/boot/vmlinuz ]; then
        cp $(readlink -f $STAGEONE_OUTPUT_DIR/boot/vmlinuz) $START_PWD/tmp
    fi
done


sudo tee "$STAGEONE_OUTPUT_DIR"/init <<EOF 
#!/bin/sh

echo "Welcome to Re:RAID"
/sbin/init
EOF

# rm "$STAGEONE_OUTPUT_DIR"/etc/motd
