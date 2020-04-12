#!/bin/bash
# adduser -- 添加新用户，包括建立用户主目录、复制默认配置数据等。
# 该脚本仅适用于标准的Unix /Linux系统，不适用于OS X系统。

pwfile="/etc/passwd"
shadowfile="/etc/shadow"
gfile="/etc/group"
hdir="/home"

if [ "$(id -un)" != "root" ] ; then
    echo "Error: You must be root to run this command." >&2
    exit 1
fi

echo "Add new user account to $(hostname)"
echo -n "login: " ; read login

# 下一行将用户ID可能的最高值设置为5000，不过你应该将该值
# 调整为符合你所在系统的用户ID范围的上限值。

uid="$(awk -F: '{if ( big < $3 && $3 < 5000) big = $3 } END { print big + 1 }' $pwfile)"
homedir=$hdir/$login

# 为每个用户建立自有组。
gid=$uid

echo -n "full name: " ; read fullname
echo -n "shell: " ; read shell

echo "Setting up account $login for $fullname..."

echo ${login}:x:${uid}:${gid}:${fullname}:${homedir}:$shell >> $pwfile
echo ${login}:*:11647:0:99999:7::: >> $shadowfile

echo "${login}:x:${gid}:$login" >> $gfile

mkdir $homedir
cp -R /etc/skel/.[a-zA-Z]* $homedir
chmod 755 $homedir
chown -R ${login}:${login} $homedir

# 设置初始密码。
exec passwd $login