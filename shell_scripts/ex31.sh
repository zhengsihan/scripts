#!/bin/bash
# mysftp -- 让sftp用起来更像ftp

/bin/echo -n "User account: "
read account

if [ -z $account ] ; then
    exit 0; # 用户大概是改注意了
fi

if [ -z "$1" ] ; then
    /bin/echo -n "Remote host: "
    read host
    if [ -z $host ] ; then
        exit 0
    fi
else
    host=$1
fi

# 最后以切换到sftp作结。-C选项在此处启用压缩功能

exec sftp -C $account@$host