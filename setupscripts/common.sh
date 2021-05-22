RERAID_VERSION="0.1"

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
    sudo tar -xpvJf "$1" -C $STAGEONE_OUTPUT_DIR/
	if [ -f $STAGEONE_OUTPUT_DIR/install/doinst.sh ]; then
		sudo chmod +x $STAGEONE_OUTPUT_DIR/install/doinst.sh
		(cd $STAGEONE_OUTPUT_DIR ; sudo install/doinst.sh)
		sudo rm -r $STAGEONE_OUTPUT_DIR/install
	fi
}