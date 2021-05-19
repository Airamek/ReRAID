#!/bin/sh

#From stackoverflow
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

#Needed for relative paths
START_PWD=$(pwd)

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

#install the slackware packages from essentialsv2
#need to make separate packages in dir to make more understandable file structure
for f in $RERAID_ESSENTIALS_DIR/essentialsv2/*
do
	tar -xpvJf "$f" -C $STAGEONE_OUTPUT_DIR/
	if test -f $STAGEONE_OUTPUT_DIR/install/doinst.sh; then
		chmod +x $STAGEONE_OUTPUT_DIR/install/doinst.sh
		(cd $STAGEONE_OUTPUT_DIR ; install/doinst.sh)
		rm -r $STAGEONE_OUTPUT_DIR/install
	fi
done


cat <<EOF > "$STAGEONE_OUTPUT_DIR"/init
#!/bin/sh

echo "Welcome to Re:RAID"
/sbin/init
EOF

# rm "$STAGEONE_OUTPUT_DIR"/etc/motd
