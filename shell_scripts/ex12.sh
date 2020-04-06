#!/bin/bash
# 函数库测试脚本
# 先读入文件library.sh

. library.sh

initializeANSI #设置所有的ANSI转义序列

# 测试validint功能
echon "First off, do you have echo in your path? (1=yes, 2=no) "
read answer
while ! validint $answer 1 2 ; do
    echon "${boldon}Try again${boldoff}. Do you have echo "
    echon "in your path? (1=yes, 2=no) "
    read answer
done

# 测试checkForCmdInPath功能
if ! checkForCmdInPath "echo" ; then
    echo "Nope, can't find the echo command."
else
    echo "The echo command is in the PATH."
fi

echo ""
echon "Enter a year you think might be a leap year: "
read year

# 使用带有区间的validint测试指定年份是否在1到9999之间
while ! validint $year 1 1999 ; do
    echon "Please enter a year in the ${boldon}correct${boldoff} format: "
    read year
done

#测试是否为闰年
if isLeapYear $year ; then
    echo "${greenf}You're right! $year is a leap year.${reset}"
else
    echo "${redf}Nope, that's not a leap year.${reset}"
fi

exit 0