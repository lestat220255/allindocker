#!/usr/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/java/jre/bin:~/bin
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
    backups_dir="$3"
    mysql_user="$4"
    mysql_password="$5"
    delete_offset="$6"

    if [ "$backups_dir" == "" ]; then
        mkdir -p /data/allindocker_backup/
        backups_dir="/data/allindocker_backup/"
    fi
    
    if [ "$delete_offset" == "" ]; then
            delete_offset="0"
    fi
else
    echo -e "\e[96m请使用root权限执行该脚本!"
    echo "输入需要备份的mysql容器名称(docker-compose.yml文件中的容器名):"
    read mysql_alias

    if [ "$mysql_alias" == "" ]; then
        echo -e "\e[91m容器名不能为空"
        exit
    fi

    echo "待备份数据库名称:"
    read database
    if [ "$database" == "" ]; then
        echo -e "\e[91m数据库不能为空"
        exit
    fi

    echo "备份目录(默认:/data/allindocker_backup):"
    read backups_dir
    if [ "$backups_dir" == "" ]; then
        mkdir -p /data/allindocker_backup/
        backups_dir="/data/allindocker_backup/"
    fi

    echo "数据库用户:"
    read mysql_user
    if [ "$mysql_user" == "" ]; then
        echo -e "\e[91m数据库用户不能为空"
        exit
    fi

    echo -n -e "数据库密码:\n"
    read -s mysql_password
    if [ "$mysql_password" == "" ]; then
        echo -e "\e[91m数据库密码不能为空"
        exit
    fi

    delete_offset="0"
    echo "是否删除指定天数前备份(默认:不删除)?[y/n]"
    read delete_tag
    if [ "$delete_tag" == "y" ]; then
        echo "输入需要删除最早备份距当前的天数(默认:15);示例:如果需要删除3天前的备份,则输入3"
        read delete_offset
        if [ "$delete_offset" == "" ]; then
            delete_offset="15"
        fi
    fi
fi

# Date/time included in the file names of the database backup files.
datetime=$(date +'%Y-%m-%d-%H:%M:%S')

echo "正在获取容器ID..."

container_id=$(docker inspect $mysql_alias --format="{{.Id}}")

if [ $? -ne 0 ]; then
    echo -e "\e[91m容器ID获取失败"
    exit
fi

echo -e "\e[94m正在备份容器:$container_id中的数据库:$database..."

docker exec $container_id /usr/bin/mysqldump -u $mysql_user --password=$mysql_password --routines $database > $backups_dir$database--$datetime.sql 2>&1

if [ $? -ne 0 ]; then
    echo -e "\e[91m备份失败"
    exit
else
    echo -e "\e[92m备份完成:$backups_dir$database--$datetime.sql"
fi

if [ "$delete_offset" != "0" ]; then
    echo -e "\e[94m正在删除$delete_offset天前备份"
    find $backups_dir -mtime +$delete_offset -name "*.sql" -exec rm -f {} \;
fi