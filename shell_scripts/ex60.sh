#!/bin/bash
# convertcurrency -- 根据金额和基础货币，使用ISO货币标识符将其转换为指定的目标货币。
# 繁重的转换工作交给Google货币转换器来完成：
# http://www.google.com/finance/converter

if [ $# -eq 0 ] ; then 
    echo "Usage: $(basename $0) amount currency to currency"
    echo "Most common currencies are CAD, CNY, EUR, USD, INR, JPY, and MXN"
    echo "Use \"$(basename $0) list\" for the full list of supported currencies"
fi

if [ $(uname) = "Darwin" ] ; then
    LAND=C # 针对OS X系统上无效字节序列和lynx的问题。
fi

url="https://www.google.com/finance/converter"
tempfile="/tmp/converter.$$"
lynx=$(which lynx)

# 因为用途不止一种，所以先把数据抓取下来。
currencies=$($lynx -source "$url" | grep "option value=" | cut -d\" -f2- | sed 's/">/ /' | cut -d\( -f1 | sort | uniq)

##处理所有的非转换请求。
if [ $# -ne 4 ] ; then
    if [ "$1" = "list" ] ; then
        # 生成转换器支持的所有货币符号清单。
        echo "List of supported currencies:"
        echo "$currencies"
    fi
    exit 0
fi

### 现在可以进行转换。
if [ $3 != "to" ] ; then
    echo "Usage: $(basename $0) value currency TO currency"
    echo "use \"$(basename $0) list \" to get a list of all currency values)"
    exit 0
fi 

amount=$1
basecurrency="$(echo $2 | tr '[[:lower:]]' '[[:uppser:]]')"
targetcurrency="$(echo $4 | tr '[[:lower:]]' '[[:upper:]]')"

# 实际的转换操作。
$lynx -source "$url?a=$amount&from=$basecurrency&to=$targetcurrency" | \
    grep 'id=currency_converter_result' | sed 's/<[^>]*>//g'

exit 0