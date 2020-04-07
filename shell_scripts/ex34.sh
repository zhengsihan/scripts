#!/bin/bash
# bestcompress -- 尝试使用所有可用的压缩工具压缩给定的文件，
# 保留压缩后体积最小的文件，将结果报告给用户。如果没有指定-a，
# bestcompress会跳过输入流中的压缩文件。

Z="compress"
gz="gzip"
bz="bzip2"
Zout="/tmp/bestcompress.$$.Z"
gzout="/tmp/bestcompress.$$.gz"
bzout="/tmp/bestcompress.$$.bz"
skipcompressed=1

if [ "$1" = "-a" ] ; then
    skipcompressed=0; shift
fi

if [ $# -eq 0 ] ; then  
    echo "Usage: $0 [-a] file or files to optimally compress" >&2
    exit 1
fi

trap "/bin/rm -f $Zout $gzout $bzout" EXIT

for name in "$@"
do
    if [ ! -f "$name" ] ; then
        echo "$0: file $name not found. Skipped." >&2
        continue
    fi

    if [ "$(echo $name | egrep '(\.Z$|\.gz$|\.bz2$)')" != "" ] ; then
        if [ $skipcompressed -eq 1 ] ; then
            echo "Skipped file ${name}: It's already compressed."
            continue
        else
            echo "Warning: Trying to double-compress $name"
        fi
    fi

    # 尝试并行压缩3个文件
done