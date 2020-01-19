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


docker-ip() {
    docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$@"
}

MS_STATUS=`docker exec mysql_master  mysql -uroot -ppwd -e "SHOW MASTER STATUS"`
echo $MS_STATUS
echo $MS_STATUS | awk '{print $6}'
CURRENT_LOG=`echo $MS_STATUS | awk '{print $6}'`
CURRENT_POS=`echo $MS_STATUS | awk '{print $7}'`

start_slave_stmt="CHANGE MASTER TO MASTER_HOST='$(docker-ip mysql_master)',MASTER_USER='mydb_slave_user',MASTER_PASSWORD='mydb_slave_pwd',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_slave_cmd='export MYSQL_PWD=111; mysql -u root -e "'
start_slave_cmd+="$start_slave_stmt"
start_slave_cmd+='"'

docker exec mysql_slave mysql -uroot -ppwd -e "$start_slave_stmt"
docker exec mysql_slave mysql -uroot -ppwd -e 'SHOW SLAVE STATUS \G'