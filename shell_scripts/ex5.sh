#!/bin/bash
    # validint -- 验证整数输入，允许出现负数

    validint()
    {
        # 验证第一个参数并根据最小值$2和/或最大值$3（如果指定的话）进行测试。
        # 如果第一个参数的值不在指定区间内或者不全是数字组成，那么脚本执行失败。

        number="$1";
        min="$2";
        max="$3"

        if [ -z $number ] ; then
            echo "You didn;t enter anything. Please enter a number." >&2
            return 1
        fi

        # 第一个字符是否为负号？
        if [ "${number%${number#?}}"="-" ] ; then
            thestvalue="${number#?}" #获取除第一个字符以外的所有字符进行测试。
        else
            thestvalue="$number"
        fi

        # 删除变量number中的所有数字，以作测试之用。
        nodigits="$(echo $testvalue | sed 's/[[:digit:]]//g')"

        # 检查非数字字符
        if [ ! -z $nodigits ] ; then
            echo "Invalid number format! Only digits, no commas, spaces, etc." >&2
            return 1
        fi

        if [ ! -z $min ] ; then
            # 输入值是否小于指定的最小值？
            if [ "$number" -lt "$min" ] ; then
                echo "Your value is too small: smallest acceptable value is $min." >&2
                return 1
            fi
        fi
        if [ ! -z $max ] ; then
            # 输入值是否大于指定的最大值？
            if [ "$number" -gt "$max" ] ; then
                echo "Your value is too big: largest acceptable value is $max." >&2
                return 1
            fi
        fi
        return 0
    }