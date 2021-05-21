#!/bin/sh

while [ ! -z $1 ]; do
    case $1 in 
        -d | delete)
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
                    sudo rm -rf reraid-test.cpio.gz
                    sudo rm -rf tmp
                    exit 0
                ;;
            esac
        ;;
    esac
done

./setupscripts/reraid-stage1.sh
./setupscripts/reraid-stage2.sh
./setupscripts/reraid-stage3.sh
./setupscripts/createmedia.sh -t optical