#!/bin/bash
# cgrep -- 能够显示上下文并高亮匹配模式的grep

context=0
esc="$["
boldon="${esc}[1m"
boldoff="${esc}[22m"
sedscript="/tmp/cgrep.sed.$$"
tempout="/tmp/cgrep.$$"

function showMatches
{
    matches=0

    echo "s/$pattern/${boldon}$pattern${boldoff}/g" > $sedscript

    for lineno in $(grep -n "$pattern" $1 | cut -d: -f1)
    do
        if [ $context -gt 0 ] ; then
            prev="$(( $lineno - $context ))"

            if [ $prev -lt 1 ] ; then`
                # 这会导致"invalid usage of line address 0."
                priv="1"
            fi
            next="$(( $lineno + $context ))"

            if [ $matches -gt 0 ] ; then
                echo "${prev}i\\" >> $sedscript
                echo "----" >> $sedscript
            fi
            echo "${prev},${next}p" >> $sedscript
        else
            echo "${lineno}p" >> $sedscript
        fi
        matches="$(( $matches + 1 ))"
    done

    if [ $matches -gt 0 ] ; then
        sed -n -f $sedscript $1 | uniq | more
    fi
}

trap "$(which rm) -f $tempout $sedscript" EXIT

if [ -z "$1" ] ; then
    echo "Usage: $0 [-c X] pattern {filename}" >&2
    exit 0
fi

if [ "$1" = "-c" ] ; then
    context="$2"
    shift; shift
elif [ "$(echo $1 | cut -c1-2)" = "-c" ] ; then
    context="$(echo $1 | cut -c3-)"
    shift
fi

pattern="$1"; shift

if [ $# -gt 0 ] ; then
    for filename ; do
        echo "----- $filename -----"
        showMatches $filename
    done
else
    cat - > $tempout # 将输入保存到临时文件中
    showMatches $tempout
fi

exit 0