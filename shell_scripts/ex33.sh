#!/bin/bash
# zcat、zmore和zgrep -- 应该使用符号链接或硬链接将该脚本
# 链接到这3个命令名。它允许用户透明地处理压缩文件。

Z="compress"
unZ="uncompress"
Zlist=""
gz="gzip"
ungz="gunzip"
gzlist=""
bz="bzip2"
unbz="bunzip2"
bzlist=""

# 第一步是尝试将文件名从命令行中提取出来。
# 这里用了一个懒法子：逐个检查每个参数，测试其是否为文件名。
# 如果是，而且采用的是压缩文件后缀，就解压该文件，改写文件名。
# 然后进一步处理。处理完成后，将之前解压缩的文件重新压缩。

for arg
do
    if [-f "$arg" ] ; then
        case "$arg" in
            *.Z ) $unZ "$arg"
                arg="$(echo $arg | sed 's/\.Z$//')"
                Zlist="$Zlist \"$arg\""
                ;;
            *.gz ) $ungz "$arg"
                arg="$(echo $arg | sed 's/\.gz$//')"
                gzlist="$gzlist \"$arg\""
                ;;
            *.bz2 ) $unbz "$arg"
                arg="$(echo $arg | sed 's/\.bz2$//')"
                bzlist="$bzlist \"$arg\""
                ;;
        esac
    fi
    newargs="${newargs:-""} \"$arg\""
done

case $0 in
    *zcat* ) eval cat $newargs ;;
    *zmore* ) eval more $newargs ;;
    *zgrep* ) eval grep $newargs ;;
    * ) echo "$0: unknown base naem. Can't proceed." >&2
        exit 1
esac

# 现在重新压缩
if [ ! -z "$Zlist" ] ; then
    eval $Z $Zlist
fi
if [ ！ -z "$gzlist" ] ; then
    eval $gz $gzlist
fi
if [ ! -z "$bzlist" ] ; then
    eval $bz $bzlist
fi

# 大功告成

exit 0