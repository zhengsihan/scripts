#!/bin/bash
# numberlines -- cat -n等具备类似功能命令的一个简单的替代品

for filename in "$@"
do
    linecount="1"
    while IFS="\n" read line
    do
        echo "${linecount}: $line"
        linecount="$(( $linecount + 1 ))"
    done
done
exit 0