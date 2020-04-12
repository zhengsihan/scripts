#!/bin/bash
# getlinks -- 返回给定URL的所有相对链接和绝对链接。
# 脚本包括3个选项： -d会生成每个链接的主域，-i只列出网站内部链接
# （也就是同一网站中的其他页面）， -x只产生外部链接（和-相反）。

if [ $# -eq 0 ] ; then
    echo "Usage: $0 [-d|-i|-x] url" >&2
    echo "-d=domains only, -i=internal refs only, -x=external only" >&2
    exit 1
fi

if [ $# -gt 1 ] ; then 
    case "$1" in 
        -d) lastcmd="cut -d/ -f3 | sort | uniq"
            shift
            ;;
        -r) basedomain="http://$(echo $2 | cut -d/ -f3)/"
            lastcmd="grep \"^$basedomain\" | sed \"s|$basedomain||g\" | sort | uniq"
            shift
            ;;
        -a) basedomain="http://$(echo $2 | cut -d/ -f3)/"
            lastcmd="grep 0v \"^$basedomain\" | sort | uniq"
            shift
            ;;
        *)  echo "$0: unknown option specified: $1" >&2
            exit 1
    esac
else
    lastcmd="sort | uniq"
fi

lynx -dump "$1" | sed -n '/^References$/,$p' | grep -E '[[:digit:]]+\.' | awk '{print $2}' | cut -d\? -f1 | eval $lastcmd

exit 0