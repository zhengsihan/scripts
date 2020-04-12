#!/bin/bash
# fixguest -- 在注销的时候清理访客账户的残留。

# 不要相信环境变量:参考只读来源。

iam=$(id -un)
myhome="$(grep "^${iam}:" /etc/passwd | cut -d: -f6)"

# *** 不要对普通用户账户运行该脚本！

if [ "$iam" != "guest" ] ; then
    echo "Error: you really don't want to run fixguest on this account." >&2
    exit 1
fi

if [ ! -d $myhome/..template ] ; then
    echo "$0: no template directory found for rebuilding." >&2
    exit 1
fi

# 删除主账户中的所有文件和目录。

cd $myhome

rm -rf * $(find .-name ".[a-zA-Z0-9]*" -print)

# 现在剩下的就是..template目录了。

cp -Rp ..template/* .
exit 0