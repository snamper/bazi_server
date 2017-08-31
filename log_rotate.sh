#!/bin/bash
LOGS_PATH="/data/logs/baziWebServer/"
PID_PATH="/data/logs/baziWebServer/nginx.pid"
OLD_LOGS="/data/logs/baziWebServer/oldlogs"
KEEP_DAYS=7
date=$(date -d 'yesterday' +%Y-%m-%d)
echo $date
if [-r ${PID_PATH}; then
    mkdir -p  ${OLD_LOGS}
fi
for i in `ls ${LOGS_PATH}`;do
    mv ${LOGS_PATH}/$i  ${OLD_LOGS}/${i%%.*}_${date}.log
done
kill -USR1 $(cat ${PID_PATH})

find ${OLD_LOGS} -mtime +${KEEP_DAYS} -name "*.log" -exec rm -rf {} \;
