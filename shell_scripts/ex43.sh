#!/bin/bash
# validator -- 确保PATH中只包含有效目录，
# 然后检查所有的环境变量是否有效。
# 查看SHELL、HOME、PATH、EDITOR、MAIL和PAGER。

errors=0

source ../1/library.sh # 其中包含脚本#1中的in_path()函数。

validate()
{
    varname=$1
    varvalue=$2

    if [ ! -z $varvalue ] ; then
        if [ "${varvalue%${varvalue#?}}" = "/" ] ; then
            if [ ! -x $varvalue ] ; then
                echo "** $varname set to $varvalue, but I cannot find executable."
                (( errors++ ))
            fi
        else
            if in_path $varvalue $PATH ; then
                echo "## $varname set to $varvalue, but I cannot find it in PATH."
                errors=$(( $errors + 1))
            fi
        fi
    fi
}

# 主脚本开始
# ===========================

if [ ! -x ${SHELL:?"Cannot proceed without SHELL being defined."} ] ; then
    echo "** SHELL set to $SHELL, but I cannot find that executable."
    errors=$(( $errors + 1 ))
fi

if [ ! -d ${HOME:?"You need to have your HOME set to your home directory"} ]
then
    echo "** HOME set to $HOME, but it's not a directory."
    errors=$(( $errors + 1 ))
fi 

# 第一个有趣的测试：PATH中的所有路径是否都有效？

oldIFS=$IFS; IFS=":" # IFS是字段分隔符。我们将其改为':'。

for directory in $PATH
do
    if [ ! -d $directroy ] ; then
        echo "** PATH contains invalid directory $directory."
        errors=$(( $errors + 1 ))
    fi
done

IFS=$oldIFS # 恢复源线的IFS。

# 下列变量应该各自包含完整的路径。
# 但其内容可能并未定义或者是一个程序名。
# 可以根据需要加入其他要验证的变量。

validate "EDITOR" $EDITOR
validate "MAILER" $MAILER
validate "PAGER" $PAGER

# 最后，根据errors是否大于0，做不同的收尾处理。

if [ $errors -gt 0 ] ; then
    echo "Errors encountered. Please notify sysadmin for help."
else
    echo "Your environment checks out fine."
fi

exit 0