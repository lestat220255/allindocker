#!/bin/bash

set -e

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

if [ $UID -ne 0  ]; then
    echo -e "${Error}你需要root权限来执行该操作"
    exit 1
fi

echo -e "${Info}输入openresty/nginx容器名称(默认:openresty):"
read container_name

if [ "$container_name" == "" ]; then
    container_name="openresty"
fi

echo -e "${Info}输入域名:"
read host

if [ "$host" == "" ]; then
    echo -e "${Error}域名不能为空"
    exit
fi

echo -e "${Info}输入项目入口文件绝对路径(容器内绝对路径):"
read abs_path

if [ "$abs_path" == "" ]; then
    echo -e "${Error}入口文件路径不能为空"
    exit
fi

echo -e "${Info}输入nginx/openresty虚拟机配置目录在宿主机上的绝对路径:"
read abs_conf_path

if [ "$abs_conf_path" == "" ]; then
    echo -e "${Error}配置路径不能为空"
    exit
fi

conf_file="$abs_conf_path/$host.conf"

# 判断同名配置文件是否已经存在
if [ -f "$conf_file"  ]; then
    echo -e "${Error}当前域名对应的配置文件已经存在!"
    exit 1
fi

# 创建配置文件
cp $abs_conf_path/example.conf.example $conf_file

# 替换内容
sed -i "" "s+HOST_NAME+$host+g" "$conf_file"
sed -i "" "s+ABS_PATH+$abs_path+g" "$conf_file"

# 更新hosts文件
sudo echo "127.0.0.1 $host" >> /etc/hosts

# 重启nginx
sudo docker exec $container_name nginx -s reload
