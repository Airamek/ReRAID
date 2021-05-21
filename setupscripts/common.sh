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
