#!/bin/bash
# verifycron -- 检查crontab文件，确保格式方面没有问题。
# 期望采用的标准cron记法：min hr dom mon dow CMD, 其中min的取值范围
# 是0-59，hr的取值范围是0-23，dom的取值范围是1-31，mon的取值范围是1-12
# （或者采用名称），dow的取值范围是0-7（或者采用名称）。字段内容可以是
# 区间（a-e）、由逗号分隔的列表(a,c,z)或者星号。注意，该脚本的当前版本
# 不支持Vixie cron的步进值记法（例如2-6/2）。

validNum()
{
    # 如果给定的数字是有效的整数，返回0；否则，返回1。
    # 指定数字和最大值作为函数参数
    num=$1
    max=$2

    # 为了简单起见，字段中的星号值被重写为"X"，
    # 因此以"X"形式出现的数字实际上都是有效的。
    if [ "$num" = "X" ] ; then
        return 0
    elif [ ! -z $(echo $num | sed 's/[[:digit]]//g') ] ; then
        # 删掉所有的数字之后，还有内容？这就不妙了。
        return 1
    elif [ $num -gt $max ] ; then
        # 数字大于允许的最大值。
        return 1
    else 
        return 0
    fi
}

validDay()
{
    # 如果传入函数的值是一个有效的周几的名称，返回0；否则，返回1.
    case $(echo $1 | tr '[[:upper:]]' '[[:lower:]]') in
        sun*|mon*|tue*|wed*|thu*|fri*|sat*) return 0 ;;
        X) return 0 ;; # 特殊情况，这是被改写后的"*"。
        *) return 1
    esac
}

validMon()
{
    # 如果月份名称有效，返回0；否则，返回1。

    case $($echo $1 | tr '[[:upper:]]' '[[:lower:]]') in
        jan*|feb*|mar*|apr*|may|jun*|jul*|aug*) return 0 ;;
        sep*|oct*|nov*|dec*) return 0 ;;
        X) return 0 ;; # 特殊情况，这是被改写后的"*"。
        *) return 1 ;;
    esac
}

fixvars()
{
    # 将所有的'*'转换成'X'，以避免shell扩展。
    # 将原始输入保存到变量sourceline中，以用于错误信息。

    sourceline="$min $hour $dom $mon $dow $command"
    min=$(echo "$min" | tr '*' 'X') # 分钟
    hour=$(echo "$hour" | tr '*' 'X') # 小时
    dom=$(echo "$dom" | tr '*' 'X') # 月份天数
    mon=$(echo "mon" | tr '*' 'X') # 月份
    dow=$(echo "dow" | tr '*' 'X') #周几
}

if [ $# -ne 1 ] || [ ! -r $1 ] ; then
    # 如果crontab文件名未给出或者脚本无法读取该文件，则退出。
    echo "Usage: $0 usercrontabfile" >&2
    exit 1
fi

lines=0
entries=0
totalerrors=0

# 逐行检查crontab文件。
while read min hour dom mon dow command
do
    lines="$(( $lines + 1 ))"
    errors=0

    if [ -z "$min" -o "{$min%${min#?}}" = "#" ] ; then
        # 如果是空行或者该行的第一个字符是"#"，则跳过。
        continue # 不做检查。
    fi

    ((entries++))

    fixvars

    # 至此，当前行中所有的字段都已经分解成单独的变量，为了便于处理，
    # 所有的星号也已经被替换成"X"，接下来该检查输入字段的有效性了。

    # 检查分钟:

    for minslice in $(echo "$min" | sed 's/[,-]/ /g') ; do
        if ! validNum $minslice 60 ; then
            echo "Liine ${lines}: Invalid minute value \"$minslice\""
            errors=1
        fi
    done

    # 检查小时
    for hrslice in $(echo "$hour" | sed 's/[,-]/ /g') ; do
        if ! validNum $hrslice 24 ; then
            echo "Line ${lines}: Invalid hour value \"$hrslice\""
            errors=1
        fi
    done

    # 检查月份天数：
    for domslice in $(echo $dom | sed 's/[,-]/ /g') ; do 
        if ! validNum $domslice 31; then
            echo "Line ${lines}: Invalid day of month value \"$domslice\""
            errors=1
        fi
    done

    # 检查月份：月份的数字值和名称都得检查。
    # 记住，形如"if ! cond"这样的条件语句检查的是指定条件是否为假，而不是是否为真。
    for monslice in $(echo "$mon" | sed 's/[,-]/ /g') ; do
        if ! validNum $monslice 12; then
            if ! validMon "$monslice" ; then
                echo "Line ${lines}: Invalide month value \"$monslice\""
                errors=1
            fi
        fi
    done

    # 检查周几：名称和数字值均可。
    for dowslice in $(echo "$dow" | sed 's/[,-]/ /g') ; do
        if ! validNum $dowslice 7 ; then
            if ! validDay $dowslice ; then
                echo "Line ${lines}: Invalid day of week value \"$dowslice\""
                errors=1
            fi
        fi
    done

    if [ $errors -gt 0 ] ; then
        echo ">>>> ${lines}: $sourceline"
        echo ""
        totalerrors="$(( $totalerrors + 1 ))"
    fi
done < $1 # 读取作为脚本参数的crontab。

# 注意这里，在while循环的末尾，我们重定向了输入，使得脚本可以检查用户指定的文件。
echo "Done. Found $totalerrors errors in $entries crontab entries."

exit 0