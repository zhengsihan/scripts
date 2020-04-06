#!/bin/bash
# timein -- 显示指定时区或地区的当前时间
# 如果不指定任何参数，则显示UTC/GMT。参数list会显示出已知地区的列表。
# 注意，它有可能会匹配到区域目录（地域），但只有时区文件（城市）才是有效的规格。

# 时区数据库参考：http://www.twinsun.com/tz/tz-link.htm

zonedir="/usr/share/zoneinfo"

if [ ! -d $zonedir ] ; then
    echo "No time zone database at $zonedir." >&2
    exit 1
fi

if [ -d "$zonedir/posix" ] ; then
    zonedir=$zonedir/posix # 现代Linux系统
fi

if [ $# -eq 0 ] ; then
    timezone="UTC"
    mixedzone="UTC"
elif [ "$1" = "list" ] ; then
    ( echo "All known time zones and regions defined on this system:"
        cd $zonedir
        find -L * -type f -print | xargs -n 2| awk '{ print ” %-38s %-38s\n", $1, $1 }'
    ) | more
    exit 0
else
    region="$(dirname $1)"
    zone="$(basename $1)"

    # 指定的时区是否能直接匹配？如果能直接匹配，则最好。
    # 否则我们需要继续查找。先来统计匹配次数。

    matchcnt="$(find -L $zonedir -name $zone -type f -print | wc -l | sed 's/[^[:digit:]]//g' )"

    # 检查是否至少有一个匹配文件。
    if [ "$matchcnt" -gt 0 ] ; then
        # 如果多于一个匹配文件，则退出。
        if [ $matchcnt -gt 1 ] ; then
            echo "\"$zone\" matches more than one possible time zone record." >&2
            echo "Please use 'list' to see all known regions and time zones." >&2
            exit 1
        fi
        match="$(find -L $zonedir -name $zone -type f -print)"
        mixedzone="$zone"
    else # 我们找到的可能是一个匹配的时区地域(time zone region)，而不是一个特定是时区(time zone)
        # 地域和时区的首字母大写，其余的字母小写。
        mixedregion="$(echo ${region%${region#?}} | tr '[[:lower]]' '[[:upper]]') $(echo ${region#?} | tr '[[:upper:]]' '[[:lower:]]')"
        mixedzone = "$(echo ${zone%${zone#?}} | tr '[[:lower:]]' '[[:upper:]]') $(echo ${zone#?} | tr '[[:upper:]]' '[[:lower:]]')"

    if [ "$mixedregion" != "." ] ; then
        # 只查找特定地域中的特定时区，如果存在多种可能
        # （例如Atlantic），让用户指定唯一的匹配。
        match="$(find -L $zonedir/$mixedregion -type f -name $mixedzone -print)"
    else
        match="$(find -L $zonedir -name $mixedzone -type f -print)"
    fi

    # 如果文件完全匹配指定的模式。
    if [ -z "$match" ] ; then
        # 检查模式是否太模糊。
        if [ ! -z $(find -L $zonedir -name $mixedzone -type d -print) ] ; then 
            echo "The region \"$1\" has more than one time zone. " >&2
        else # 如果根本没有出现任何匹配
            echo "Can't find an exact match for \"$1\". " >&2
            exit 1
        fi
    fi
    timezone="$match"
fi

nicetz=$(echo $timezone | sed "s|$zonedir/||g") # 美化输出
echo It\'s $(TZ=$timezone date '+%A, %B, %e, %Y, at %l:%M %p') in $nicetz
exit 0