#!/bin/bash
# fquota -- 用于Unix的磁盘配额分析工具
# 假设所有用户的UID都大于或等于100

MAXDISKUSAGE=20000 # 以MB为单位

for name in $(cut -d: -f1,3 /etc/passwd | awk -F: '$2 > 99 {print $1}')
do
    /bin/echo -n "User $name exceeds disk quota. Disk usage is: "
    # 你需要根据个人的磁盘布局修改下面的目录列表。
    # 最可能做出的改动是将/Users改为/home。
    find / /usr /var /Users -xdev -user $name -type f -ls | awk '{ sum += $7 } END { print sum / (1024*1024) " Mbytes" }'
done | awk "\$9 > $MAXDISKUSAGE {print \$0 }"

exit 0