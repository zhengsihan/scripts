#!/bin/bash
# checkexternal -- 遍历网站上的所有URL，建立外部链接清单，然后
# 逐个检查，确定链接是否有效。选项-a强制脚本列出所有的外部链接，
# 无论其是否能够访问。默认情况下，只显示无效链接。

listall=0
errors=0
checked=0

if [ "$1" = "-a" ] ; then
    listall=1
    shift
fi

if [ -z "$1" ] ; then
    echo "Usage: $(basename $0) [-a] URL" >&2
    exit 1
fi

trap "$(which rm) -f traverse*.errors reject*.dat traverse*.dat" 0

outfile="$(echo "$1" | cut -d/ -f3).errors.ext"
URLlist="$(echo $1 | cut -d/ -f3 | sed 's/www\.//').rejects"

rm -f $outfile # 准备新的输出。

if [ ! -e "$URLlist" ] ; then
    echo "File $URLlist not found. Please run checklinks first." >&2
    exit 1
fi

if [ ! -s "$URLlist" ] ; then
    echo "There don't appear to be any external links ($URLlist is empty)." >&2
    exit 1
fi

#### 现在，准备完毕，可以开始了......
for URL in $(cat $URLlist | sort | uniq)
do
    curl -s "$URL" > /dev/null 2>&1; return=$?
    if [ $return -eq 0 ] ; then
        if [ $ listall -eq 1 ] ; then
            echo "$URL is fine."
        fi
    else
        echo "$URL fails with error code $return"
        erros=$(( $errors + 1 ))
    fi
    checked=$(( $checked + 1 ))
done

echo ""
echo "Done. Checked $checked URLs and found $errors errors."
exit 0