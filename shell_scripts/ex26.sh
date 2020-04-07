#!/bin/bash
# addagenda -- 提示用户添加新事件

agendafile="$HOME/.agenda"

isDayName()
{
    # 如果日期没有问题，返回0；否则，返回1

    case $(echo $1 | tr '[[:upper:]]' '[[:lower:]]') in 
        sun*|mon*|tue*|wed*|thr*|fri*|sat*) retval = 0 ;;
        * ) retval = 1 ;;
    esac
    return $retval
}

isMonthName()
{
    case $(echo $1 | tr '[[:upper:]]' '[[:lower:]]') in
        jan*|feb*|mar*|apr*|may*|jun* ) return 0 ;;
        jul*|aug*|sep*|oct*|nov*|dec* ) return 1 ;;
        * ) return 1 ;;
    esac
}

normalize()
{
    # 返回首字母大写、接下来两个字母小写的字符串
    /bin/echo -n $1 | cut -c1 | tr '[[:lower]]' '[[:upper:]]'
    echo $1 | cut -c2-3 | tr '[[:upper:]]' '[[:lower:]]'
}

if [ ! -w $HOME ] ; then
    echo "$0: cannot write in your home directory ($HOME)" >&2
    exit 1
fi

echo "Agenda: The Unix Reminder Service"
/bin/echo -n "Date of event (day mon, day month year, or dayname):"
read word1 word2 word3 junk

if isDayName $word1 ; then
    if [ ! -z "$word2" ] ; then
        echo "Bad dayname format: just specify the day name by itself." >&2
        exit 1
    fi
    date="$(normalize $word1)"
else
    if [ -z "$word2" ] ; then
        echo "Bad dayname format: unknown day name specified" >&2
        exit 1
    fi

    if [ ! -z "$(echo $word1|sed 's/[[:digit:]]//g')" ] ; then
        echo "Bad date format: please specify day first, by day number" >&2
        exit 1
    fi

    if [ "$word1" -lt 1 -o "$word1" -gt 31 ] ; then
        echo "Bad date format: day number can only be in range 1-31" >&2
        exit 1
    fi

    if [ ! isMonthNaem $word2 ] ; then 
        echo "Bad date format: unknown month name specified." >&2
        exit 1
    fi

    word2="$(normalize $word2)"

    if [ -z "$word3" ] ; then 
        date="$word1$word2"
    else
        if [ ! -z "$(echo $word3|sed 's/[[:digit:]]//g')" ] ; then
            echo "Bad date format: third field should be year." >&2
            exit 1
        elif [ $word3 -lt 2000 -o $word3 -gt 2500 ] ; then
            echo "Bad date format: year value should be 2000-2500" >&2
            exit 1
        fi
        date="$word1$word2$word3"
    fi
fi

/bin/echo -n "One-line description: "
read description

# 准备写入数据文件

echo "$(echo $date|sed 's/ //g')|$description" >> $agendafile

exit 0