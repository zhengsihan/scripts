#!/bin/bash
# agenda -- 扫描用户的.agenda文件，查找是否有安排在当天或第二天的事件。

agendafile="$HOME/.agenda"

checkDate()
{
    # 创建匹配当天的默认值
    weekday=$1
    day=$2
    month=$3
    year=$4
    format1="$weekday"
    format2="$day$month"
    format3="$day$month$year"

    # 在数据文件中比对日期......
    IFS="|" # 读入的内容自然在IFS处分割
    echo "On the agenda for today:"

    while read date description ; do
        if [ "$date" = "$format1" -o "$date" = "$format2" -o "$date" = "$format3" ]
        then
            echo " $desciption"
        fi
    done < $agendafile

}

if [ ! -e $agendafile ] ; then
    echo "$0: You don't seem to have an .agenda file. " >&2
    echo "To remedy this, please use 'addagenda' to add events" >&2
    exit 1
fi

# 获得当天的日期......
eval $(date '+weekday="%a" month="%b" day="%e" year="%G"')

day="$(echo $day|sed 's/ //g')" # 删除可能存在的前导空格
checkDate $weekday $day $month $year

exit 0