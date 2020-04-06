#!/bin/bash
# mklocatedb -- 使用find命令构建locate的数据库。用户必须以root身份运行该脚本

locatedb="/tmp/locate.db"

if [ "$(whoami)" != "root" ] ; then
    echo "Must be root to run this command." >&2
    exit 1
fi

find / -print > $locatedb

exit 0