#!/bin/bash
# setdate -- 易用的date命令前端。
# 日期格式：[[[[[cc]yy]mm]dd]hh]mm[.ss]

# 为了便于用户使用，该函数提示特定的日期值，
# 根据当前日期和时间在[]中显示默认值。

. ../1/library.sh # 导入函数库，使用其中的函数echon()。

askvalue()
{
    # $1 = 字段名， $2 = 默认值， $3 = 最大值，
    # $4 = 所要求的字符/数字长度。

    echon "$1 [$2] : "
    read answer
    if [ ${answer:=$2} -gt $3 ] ; then
        echo "$0: $1 $answer is invalid"
        exit 0
    elif [ "$(( $(echo $answer | wc -c) -1 ))" -lt $4 ] ; then
        echo "$0: $1 $answer is too short: please specify $4 digits"
        exit 0
    fi
    eval $1=$answer # 使用指定的值重新载入变量。
}

eval $(date "+nyear=%Y nmon=%m nday=%d nhr=%H nmin=%M")

askvalue year $nyear 3000 4
askvalue month $nmon 12 2
askvalue day $nday 31 2
askvalue hour $nhr 24 2
askvalue minute $nmin 59 2

squished="$year$month$day$hour$minute"

# 如果你使用的是Linux系统：
# squished="$month$day$hour$minute$year"
# 没错，Linux和OSX/BSD系统采用的是不同的格式。有用吧?

echo "Setting date to $squished. You might need to enter your sudo password:"
sudo date $squished

exit 0