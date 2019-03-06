#!/usr/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS/Debian/Ubuntu
#	Author: Lestat
#	Email: lestat@lestat.me
#	Blog: https://blog.lestat.me/
#=================================================

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

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
    echo -e "${Info}请使用root权限执行该脚本!"
    echo "输入需要备份的mysql容器名称(docker-compose.yml文件中的容器名):"
    read mysql_alias

    if [ "$mysql_alias" == "" ]; then
        echo -e "${Error}容器名不能为空"
        exit
    fi

    echo -e "${Info}待备份数据库名称:"
    read database
    if [ "$database" == "" ]; then
        echo -e "${Error}数据库不能为空"
        exit
    fi

    echo -e "${Info}备份目录(默认:/data/allindocker_backup):"
    read backups_dir
    if [ "$backups_dir" == "" ]; then
        mkdir -p /data/allindocker_backup/
        backups_dir="/data/allindocker_backup/"
    fi

    echo -e "${Info}数据库用户:"
    read mysql_user
    if [ "$mysql_user" == "" ]; then
        echo -e "${Error}数据库用户不能为空"
        exit
    fi

    echo -n -e "数据库密码:\n"
    read -s mysql_password
    if [ "$mysql_password" == "" ]; then
        echo -e "${Error}数据库密码不能为空"
        exit
    fi

    delete_offset="0"
    echo -e "${Info}是否删除指定天数前备份(默认:不删除)?[y/n]"
    read delete_tag
    if [ "$delete_tag" == "y" ]; then
        echo -e "${Info}输入需要删除最早备份距当前的天数(默认:15);示例:如果需要删除3天前的备份,则输入3"
        read delete_offset
        if [ "$delete_offset" == "" ]; then
            delete_offset="15"
        fi
    fi
fi

# Date/time included in the file names of the database backup files.
datetime=$(date +'%Y-%m-%d-%H:%M:%S')

echo -e "${Tip}正在获取容器ID..."

container_id=$(docker inspect $mysql_alias --format="{{.Id}}")

if [ $? -ne 0 ]; then
    echo -e "${Error}容器ID获取失败"
    exit
fi

echo -e "${Tip}正在备份容器:$container_id中的数据库:$database..."

docker exec $container_id /usr/bin/mysqldump -u $mysql_user --password=$mysql_password --routines $database > $backups_dir$database--$datetime.sql

if [ $? -ne 0 ]; then
    echo -e "${Error}备份失败"
    exit
else
    echo -e "${Tip}备份完成:$backups_dir$database--$datetime.sql"
fi

if [ "$delete_offset" != "0" ]; then
    echo -e "${Tip}正在删除$delete_offset天前备份"
    find $backups_dir -mtime +$delete_offset -name "*.sql" -exec rm -f {} \;
fi