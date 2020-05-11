#!/bin/bash

# Script for logging some system statistics
#
# This script should be located at user's home direccotry
# Also should be added to crontab with crontab -e:
# */2 * * * * mkdir -p $HOME/memory; vmstat -S K -w | tail -n 1 | awk '{print "Free: "$4"K, Buff: "$5"K, Cache: "$6"K"}' >> $HOME/memory/stat 2>&1
# */5 * * * * tar -czf $HOME/arch/stat.tar.gz $HOME/memory/* $HOME/logs/* 2>/dev/null
# */2 * * * * $HOME/script_4.12.3.sh
#

LOG_DIR="${HOME}/logs"
CONTXT_LOG="${LOG_DIR}/contxt.log"
LA_LOG="${LOG_DIR}/la.log"
PAGES_LOG="${LOG_DIR}/pages.log"
PART_LOG="${LOG_DIR}/parts.log"
DATE_FMT="%Y-%m-%d %H:%M:%S"
VMS_DELAY=3
VMS_NUM=11

timestamp() {
    date +"${DATE_FMT}"

    return
}

if ! [[ -e "${LOG_DIR}" ]]; then mkdir $LOG_DIR; fi

timestamp >> $PART_LOG
while read -r part; do
    vmstat -p "/dev/${part}" >> $PART_LOG 2>&1
done < <(lsblk -ln | grep part | awk '{print $1}')

timestamp >> $LA_LOG
cat /proc/loadavg | awk '{print "LA for 15 min: "$2}' >> $LA_LOG

timestamp >> $PAGES_LOG
vmstat -s | grep pages >> $PAGES_LOG

timestamp >> $CONTXT_LOG
i=0
sum=0
while read -r cs; do
    ((sum+=cs))
    ((i++))
done < <(vmstat $VMS_DELAY $VMS_NUM | awk '{print $12}' | tail -n +3)
echo "Average num of context switches is $((sum/i))" >> $CONTXT_LOG
