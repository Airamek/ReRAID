#!/bin/sh

START_PWD=$(pwd)
. $START_PWD/setupscripts/common.sh

help()
{
    echo "create-reraid"
    echo "      -h | --help        displays help page"
    echo "      -e | --essentials  specifies the folder for install files, default is reraid_essentials"
    echo "      -t | --type        the type of media Re:RAID will be installed on"
    echo "                         supported types are: optical, flash, nodev"
    echo "                         nodev is for development purposes"
    echo "      -d | --device      specifies the device it will be installed on"
    echo "      -s | --stage       what stages should be processed"
    echo "                         stages are: 1,2,3,4"
    echo "      --delete           deletes all work files"
}

while [ ! -z $1 ]; do
    case $1 in 
        --delete)
        # Delete all work files
            case $2 in
                3)
                    sudo rm -rf tmp/fs
                    exit 0
                ;;
                2)
                    sudo rm -rf tmp/fs
                    rm -rf reraid-test.cpio.gz
                    exit 0
                ;;
                1 | *)
                    sudo rm -rf reraid/
                    sudo rm -f reraid-test.cpio.gz
                    sudo rm -rf tmp
                    sudo rm -f reraid.iso
                    exit 0
                ;;
            esac
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
        -s | --stage)
            STAGES_TO_PROCESS=$2
            shift
            shift
        ;;
    esac
done

export DEVICE_TYPE
export INSTALL_DEVICE
export RERAID_ESSENTIALS_DIR

echo $STAGES_TO_PROCESS

case $STAGES_TO_PROCESS in
    "3")
        ./setupscripts/reraid-stage1.sh || exit $? 
        ./setupscripts/reraid-stage2.sh || exit $?
        ./setupscripts/reraid-stage3.sh || exit $?
        exit 0
    ;;
    "2")
        ./setupscripts/reraid-stage1.sh || exit $?
        ./setupscripts/reraid-stage2.sh || exit $?
        exit 0
    ;;
    "1")
        ./setupscripts/reraid-stage1.sh || exit $?
        exit 0
    ;;
    *)
        ./setupscripts/prepare-device.sh || exit $?
        ./setupscripts/reraid-stage1.sh || exit $?
        ./setupscripts/reraid-stage2.sh || exit $?
        ./setupscripts/reraid-stage3.sh || exit $?
        ./setupscripts/reraid-stage4-finish.sh || exit $?
        exit 0
    ;;
esac
