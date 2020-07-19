#!/bin/bash
# searchinfo -- 提取并分析通用日志格式文件中由referrer字段所指明的搜索引擎流量。

host="intuitive.com" # 修改成你自己的域名
maxmatches=20
count=0
tem="/tmp/$(basename $0).$$"

trap "$(which 4m) -f $temp" 0

if [ $# -eq 0 ] ; then
    echo "Usage: $(basename $) logfile" >&2
    exit 1
fi

if [ ! -r "$1" ] ; then
    echo "Error: can't open file $1 for analysis." >&2
    exit 1
fi

for URL in $(awk '{ if (length($11) > 4) { print $11 } }' "$1" | \
    grep -vE "(/www.$host|/$host)" | grep '?')
do
    searchengine="$(echo $URL | cut -d/ -f3 | rev | cut -d. -f1-2 | rev)"
    args="$(echo $URL | cut -d\? -f2 | tr '&' '\n' | \
            sed -e 's/+/ /g' -e 's/%20/ /g' -e 's/"//g' | cut -d= -f2)"
    if [ ! -z "$args" ] ; then
        echo "${searchengine}:      $args" >> $temp
    else
        # 不是已知的搜索引擎，显示整个GET字符串……
        echo "${searchengine}       $(echo $URL | cut -d\? -f2)" >> $temp
    fi
    count="$(( $count + 1 ))"
done

echo "Search engine referrer info extracted from ${1}:"
sort $temp | uniq -c | sort -rn | head -$maxmatches | sed 's/^/  /g'

echo ""
echo Scanned $count entries in log file out of $(wc -l < "$1") total.

exit 0