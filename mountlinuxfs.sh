#!/bin/sh

if [ -z $1 ] 
then
	mount --bind /dev reraid/dev
	mount --bind /proc reraid/proc
	mount --bind /sys reraid/sys
fi
if [ "$1" = "-u" ]
then
	umount reraid/dev reraid/sys reraid/proc
fi
