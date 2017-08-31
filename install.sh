#!/bin/bash
OPENRESTY_PATH="/usr/local/openresty"
LOGS_PATH="/data/logs/baziWebServer/"
PREFIX="/data/baziWebServer"
rm -rf ${PREFIX}
mkdir -p ${PREFIX}

cp -r ./app ${PREFIX}/
cp -r ./common ${PREFIX}/
cp -r ./conf ${PREFIX}/
cp -r ./ngx_conf ${PREFIX}/
cp -r ./onlineTest ${PREFIX}/
cp log_rotate.sh ${PREFIX}/

chown -R  daemon:daemon ${PREFIX}/

if [ ! -d ${LOGS_PATH} ]; then
    mkdir -p ${LOGS_PATH}
fi
dt=$(date +'%F_%T')
cp ${OPENRESTY_PATH}/nginx/conf/nginx.conf ${OPENRESTY_PATH}/nginx/conf/nginx.conf.bak.$dt
cp ${PREFIX}/ngx_conf/nginx.conf ${OPENRESTY_PATH}/nginx/conf

chown -R root:daemon ${OPENRESTY_PATH}/nginx/conf/nginx.conf
cp -r ${PREFIX}/common/lib/* ${OPENRESTY_PATH}/lualib/
chown -R  root:daemon ${OPENRESTY_PATH}/lualib/

