#!/bin/bash
# diskspace -- 汇总可用磁盘空间，以更合乎逻辑且易读的形式输出

tempfile="/tmp/available.$$"

trap "rm -f $tempfile" EXIT

cat << 'EOF' > $tempfile
    { sum += $4 }
END { mb = sum / 1024
        gb = mb /1024
        printf "%.0f MB (%.2fGB) of available disk space\n", mb, gb
    }

df -k | awk -f $tempfile

exit 0