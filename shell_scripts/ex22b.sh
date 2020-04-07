#!/bin/bash
# remindme -- 查找数据文件中匹配的行，如果没有指定参数，则显示数据文件的全部内容

rememberfile="$HOME/.remember"

if [ ! -f $rememberfile ] ; then
    echo "$0: You don't seem to have a .remember file." >&2
    echo "To remedy this, please use 'remember' to add reminders" >&2
    exit 1
fi

if [ $# -eq 0 ] ; then
    # 如果没有指定任何搜索条件，则显示整个数据文件
    more $rememberfile
else
    #否则，搜索指定内容并整齐地显示结果
    grep -i -- "$@" $rememberfile | ${PAGER:-more}
fi

exit 0