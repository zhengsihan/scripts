#!/bin/bash
# mkslocatedb -- 以用户nobody的身份构建中央公共数据库，
# 同时遍历每个用户的主目录，在其中查找.slocatedb文件。
# 如果找到，就为该用户创建另外一个私有版本的locate数据库。

locatedb="/var/locate.db"
slocatedb=".slocatedb"

if [ "$(id -nu)" != "root" ] ; then
    echo "$0: Error: You must be root to run this command." >&2
    exit 1
fi

if [ "$(grep '^nobody:' /etc/passwd)" = "" ] ; then
    echo "$0: Error: you must have an account for user 'nobody'" >&2
    echo "to create the default slocate database." >&2
    exit 1
fi

cd / # 避开执行su之后的当前目录权限问题。

# 首先，创建或更新公共数据库。
su -fm nobody -c "find / -print" > $locatedb 2>/dev/null
echo "building default slocate database (user = nobody)"
echo ... result is $(wc -l < $locatedb) lines long.

# 遍历所有用户的主目录，看看谁有.slocatedb文件。
for account in $(cut -d: -f1 /etc/passwd)
do
    homedir="$(grep "^${account}:" /etc/passwd | cut -d: -f6)"

    if [ "$homedir" = "/" ] ; then
        continue # 如果是根目录，则不建立文件。
    elif [ -e $homedir/$slocatedb ] ; then
        echo "building slocate database for user $account"
        su -m $account -c "find / -print" > $homedir/$slocatedb 2>/dev/null
        chmod 600 $homedir/$slocatedb
        chown $account $homedir/$slocatedb
        echo ... result is $(wc -l < $homedir/$slocatedb) lines long.
done

exit 0