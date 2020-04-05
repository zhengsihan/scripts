#！/bin/bash
    # valid-date -- 验证日期（考虑闰年亏则）。

    PATH=.:$PATH

    exceedsDaysInMonth()
    {
        # 给定月份名称和天数，如果指定的天数小于或等于该月份的最大天数，
        # 函数返回0；否则，返回1.

        case $(echo $1|tr '[:upper:]' '[:lower:]') in
            jan* ) days=31 ;;
            feb* ) days=28 ;;
            mar* ) days=31 ;;
            apr* ) days=30 ;;
            may* ) days=31 ;;
            jun* ) days=30 ;;
            jul* ) days=31 ;;
            aug* ) days=31 ;;
            sep* ) days=30 ;;
            oct* ) days=31 ;;
            nov* ) days=30 ;;
            dec* ) days=31 ;;
            * ) echo "$0: Unknown month name $1" >&2
                exit 1
        esac
        if [ $2 -lt 1 -o $2 -gt $days ] ; then
            return 1
        else
            return 0 # 天数有效。
        fi
    }

    isLeapYear()
    {
        # 如果指定的年份是闰年，该函数返回0；否则，返回1.
        # 验证闰年的规则如下。
        # (1) 不能被4整除的年份不是闰年。
        # (2) 能够被4和400整除的年份是闰年。
        # (3) 能够被4整除，不能被400整除，但是可以被100整除的年份不是闰年。
        # (4) 其他能够被4整除的年份是闰年。

        year=$1
        if [ "$((year % 4))" -ne 0 ] ; then
            return 1 # 不是闰年。
        elif [ "$((year % 400))" -eq 0 ] ; then
            return 0 # 是闰年
        elif [ "$((year % 100))" -eq 0 ] ; then
            return 1
        else
            return 0
        fi
    }

    # 主脚本开始
    # =====================

    if [ $# -ne 3 ] ; then
        echo "Usage: $0 month day year" >&2
        echo "Typical input formats are August 3 1962 and 8 3 1962" >&2
        exit 1
    fi

    # 规范日期，保存返回值以供错误检查。

    newdate="$($normdate "$@")"

    if [ $? -eq 1 ] ; then
        exit 1 #错误情况已经由normdate报告过了。
    fi

    # 拆分规范后的日期格式，其中第一个字段是月份，
    # 第二个字段是天数，第三个字段是年份。

    month="$(echo $newdate | cut -d\ -f1)"
    day="$(echo $newdate | cut -d\ -f2)"
    year="$(echo $newdate | cut -d\ -f3)"

    # 现在来检查天数是否合法有效（例如，不能是1月36日）。

    if ! exceedsDaysInMonth $month "$2" ; then
        if [ "$month" = "Feb" -a "$2" -eq "29" ] ; then
            if ! isLeapYear $3 ; then
                echo "$0: $3 is not a leap year, so Feb doesn't have 29 days." >&2
                exit 1
            fi
        else
            echo "$0: bad day value: $month doesn't have $2 days." >&2
            exit 1
        fi
    fi

    echo "Valid date: $newdate"

    exit 0