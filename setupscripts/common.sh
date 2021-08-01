RERAID_VERSION="0.4-live"
RERAID_LIVE=1

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

installpackage()
{
    sudo tar -xpvJf "$1" -C $RERAID_DIR/
	if [ -f $RERAID_DIR/install/doinst.sh ]; then
		sudo chmod +x $RERAID_DIR/install/doinst.sh
		(cd $RERAID_DIR ; sudo install/doinst.sh)
		sudo rm -r $RERAID_DIR/install
	fi
}