#!/bin/bash
# unrm -- 在已删除的文件归档中查找指定的文件或目录。如果有多个
# 匹配结果，则按时间戳排序，将结果列出，由用户指定要恢复哪个

archivedir="$HOME/.deleted-files"
realrm="$(which rm)"
move="$(which mv)"

dest=$(pwd)

if [ ! -d $archivedir ] ; then
    echo "$0: No deleted files directory: nothing to unrm" >&2
    exit 1
fi

# 如果没有提供参数，则只显示已删除文件的列表
if [ $# -eq 0 ] ; then
    echo "Contents of your deleted files archive (sorted by date):"
    ls -FC | sed -e 's/\([[:digit:]][[:digit:]]\.\)\{5\}//g' -e 's/^/ /'
    exit 0
fi

# 否则，就必须按用户指定的模式来处理。
# 让我们看看是否由多个匹配结果。

matches="$(ls -d *"$1" 2> /dev/null | wc -l)"

if [ $matches -eq 0 ] ; then
    echo "No match for \"$1\" in the deleted file archive." >&2
    exit 1
fi

if [ $matches -gt 1 ] ; then
    echo "More than one file or directory match in the archive:"
    index=1
    for name in$(ls -td *"$1")
    do
        datetime="$(echo $name | cut -c1-14 | awk -F. '{ print $5"/"$4 at "$3":"$2":"$1 }')"
        filename="$(echo $name | cut -c16-)"
        if [ -d $name ] ; then
            filecount="$(ls $name | wc -l | sed 's/[^[:digit:]]//g')"
            echo " $index) $filename (contents = ${filecount} items, deleted = $datetime)"
        else
            size="$(ls -sdk1 $name | awk '{print $1}')"
            echo " $index) $filename (size = ${size}Kb, deleted = $datetime)"
        fi
        index=$(( $index + 1 ))
    done
    echo ""
    echo -n "Which version of $1 do you want to restore ('0' to quit)? [1] : "
    read desired

    if [ ! -z "$(echo $desired | sed 's/[[:digit:]]//g')" ] ; then
        echo "$0: Restore canceled by user: invalid input." >&2
        exit 1
    fi

    if [ ${desired:=1} -ge $index ] ; then
        echo "$0: Restore canceled by user: index value too big." >&2
        exit 1
    fi

    if [ $desired -lt 1 ] ; then
        echo "$0: restore canceled by user." >&2
        exit 1
    fi

    restore="$(ls -tdl *"$1" | sed -n "${desired}p")"

    if [ -e "$dest/$1" ] ; then
        echo "\"$1\" already exists in this directory. Cannot overwrite." >&2
        exit 1
    fi

    echo -n "Restoring file \"$1\" ..."
    $move "$restore" "$dest/$1"
    echo "done."

    echo -n "Delete the additional copies of this file? [y] "
    read answer

    if [ ${answer:=y} = "y" ] ; then
        $realrm -rf *"$1"
        echo "edleted."
    else
        echo "additional copies retained."
    fi
else
    if [ -e "$dest/$1" ] ; then
        echo "\"$1\" already exists in this directory. Cannot overwrite." >&2
        exit 1
    fi

    restore ="$(ls -d *"$1")"
    echo -n "Restoring file \"$1\" ..."
    $move "$restore" "$dest/$1"
    echo "done."
fi

exit 0