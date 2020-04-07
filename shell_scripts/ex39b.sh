#!/bin/bash
# slocate -- 尝试在用户自己的安全slocatedb数据库中搜索指定的模式。
# 如果找不到，则意味着数据库不存在，输出警告信息并创建数据库。
# 如果个人的.slocatedb数据库为空，则使用系统数据库。

locatedb="/var/locate.db"
slocatedb="$HOME/.slocatedb"

if [ ! -e $slocatedb -o "$1" = "--explain" ] ; then
    cat << "EOF" >&2
    Warning: Secure locate keeps a private database for each user, and your
    database hasn't yet been created. Until it is (probably late tonight),
    I'll just use the public locate database, which will show you all
    publicly accessible matches rather than those explicitly available to
    account ${USER:-$LOGNAME}.
    EOF

    if [ "$1" = "--explain" ] ; then
        exit 0 
    fi

    # 在继续往下进行之前，先创建.slocatedb,这样下次脚本
    # mkslocatedb运行的时候，cron就可以向其中填入内容了。

    touch $slocatedb # mkslocatedb会在下次建立该文件。
    chmod 600 $slocatedb # 设置好正确的权限。

elif [ -s $slocatedb ] ; then
    locatedb=$slocatedb
else
    echo "Warning: using public database. Use \"$0 --explain\" for details." >&2
fi

if [ -z "$1" ] ; then
    echo "Usage: $0 pattern" >&2
    exit 1
fi

exec grep -i "$1" $locatedb