#!/usr/bin/bash

if [ "$1" ]; then
    mysql_alias="$1"
    database="$2"
    backup_file="$3"
    mysql_user="$4"
    mysql_password="$5"
else
    echo -e "\e[96m请使用root权限执行该脚本!"
    echo "输入需要还原的mysql容器名称(docker-compose.yml文件中的容器名):"
    read mysql_alias

    if [ "$mysql_alias" == "" ]; then
        echo "容器名不能为空"
        exit
    fi

    echo "待还原数据库名称:"
    read database
    if [ "$database" == "" ]; then
        echo "数据库不能为空"
        exit
    fi

    echo "备份文件名称(绝对路径):"
    read backup_file
    if [ "$backup_file" == "" ]; then
        echo "备份文件不能为空"
        exit
    fi

    echo "数据库用户:"
    read mysql_user
    if [ "$mysql_user" == "" ]; then
        echo "数据库用户不能为空"
        exit
    fi

    echo -n -e "数据库密码:\n"
    read -s mysql_password
    if [ "$mysql_password" == "" ]; then
        echo "数据库密码不能为空"
        exit
    fi
fi

cat $backup_file | docker exec -i $(sudo docker inspect $mysql_alias | grep Id | awk '{print $2}' | sed 's/\("\|,\)//g') /usr/bin/mysql -u $mysql_user --password=$mysql_password $database