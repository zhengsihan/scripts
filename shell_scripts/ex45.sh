#!/bin/bash
# findsuid -- 检查所有的SUID文件或程序，确定其是否可写，
# 以友好实用的格式输出结果。

mtime="7" # 检查多久之前（以天为单位）被修改过的命令。
verbose=0 # 默认采用安静模式

if [ "$1" = "-v" ] ; then
    verbose=1 # 用户指定了选项-v，因此采用详细模式。
fi

# find -perm命令回查看文件的权限：4000以及以上的权限为setuid/setgid。

find / type f -perm +4000 -print0 | while read -d '' -r match
do
    if [ -x "$match" ] ; then
        # 从ls -ld的输出中获得文件属主以及权限。
        owner="$(ls -ld $match | awk '{print $3}')"
        perms="$(ls -ld $match | cut -c5-10 | grep 'w')"

        if [ ! -z $perms ] ; then
            echo "**** $match (writeable and setuid $owner)"
        elif [ ! -z $(find $match -mtime -$mtime -print) ] ; then
            echo "**** $match (modified within $mtime days and setuid $owner)"
        elif [ $verbose -eq 1 ] ; then
            # 默认情况下，只列出危险的脚本。如果是详细模式，则全部列出。
            lastmod="$(ls -ld $match | awk '{print $6, $7, $8}')"
            echo "$match (setuid $owner, last modified $lastmod)"
        fi
    fi
done

exit 0