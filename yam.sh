#!/bin/bash

CONF=/yam/yam.conf
. $CONF

download () {
    if [[ $1 -eq 1 ]]; then
        LINK=$(awk -vLOOKUPVAL=$PACKAGE 'BEGIN{IGNORECASE=1};$1 == LOOKUPVAL {printf "%s\n", $3}' $PATH_TO_SOURCE)
        COMMIT=$(awk -vLOOKUPVAL=$PACKAGE 'BEGIN{IGNORECASE=1};$1 == LOOKUPVAL {printf "%s\n", $5}' $PATH_TO_SOURCE)
        curl -o $CACHE_DIR/$PACKAGE $LINK"zip/"$COMMIT
        setup " has been installed"
    elif [[ $1 -eq 2 ]]; then
        LINK=$(awk -vLOOKUPVAL=$PACKAGE 'BEGIN{IGNORECASE=1};$1 == LOOKUPVAL {printf "%s\n", $3}' $PATH_TO_INSTALLED)
        curl -o $CACHE_DIR/$PACKAGE.zip "https://codeload."$LINK"zip/master"
        setup " has been updated"
    elif [[ $1 -eq 3 ]]; then
        echo "This doesn't work yet"
    fi
}

setup () {
    LINE_NUM=$(awk -vLOOKUPVAL=$PACKAGE 'BEGIN{IGNORECASE=1} $1 == LOOKUPVAL {print NR}' $PATH_TO_INSTALLED)
    unzip $CACHE_DIR/$PACKAGE.zip -d /tmp/$PACKAGE
    cd /tmp/$PACKAGE/$PACKAGE-master
    ls
    . info.yam
    echo -ne "Do you want to edit, supply the config file or use the included configs? ${COLOR}[(E)DIT / (S)UPPLY / (D)EFAULT]${NC}\n"
    read ANSWER
    case "${ANSWER,,}" in
        edit | e) $EDITOR $CONFIG;;
        supply | s) echo -ne "supply the config file. ${COLOR}USE THE FULL PATH${NC}\n"; read PATH_TO_NEW_CONF; printf "\nCONFIG=$PATH_TO_NEW_CONF" >> info.yam;;
        DEFAULT | d) echo "skiping";;
        *) echo -n "Invalid option";;
    esac
    if [[ $LINE_NUM -eq "" ]]; then
        echo $NAME $VERSION $LINK $COMMIT $AUTHOR >> $PATH_TO_INSTALLED 
    else
        awk -vLINE=$LINE_NUM -vPACKAGE=$NAME -vVERSION=$VERSION -vLINK=$LINK -vCOMMIT=$COMMIT -vAUTHORNAME=$AUTHOR '{ if (NR == LINE) print PACKAGE " " VERSION " " LINK " " COMMIT " " AUTHORNAME; else print $0}' $PATH_TO_INSTALLED > /tmp/installed
        cp /tmp/installed $PATH_TO_INSTALLED
    fi
    bash $INSTALL_SCRIPT
    echo $PACKAGE $1
}

while getopts S:U:Q:FCh* OPTIONS # Argument shit, you can tell what everything does by looking at it
do
    case "${OPTIONS}" in
        S) SYNC=${OPTARG};;
        U) UPDATE=${OPTARG};;
        Q) awk -vLOOKUPVAL=${OPTARG} 'BEGIN{print "Source List"; IGNORECASE=1};(index($1, LOOKUPVAL) != 0) {printf "%-15s %-5s %s by %s\n",  $1, $2, $3, $5}' $PATH_TO_SOURCE ; awk -vLOOKUPVAL=${OPTARG} 'BEGIN{print "\nInstaled List"; IGNORECASE=1};(index($1, LOOKUPVAL) != 0) {printf "%-15s %-5s %s\n",  $1, $2, $3}' $PATH_TO_INSTALLED;;
        F) curl -o "$PATH_TO_SOURCE" $SOURCE; download 3 ;;
        C) cat $CONF;;
        h) printf -- "-S <package> ${COLOR}Downloads the selected package${NC} \n-U <package> ${COLOR}Updates the selected package to the lastest version${NC}\n-Q <package> ${COLOR}Querys the sources list for a package${NC}\n-F ${COLOR}Updates the sources list${NC}\n-C ${COLOR}Prints out the config file${NC}\n-h ${COLOR}Brings up this list${NC}\n" ;;
        *) echo -n "Invalid option";;
    esac
done

for PACKAGE in $SYNC; do
    download 1 $PACKAGE
done

for PACKAGE in $UPDATE; do
    download 2 $PACKAGE
done