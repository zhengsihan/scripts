#!/bin/bash
# archivedir -- 创建指定目录的压缩归档。

maxarchivedir=10 # “大块头（big）”目录的大小（以块为单位）。
compress=gzip # 修改成你喜欢的压缩程序。
progname=$(basename $0) # 更美观的错误信息输出格式。

if [ $# -eq 0 ] ; then # 没有参数？这就是有问题了。
    echo "Usage: $progname directory" >&2
    exit 1
fi

if [ ! -d $1 ] ; then
    echo "${progname}: can't find directory $1 to archive." >&2
    exit 1
fi 

if [ "$(basename $1)" != "$1" -o "$1" = "." ] ; then
    echo "${progname}: you must specify a subdirectory" >&2
    exit 1
fi

if [ ! -w . ] ; then
    echo "${progname}: cannot write archive file to current directroy." >&2
    exit 1
fi

# 最终形成的归档文件是否大得过头了？让我们检查一下......
dirsize="$(du -s $1 | awk '{print $1}')"

if [ $dirsize -gt $maxarchivedir ] ; then
    echo -n "Warning: directory $1 is $dirsize blocks. Proceed? [n] "
    read answer
    answer="$(echo $answer | tr '[[:upper:]]' '[[:lower:]]' | cut -c1)"
    if [ "$answer" != "y" ] ; then
        echo "${progname}: archive of directory $1 canceled." >&2
        exit 0
    fi
fi

archivename="$1.tgz"

if tar cf - $1 | $compress > $archivename ; then
    echo "Directory $1 archived as $archivename"
else
    echo "Warning: tar encountered errors archiving $1"
fi

exit 0