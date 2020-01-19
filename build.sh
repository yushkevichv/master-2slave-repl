#!/bin/bash

docker-compose down
rm -rf ./master/data/*
rm -rf ./slave/data/*
docker-compose build
docker-compose up -d

until docker exec mysql_master  mysql -uroot -ppwd -e ";"
do
    echo "Waiting for mysql_master database connection..."
    sleep 4
done

echo "connection to master is ok"

priv_stmt='GRANT REPLICATION SLAVE ON *.* TO "slave_user"@"%" IDENTIFIED BY "slave_pwd"; FLUSH PRIVILEGES;'
docker exec mysql_master mysql -uroot -ppwd -e "$priv_stmt"

until docker exec mysql_slave mysql -uroot -ppwd -e ";"
do
    echo "Waiting for mysql_slave database connection..."
    sleep 4
done

echo "connection to slave is ok"

until docker exec mysql_slave2 mysql -uroot -ppwd -e ";"
do
    echo "Waiting for mysql_slave2 database connection..."
    sleep 4
done

echo "connection to slave2 is ok"


docker-ip() {
    docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$@"
}

MS_STATUS=`docker exec mysql_master  mysql -uroot -ppwd -e "SHOW MASTER STATUS"`
CURRENT_LOG=`echo $MS_STATUS | awk '{print $6}'`
CURRENT_POS=`echo $MS_STATUS | awk '{print $7}'`

start_slave_stmt="CHANGE MASTER TO MASTER_HOST='$(docker-ip mysql_master)',MASTER_USER='slave_user',MASTER_PASSWORD='slave_pwd',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"

docker exec mysql_slave mysql -uroot -ppwd -e "$start_slave_stmt"
docker exec mysql_slave mysql -uroot -ppwd -e 'SHOW SLAVE STATUS \G'

echo "and for second slave"

MS_STATUS=`docker exec mysql_master  mysql -uroot -ppwd -e "SHOW MASTER STATUS"`
CURRENT_LOG=`echo $MS_STATUS | awk '{print $6}'`
CURRENT_POS=`echo $MS_STATUS | awk '{print $7}'`

start_slave_stmt="CHANGE MASTER TO MASTER_HOST='$(docker-ip mysql_master)',MASTER_USER='slave_user',MASTER_PASSWORD='slave_pwd',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"

docker exec mysql_slave2 mysql -uroot -ppwd -e "$start_slave_stmt"
docker exec mysql_slave2 mysql -uroot -ppwd -e 'SHOW SLAVE STATUS \G'
