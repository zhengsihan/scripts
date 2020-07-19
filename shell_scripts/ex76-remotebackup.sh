#!/bin/bash
# remotebackup -- 接受文件和目录列表，创建一个压缩归档，然后
# 将其通过电子邮件发送到远程归档站点保存。它旨在每晚针对重要
# 的用户文件运行，不过并未试图取代更为严格的备份方案。

outfile="/tmp/rb.$$.tgz"
outfname="backup.$(date +%y%m%d).tgz"
infile="/tmp/rb.$$.in"

trap "$(which rm) -f $outfile $infile" 0

if [ $# -ne 2 -a $# -ne 3 ] ; then
    echo "Usage: $(basename $0) backup-file-list remoteaddr {targetdir}" >&2
    exit 1
fi

if [ ! -s "$1" ] ; then
    echo "Error: backup list $1 is empty or missing" >&2
    exit 1
fi

# 扫描归档的文件列表项，将处理后的文件列表保存在$infile中。
# 在处理过程中，会扩展通配符，使用反斜线转义文件名中的空格，
# "this file"会被修改成this\ file,所以也就用不着引号了。

while read entry; do
    echo "$entry" | sed -e 's/ /\\ /g' >> $infile
done < "$1"

#创建归档、编码并发送
 tar czf - $(cat $infile) | \
    uuencode $outfname | \
    mail -s "${3:-Backup archive for $(date)}" "$2"

echo "Done. $(basename $0) backed up the following files:"
sed 's/^/    /' $infile
echo -n "and mailed them to $2 "
if [ ! -z "$3" ] ; then
    echo "with requestd target directory $3"
else
    echo ""
fi

exit 0