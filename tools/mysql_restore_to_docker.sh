#!/usr/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS/Debian/Ubuntu
#	Author: Lestat
#   Email: lestat@lestat.me
#	Blog: https://blog.lestat.me/
#=================================================


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

container_id=$(docker inspect $mysql_alias --format="{{.Id}}")

cat $backup_file | docker exec -i $container_id /usr/bin/mysql -u $mysql_user --password=$mysql_password $database