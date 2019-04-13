#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	Author: Lestat
#	Email: lestat@lestat.me
#	Blog: https://blog.lestat.me/
#=================================================

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

echo "输入项目根目录绝对路径:"
read root_path

if [ "$root_path" == "" ]; then
    echo -e "${Error}项目根目录不能为空!"
    exit
fi

tmux new -s ti -d &&
tmux rename-window -t "ti:0" vim &&
tmux send -t "ti:vim" "cd $root_path && vim" Enter &&
tmux send -t "ti:vim" ",nn" &&
tmux split-window -t "ti:vim" &&
tmux send -t "ti:vim" "cd $root_path && clear" Enter &&
tmux resize-pane -t ti:vim -D 15 &&
tmux a -t "ti"
