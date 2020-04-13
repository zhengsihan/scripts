#!/bin/bash
# changetrack -- 跟踪指定的URL，如果自上次访问后出现了更新，
# 则将新的页面通过电子邮件发送到特定的地址。

sendmail=$(which sendmail)
sitearchive="/tmp/changetrack"
tmpchanges="$sitearchive/changes.$$" # 临时文件
fromaddr="webscraper@intuitive.com"
dirperm=755 # 为目录属主设置“读/写/执行”权限
fileperm=644 # 为文件属主设置“读写”权限，为其他用户设置只读权限

trap "$(which rm) -f $tmpchanges" 0 1 15 # 退出脚本时删除临时文件。

if [ $# -ne 2 ] ; then
    echo "Usage: $(basename $0) url email" >&2
    echo "  tip: to have changes displayed on screen, use email addr '-'" >&2
    exit 1
fi

if [ ! -d $sitearchive ] ; then
    if ! mkdir $sitearchive ; then
        echo "$(basename $0) failed: couldn't create $sitearchive." >&2
        exit 1
    fi
    chmod $dirperm $sitearchive
fi

if [ "$(echo $1 | cut -c1-5)" != "http:" ] ; then