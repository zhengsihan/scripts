#!/bin/bash
# sftpsync -- 指定sftp服务器上的目标目录，确保所有的新文件或修改过的
# 文件都被上传到远程系统。使用名字巧妙的时间戳文件.timestamp进行跟踪。

timestamp=".timestamp"
tempfile="/tmp/sftpsync.$$"
count=0

trap "$(which rm) -f $tempfile" 0 1 15 # 退出脚本时删除临时文件。

if [ $# -eq 0 ] ; then 
    echo "Usage: $0 user@host { remotedir }" >&2
    exit 1
fi

user="$(echo $1 | cut -d@ -f1)"
server="$(echo $1 | cut -d@ -f2)"

if [ $# -gt 1 ] ; then
    echo "cd $2" >> $tempfile
fi

if [ ! -f $timestamp ] ; then
    # 如果没有时间戳文件，则上传所有文件。
    for filename in *
    do
        if [ -f "$filename" ] ; then
            echo "put -P \"$filename\"" >> $tempfile
            count=$(( $count + 1 ))
        fi
    done
else
    for filename in $(find . -newer $timestamp -type f -print)
    do
        echo "put -P \"$filename\"" >> $tempfile
        count=$(( $count + 1))
    done
fi

if [ $count -eq 0 ] ; then
    echo "$0: No files require uploading to $server" >&2
    exit 1
fi

echo "quit" >> $tempfile

echo "Synchronizing: Found $count files in local folder to upload."

if ! sftp -b $tempfile "$user@$server" ; then
    echo "Done. All files synchronized up with $server"
    touch $timestamp
fi
exit 0