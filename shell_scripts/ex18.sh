#!/bin/bash
# formatdir -- 采用友好且实用的格式输出目录列表

# 注意，一定要确保scriptbc （脚本#9） 处于当前路径中，
# 因为在脚本中会多次调用到它

# 该函数将以KB为单位的文件大小格式化为KB、MB、GB，提高输出的可读性

readablesize()
{
    if [ $1 -ge 1048576 ] ; then
        echo "$(scriptbc -p 2 $1 / 1048576)GB"
    elif [ $1 -ge 1024 ] ; then
        echo "$(scriptbc -p 2 $1 / 1024)MB"
    else
        echo "${1}KB"
    fi

    #####################
    ## 主脚本

    if [ $# -gt 1 ] ; then
        echo "Usage: $0 [dirname]" >&2
        exit 1
    elif [ $# -eq 1 ] ; then # 指定了其他目录？
        cd "$@" # 切换到指定的目录
        if [ $? -ne 0 ] ; then # 如果指定目录不存在，则退出脚本
            exit 1
        fi
    fi

    for file in *
    do
        if [ -d "$file" ] ; then
            size=$(ls "$file" | wc -l | sed 's/[^[:digit:]]//g')
            if [ $size -eq 1 ] ; then
                echo "$file ($size entry)|"
            else
                echo "$file ($size entries)|"
            fi
        else
            size="$(ls -sk "$file" | awk '{print $1}')"
            echo "$file ($(readablesize $size))|"
        fi
    done | \
        sed 's/ /^^^/g' | \
        xargs -n 2 | \
        sed 's/\^\^\^/ /g' | \
        awk -F\| '{ printf "%-39s %-39s\n", $1, $2 }'
    
    exit 0
}