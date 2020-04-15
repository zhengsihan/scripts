#!/bin/bash
# ssync -- 如果出现改动，则创建归档包，使用sftpsync通过sftp同步远程目录。

sftpacct="taylor@intuitive.com"
tarballname="AllFiles.tgz"
localsource="$HOME/Desktop/Wicked Cool Scripts/scripts"
remotedir="/wicked/scripts"
timestamp=".timestamp"
count=0

# 先看看本地目录是否存在，其中有没有文件。
if [ ! -d "$localsource" ] ; then
    echo "$0: Error: directory $localsource doesn't exist?" >&2
    exit 1
fi

cd "$localsource"

# 现在统计文件，确保的确有改动。
if [ ! -f $timestamp ] ; then
    for filename in * 
    do
        if [ -f "$filename" ] ; then
            count=$(( $count + 1 ))
        fi
    done
else
    count=$(find . -newer $timestamp -type f -print | wc -l)
fi

if [ $count -eq 0 ] ; then
    echo "$(basename $0): No files found in $localsource to sync with remote."
    exit 0
fi

echo "Making tarball archive file for upload"

tar -czf $tarballname ./*

# 搞定！现在切换到脚本sftpsync。
exec sftpsync $sftpacct $remotedir