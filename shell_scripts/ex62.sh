#!/bin/bash
# changetrack -- 跟踪指定的URL，如果自上次访问后出现了更新，
# 则将新的页面通过电子邮件发送到特定的地址。

sendmail=$(which sendmail)
sitearchive="/tmp/changetrack"
tmpchanges="$sitearchive/changes.$$" # 临时文件
fromaddr="webscraper@intuitive.com"
dirperm=755 # 为目录属主设置“读/写/执行”权限
fileperm=644 # 为文件属主设置“读写”权限，为其他用户设置只读权限

trap "$(which rm) -f $tmpchanges" 0 1 15 # 退出脚本时删除临时文件。

if [ $# -ne 2 ] ; then
    echo "Usage: $(basename $0) url email" >&2
    echo "  tip: to have changes displayed on screen, use email addr '-'" >&2
    exit 1
fi

if [ ! -d $sitearchive ] ; then
    if ! mkdir $sitearchive ; then
        echo "$(basename $0) failed: couldn't create $sitearchive." >&2
        exit 1
    fi
    chmod $dirperm $sitearchive
fi

if [ "$(echo $1 | cut -c1-5)" != "http:" ] ; then
    echo "Please use fully qualified URLs (e.g. start with 'http://')" >&2
    exit 1
fi

fname="$(echo $1 | sed 's/http:\/\///g' | tr '/?&' '...')"
baseurl="$(echo $1 | cut -d/ -f1-3)/"

# 抓取页面副本并将其放入归档文件。注意，我们只通过查看页面内容
# （使用选项-dump，而不是-source）来跟踪更新，所以不需要解析HTML......

lynx -dump "$1" | uniq > $sitearchive/${fname}.new
if [ -f "$sitearchive/$fname" ] ; then
    # 我们以前已经访问过该站点，所以现在要比较两次访问之间的差异。
    diff $sitearchive/$fname $sitearchive/${fname}.new > $tmpchanges
    if [ -s $tmpchanges ] ; then
        echo "Status: Site $1 has changed since our last check."
    else
        echo "Status: No changes for site $1 since last check."
        rm -f $sitearchive/${fname}.new # 没有更新......
        exit 0 # 没有变化 -- 退出脚本
    fi
else
    echo "Status: first visit to $1. Copy archived for future analysis."
    mv $sitearchive/${fname}.new $sitearchive/$fname
    chmod $fileperm $sitearchive/$fname
    exit 0
fi

# 如果脚本执行到此处，说明站点已经更新，我们需要将.new文件内容发送给
# 用户，然后使用.new文件替换掉旧的站点快照，以便下次调用脚本时使用。

if [ "$2" != "-" ] ; then
(
    echo "Content-type: text/html"
    echo "From: $fromaddr (Web Site Change Tracker)"
    echo "Subject: Web Site $1 Has Changed"
    echo "To: $2"
    echo ""

    lynx -s -dump $1 | \
            sed -e "s|src=\"|SRC=\"$baseurl|gi" \
                -e "s|href=\"|HREF=\"$baseurl|gi" \
                -e "s|$baseurl\/http:|http:|g"
) | sendmail -t
else
    # 只在屏幕上显示差异也太难看了。有没有解决方法？
    diff $sitearchive/$fname $sitearchive/${fname}.new
fi

# 更新站点保存的快照。
mv $sitearchive/${fname}.new $sitearchive/$fname
chmod 755 $sitearchive/$fname
exit 0