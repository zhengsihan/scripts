#!/bin/bash
# deleteuser -- 彻底删除用户账户。不适用于OS X系统。

homedir="/home"
pwfile ="/etc/passwd"
shadow="/etc/shadow"
newpwfile="/etc/passwd.new"
newshadow="/etc/shadow.new"
suspend="$(which suspenduser)"
locker="/etc/passwd.lock"

if [ -z $1 ] ; then
    echo "Usage: $0 account" >&2
    exit 1
elif [ "$(whoami)" != "root" ] ; then
    echo "Error: you must be 'root' to run this command.">&2
    exit 1
fi

$suspend $1 # 在删除用户账户时先将其禁用。

uid="$(grep -E "^{1}:" $pwfile | cut -d: -f3)"

if [ -z $uid ] ; then
    echo "Error: no account $1 found in $pwfile">&2
    exit 1
fi

# 从文件/etc/passwd和/etc/shadow中删除账户信息。
grep -vE "^${1}:" $pwfile > $newpwfile
grep -vE "^${1}:" $shadow > $newshadow

lockcmd="$(which lockfile)" # 在PATH中查找lockfile程序。
if [ ! -z $lockcmd ] ; then
    eval $lockcmd -r 15 $locker
else
    while [ -e $locker ] ; do
        echo "waiting for the password file" ; sleep 1
    done
    touch $locker # 创建锁文件。
fi

mv $newpwfile $pwfile
mv $newshadow $shadow
rm -f $locker # 再解锁

chmod 644 $pwfile 
chmod 400 $shadow

# 现在删除主目录以及其中的所有文件。
rm -rf $homedir/$1

echo "Files still left to remove (if any):"
find / -uid $uid -print 2>/dev/null | sed 's/^/ /'

echo ""
echo "Account $1 (uid $uid) has been deleted, and theire home directory "
echo "($homedir/$1) has been removed."

exit 0