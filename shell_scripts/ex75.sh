#!/bin/bash
# weberrors -- 扫描Apache的error_log文件，报告最重要的错误，然后列出其他日志项。

temp="/tmp/$(basename $0).$$"

# 下面的3行代码需要根据你自己实际的安装情况做出调整。
htdocs="/usr/local/etc/httpd/htdocs/"
myhome="/usr/home/taylor/"
cgibin="/usr/local/etc/httpd/cgi-bin/"

sedstr="s/^/  /g;s|$htdocs|[htdocs]  |;s|$myhome|[homedir] |;s|$cgibin|[cgi-bin] |"
screen="(File does not exist|Invalid error redirect|premature EOF | Premature end of script|script not found)"

length=5 # 每种类别显示的项数。

checkfor()
{
    grep "${2}:" "$1" | awk '{print $NF}' |\
        sort | uniq -c | sort -rn | head -$length | sed "$sedstr" > $temp
    if [ $(wc -l < $temp) -gt 0 ] ; then
        echo ""
        echo "$2 errors:"
        cat $temp
    fi
}

trap "$(which rm) -f $temp" 0

if [ "$1" = "-l" ] ; then
    length=$2
    shift 2
fi

if [ $# -ne 1 -o ! -r "$1" ] ; then
    echo "Usage: $(basename $0) [-l len] error_log" >&2
    exit 1
fi

echo Input file $1 has $(wc -l < "$1") entries.

start="$(grep -E '\[.*:.*:.*\]' "$1" | head -1 | awk '{print $1" "$2" "$3" "$4" "$5 }')"
end="$(grep -E '\[.*:.*:.*\]' "$1" | tail -1 | awk '{print $1" "$2" "$3" "$4" "$5 }')"
/bin/echo -n "Entries from $start to $end"

echo ""

## 检查各种常见和众所周知的错误:
checkfor "$1" "File does not exist"
checkfor "$1" "Invalid error rediretion directive"
checkfor "$1" "premature EOF"
checkfor "$1" "script not found or unable to start"
checkfor "$1" "Premature end of script headers"

grep -vE "$screen" "$1" | grep "\[error\]" | grep "\[client " |\
    sed 's/\[error\]/\`\' | cut -d \` -f2 | cut -d\ -f4- | \
        sort | uniq -c | sort -rn | sed 's/^/  /' | head -$length > $temp

if [ $(wc -l < $temp) -gt 0 ] ; then
    echo ""
    echo "Additional error messages in log file:"
    cat $temp
fi

echo ""
echo "And non-error messages occurring in the log file:"

grep -vE "$screen" "$1" | grep -v "\[error\]" | \
    sort | uniq -c | sort -rn | \
    sed 's/^/  /' | head -$length

exit 0