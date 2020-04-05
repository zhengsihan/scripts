#!/bin/bash
# validAlphaNum -- 确保输入内容仅限于字母和数字

validAlphaNum()
{
    # 返回值：如果输入内容全部都是字母和数字，那么返回0；否则，返回1.
    # 删除所有不符合要求的字符。
    validchars="$(echo $1 | sed -e 's/[^[:alnum:]]//g')"

    if [ "$validchars" = "$1" ] ; then
        return 0
    else
        return 1
    fi
}

# 主脚本开始 -- 如果要将该脚本包含到其他脚本之内，那么删除或注释掉本行以下的所有内容。
# ==================
/bin/echo -n "Enter input: "
read input

# 输入验证
if ! validAlphaNum "$input" ; then
    echo "Your input must consist of only letters and numbers." >&2
    exit 1
else
    echo "Input is valid."
fi

exit 0