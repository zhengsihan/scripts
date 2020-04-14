#!/bin/bash
# randomquote -- 该脚本会在一行一项的数据文件中随机挑选一行显示。
# 最好是再Web页面中以SSI调用的形式使用。

awkscript="/tmp/randomquote.awk.$$"

if [ $# -ne 1 ] ; then
    echo "Usage: randomquote datafilename" >&2
    exit 1
elif [ ! -r "$1" ] ; then
    echo "Error: quote file $1 is missing or not readable" >&2
    exit 1
fi

trap "$(which rm) -f $awkscript" 0

cat << "EOF" > $awkscript
BEGIN { srand() }
      { s[NR] = $0 }  
END   { print s[randint(NR)] }
function randint(n) { return int (n * rand() ) + 1 }
E0F

awk -f $awkscript < "$1"

exit 0