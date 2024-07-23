#!/bin/bash

#Imports Config File
. Ubuntu.conf

if [[ $ENABLE_UPDATES == true ]]; then
    echo "Installing Updates"
    apt-get update -y
    apt-get upgrade -y
fi