#!/usr/bin/bash

echo -e "\e[96m请使用root权限执行该脚本!"
echo "输入需要备份的mysql容器(docker-compose.yml文件中的容器名):"
read mysql_alias

if [ "$mysql_alias" == "" ]; then
    echo "alias is required"
    exit
fi

echo "database name:"
read database
if [ "$database" == "" ]; then
    echo "database is required"
    exit
fi

echo "mysql username:"
read mysql_user
if [ "$mysql_user" == "" ]; then
    echo "mysql_user is required"
    exit
fi

echo -n -e "mysql password:\n"
read -s mysql_password
if [ "$mysql_password" == "" ]; then
    echo "mysql_password is required"
    exit
fi

docker exec $(sudo docker inspect $mysql_alias | grep Id | awk '{print $2}' | sed 's/\("\|,\)//g') /usr/bin/mysqldump -u $mysql_user --password=$mysql_password --routines $database > $database.sql