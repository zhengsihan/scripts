#!/bin/bash
# convertatemp -- 温度转换脚本。用户可以输入采用特定单位（华氏单位、摄氏单位或开尔文单位）
# 的温度，脚本会输出其对应于其他两种单位的温度。

if [ $# -eq 0 ] ; then
    cat << EOF >&2
    Usage: $0 temperature[F|C|K]
    where the suffix:
        F   indicates input is in Fahrenheit (default)
        C   indicates input is in Celsius
        K   indicates input is in Kelvin
    EOF
        exit 1
fi

unit="$(echo $1|sed -e 's/[-[:digit:]]*//g' | tr '[:lower:]' '[:upper:]' )"
temp="$(echo $1|sed -e 's/[^-[:digit:]]*//g')"

case ${unit:=F}
in
F ) # 华氏温度转换为摄氏温度的公式： Tc = (F - 32) / 1.8
    farn="$temp"
    cels="$(echo "scale=2;($farn - 32) / 1.8" | bc)"
    kelv="$(echo "scale=2;$cels + 273.15" | bc)"
    ;;

C ) # 摄氏温度转换为华氏温度的公式： Tf = (9/5)*Tc+32
    cels=$temp
    kelv="$(echo "scale=2;$cels + 273.15" | bc)"
    farn="$(echo "scale=2;(1.8 * $cels) + 32" | bc)"
    ;;

K ) # 摄氏温度 = 开尔文温度 - 273.15，然后使用摄氏温度转换为华氏温度的公式
    kelv=$temp
    cels="$(echo "scale=2; $kelv - 273.15" | bc)"
    farn="$(echo "scale=2; (1.8 * $cels) + 32" | bc)"
    ;;

* )
    echo "Given temperature unit is not supported"
    exit 1
esac

echo "Fahrenheit = $farn"
echo "Celsius = $cels"
echo "Kelvin = $kelv"

exit 0