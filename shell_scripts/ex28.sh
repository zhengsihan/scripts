#!/bin/bash
# toolong -- 只将输入流中超出指定长度的行传给fmt命令

width=72

if [ ! -r "$1" ] ; then
    echo "Cannot read file $1" >&2
    echo "Usage: $0 filename" >&2
    exit1
fi

while read input
do
    if [ ${#input} -gt $width ] ; then
        echo "$input" | fmt
    else
        echo "$input"
    fi
done < $1

exit 0