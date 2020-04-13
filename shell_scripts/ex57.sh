#!/bin/bash
# areacode -- 根据3位数字的美国电话区号，使用网站
# Bennet Yee上简单的表格数据识别出其所在标识城市和州。

source="http://www.bennetyee.org/ucsd-pages/area.xhtml"

if [ -z "$1" ] ; then
    echo "usage: areacode <three-digit US telephone area code>"
    exit 1
fi

# wc -c 返回的字符数包含行尾字符，所以3位数字共计4个字符。
if [ "$(echo $1 | wc -c)" -ne 4 ] ; then
    echo "areacode: wrong length: only works with three-digit US area codes"
    exit 1
fi

# 全都是数字？
if [ ! -z "$(echo $1 | sed 's/[[:digit:]]//g')" ] ; then
    echo "areacode: not-digits: area codes can only be made up of digits"
    exit 1
fi

# 最后，让我们来查询区号......
result="$(curl -s -dump $source | grep "name=\"$1" | sed 's/<[^>]*>//g;s/^ //g' | cut -f2- -d\ | cut -f1 -d\( )"

echo "Area code $1 =$result"

exit 0