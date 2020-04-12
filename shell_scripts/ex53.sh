#!/bin/bash
# ftpget -- 解析ftp形式的URL并尝试通过匿名ftp下载文件。

anonpass="$LOGNAME@$(hostname)"

if [ $# -ne 1 ] ; then
    echo "Usage: $0 ftp://..." >&2
    exit 1
fi

# 典型的URL：ftp://ftp.ncftp.com/unixstuff/q2getty.tar.gz

if [ "$(echo $1 | cut -c1-6)" != "ftp://" ] ; then
    echo "$0: Malformed url. I need it to start with ftp://" >&2
    exit 1
fi

server="$(echo $1 | cut -d/ -f3)"
filename="$(echo $1 | cut -d/ -f4-)"
basefile="$(basename $filename)"

echo ${0}: Downloading $basefile from server $server

ftp -np << EOF
open $server
user ftp $anonpass
get "$filename" "$basefile"
quit
EOF

if [ $? -eq 0 ] ; then
    ls -l $basefile 
fi

exit 0