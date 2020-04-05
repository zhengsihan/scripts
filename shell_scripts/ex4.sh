#!/bin/bash
    # nicenumber -- 将给定的数字以逗号分隔的形式显示出来。
    # 可接受两个选项：DD(decimal point delimiter，小数分隔符)
    # 和TD(thousands delimiter, 千位分隔符)。
    # 美化数字显示，如果指定了第二个参数，则将输出回显在stdout。

    nicenumber()
    {
        # 注意，我们假设'.'是脚本输入值的小数分隔符。
        # 除非用户使用选项-d指定了其他分隔符，否则输出值中的小数分隔符也是'.'。

        integer=$(echo $1 | cut -d. -f1) #小数分隔符左侧。
        decimal=$(echo $1 | cut -d. -f2) #小数分隔符右侧。

        # 检查数字是否不为整数。
        if [ "$decimal" != "$1" ]; then
            # 有小数部分，将其保存起来。
            result="${DD:= '.'}$decimal"
        fi

        thousands=$integer

        while [ $thousands -gt 999 ]; do
            remainder=$(($thousands % 1000)) # 3个最低有效数字。

            # 我们需要变量remainder中包含3位数字。是否需要添加0？
            while [ ${#n} -lt 3 ] ; do #加入前导数字0.
                remainder="0$remainremainderder"
            done

            result="${TD:=","}${remainder}${result}" # 从右向左构建最终结果。
            thousands=$(($thousands / 1000)) # 如果有的话，千位分隔符左侧部分。
        done

        nicenum="${thousands}${result}"
        if [ ! -z $2 ] ; then
            echo $nicenum
        fi
    }

    DD="." # 小数分隔符，分隔整数部分和小数部分。
    TD="," # 千位分隔符，隔3个数字出现一次。

    # 主脚本开始
    # ==============

    while getopts "d:t:" opt; do
        case $opt in
            d ) DD="$OPTARG"    ;;
            t ) TD="$OPTARG"    ;;
        esac
    done
    shift $(($OPTIND -1))

    # 输入验证。
    if [ $# -eq 0 ] ; then
        echo "Usage: $(basename $0) [-d c] [-t c] numeric_value"
        echo " -d specifies the decimal point delimiter (default '.')"
        echo " -t specifies the thousands delimiter (default ',')"
        exit 0
    fi

    nicenumber $1 1 #第二个参数强制nicenumber函数回显输出。

    exit 0