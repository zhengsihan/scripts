#!/bin/bash
# log-duckduckgo-search -- 记录下搜索请求的内容之后，再将其重定向到真正的DuckDuckGo搜索系统。

# 确保Web服务器对于logfile变量中所包含的目录路径和文件拥有写权限。
logfile="/var/www/wicked/scripts/searchlog.txt"

if [ ! -f $logfile ] ; then
    touch $logfile
    chmod a+rw $logfile
fi

if [ -w $logfile ] ; then 
    echo "$(date): $QUERY_STRING" | sed 's/q=//g;s/+/ /g' >> $logfile
fi

echo "Location: https://duckduckgo.com/html/?$QUERY_STRING"
echo ""

exit 0