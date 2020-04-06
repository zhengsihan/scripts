#!/bin/bash
# logrm -- 记录所有的文件删除操作（除非指定了-s选项）。

removelog="/tmp/remove.log"

if [ $# -eq 0 ] ; then
    echo "Usage: $0 [-s] list of files or directories" >&2
    exit 1
fi

if [ "$1" = "-s" ] ; then
    # 请求静默模式......不记录删除操作
    shift
else
    echo "$(date):${USER}: $@" >> $removelog
fi

/bin/rm "$@"

exit 0