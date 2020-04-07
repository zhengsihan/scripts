#!/bin/bash
# diskhogs -- 用于Unix的磁盘配额分析工具
# 假设所有用户的UID都大于或等于100
# 向超出配额的用户发送电子邮件并在屏幕上报告汇总信息。

MAXDISKUSAGE=500
violators="/tmp/diskhogs0.$$"

trap "$(which rm) -f $violators" 0

for name in $(cut -d: -f1,3 /etc/passwd | awk -F: '$2 > 99 { print $1 }')
do
    echo -n "$name"
    # 你可能需要根据个人的磁盘布局修改下面的目录列表。
    # 最可能做出的改动是将/Users改为/home。
    find / /usr /var /Users -xdev -user $name -type f -ls | awk '{ sum += $7 } END { print sum / (1024*1024) }'
done | awk "\$2 > $MAXDISKUSAGE { print \$0 }" > $violators

if [ ! -s $violators ] ; then
    echo "No users exceed the disk quota of ${MAXDISKUSAGE}MB"
    cat $violators
    exit 0
fi

while read account usage ; do
    cat << EOF | fmt | mail -s "Warning: $account Exceeds Quota" $account
    Your disk usage is ${usage}MB, but you have been allocated only
    ${MAXDISKUSAGE}MB. This means that you need to delete some of your
    files, compress your files (see 'gzip' or 'bzip2' for powerful and
    easy-to-use compression programs), or talk with us about increasing
    your disk allocation.

    Thanks for your cooperation in this matter.

    Your friendly neighborhodd sysadmin
    EOF

    echo "Account $account has $usage MB of disk space. User notified."
done < $violators

exit 0