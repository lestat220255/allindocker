#!/usr/bin/bash

if [ "$1" ]; then
    mysql_alias="$1"
    database="$2"
    backups_dir="$3"
    mysql_user="$4"
    mysql_password="$5"
    delete_tag="$6"
    delete_offset="$7"
else
    echo -e "\e[96m请使用root权限执行该脚本!"
    echo "输入需要备份的mysql容器名称(docker-compose.yml文件中的容器名):"
    read mysql_alias

    if [ "$mysql_alias" == "" ]; then
        echo "容器名不能为空"
        exit
    fi

    echo "待备份数据库名称:"
    read database
    if [ "$database" == "" ]; then
        echo "数据库不能为空"
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
        echo "数据库用户不能为空"
        exit
    fi

    echo -n -e "数据库密码:\n"
    read -s mysql_password
    if [ "$mysql_password" == "" ]; then
        echo "数据库密码不能为空"
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

echo "正在备份..."

container_id=$(sudo docker inspect $mysql_alias | grep Id | awk '{print $2}' | sed 's/\("\|,\)//g')

docker exec $container_id /usr/bin/mysqldump -u $mysql_user --password=$mysql_password --routines $database | gzip -9 > $backups_dir$database--$datetime.sql.gz;

if [ "$delete_offset" != "0" ]; then
    find $backups_dir -mtime +$delete_offset -name "*.sql.gz" -exec rm -f {} \;
fi