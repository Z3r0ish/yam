#!/bin/bash

CONF=/home/victor/yam/yam.conf
. $CONF

download () {
    if [[ $1 -eq 1 ]]; then
        LINK=$(awk -vLOOKUPVAL=$PACKAGE '$1 == LOOKUPVAL {printf "%s\n", $3}' $PATH_TO_SOURCE)
        COMMIT=$(awk -vLOOKUPVAL=$PACKAGE '$1 == LOOKUPVAL {printf "%s\n", $5}' $PATH_TO_SOURCE)
        curl -o $CACHE_DIR/$PACKAGE $LINK"zip/"$COMMIT
        echo $PACKAGE Installed
    elif [[ $1 -eq 2 ]]; then
        echo Updated
    elif [[ $1 -eq 3 ]]; then
        echo Your system has been updated
    fi
}


while getopts S:U:Q:FCh OPTIONS # Argument shit, you can tell what everything does by looking at it
do
    case "${OPTIONS}" in
        S) SYNC=${OPTARG};;
        U) UPDATE=${OPTARG};;
        Q) awk -vLOOKUPVAL=${OPTARG} '(index($1, LOOKUPVAL) != 0) {printf "%-10s %-5s %s\n", $1, $2, $3}' $PATH_TO_SOURCE ;;
        F) curl -o "$PATH_TO_SOURCE" $SOURCE; download 3 ;;
        C) cat $CONF; echo;;
        h) printf -- "-S <package> ${COLOR}Downloads the selected package${NC} \n-U <package> ${COLOR}Updates the selected package to the lastest version${NC}\n-Q <package> ${COLOR}Querys the sources list for a package${NC}\n-F ${COLOR}Updates the sources list${NC}\n-C ${COLOR}Prints out the config file${NC}\n-h ${COLOR}Brings up this list${NC}\n" ;;
    esac
done

for PACKAGE in $SYNC; do
    download 1 $PACKAGE
done

for PACKAGE in $UPDATE; do
    download 2 $PACKAGE
done