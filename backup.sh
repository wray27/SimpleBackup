#!/bin/sh

set -e

function date_to_unixtime()
{
    if [[ "$OSTYPE" == "darwin"*  ]]; then
        UNIXDATE=$(date -j -u -f "%Y-%m-%d" "$1" "+%s")
    else
        UNIXDATE=$(date -d "$1" +"%s")
    fi
    echo $UNIXDATE
}

function create_backup()
{
    FILENAME="$(date +%Y-%m-%d).tar.gz"
    tar -czvf "$FILENAME" "$SRC_PATH" 2>&1 | tee -a "$LOGFILE"
    mv "$FILENAME" "$DEST_PATH/$FILENAME"
    echo "${GREEN}+${NC} $FILENAME created successfully" 2>1 | tee -a "$LOGFILE"
}

function delete_old_backups()
{
    for FILE in $DEST_PATH/*
    do
        FILENAME=$(basename $FILE)
        FILEDATE=${FILENAME:0:10}
        UNIXDATE=$(date_to_unixtime $FILEDATE)
        (( COND=CURRENT_UNIXTIME - (KEEP_N_DAYS * 86400) ))
        if [ $UNIXDATE -le $COND ];
        then
            rm -f $FILE
            echo "${RED}-${NC} $FILENAME removed" 2>1 | tee -a "$LOGFILE"
        fi
    done
}

RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m"
LOGFILE="/var/log/backups.log"
CURRENT_UNIXTIME=$(date +"%s")
SRC_PATH=$1
DEST_PATH=$2
KEEP_N_DAYS=5

create_backup
delete_old_backups