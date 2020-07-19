#!/bin/bash
# get stats -- 每隔n分钟，抓取一次netstat命令的输出（通过crontab）。

logfile="/Users/taylor/.netstatlog" # 根据实际情况修改配置。
temp="/tmp/getstats.$$.tmp"

trap "$(which rm) -f $temp" 0

if [ ! -e $logfile ] ; then # 第一次运行该脚本?
    touch $logfile
fi
( netstat -s -p tcp > $tmp

# 第一次运行时检查日志文件:有些版本的netstat输出不止一行
# 这就是为什么在这里要用到"| head -1" 。
sent="$(grep 'packets sent' $temp | cut -d\ -f1 | sed \
's/[^[:digit:]]//g' | head -1)"
resent="$(grep 'retransmitted' $temp | cut -d\ -f1 | sed \
's/[^[:digit:]]//g')"
received="$(grep 'packets received$' $temp | cut -d\ -f1 | \
sed 's/[^[:digit:]]//g')"
dupacks="$(grep 'duplicate acks' $temp | cut -d\ -f1 | \
sed 's/[^[:digit:]]//g')"
outoforder="$(grep 'out-of-order packets' $temp | cut -d \ -f1 | \
sed 's/[^[:digit:]]//g')"
connectreq="$(grep 'connection requests' $temp | cut -d\ -f1 | \
sed 's/[^[:digit:]]//g')"
connectacc="$(grep 'connection accepts' $temp | cut -d\ -f1 | \
sed 's/[^[:digit:]]//g')"
retmout="$(grep 'retransmit timeouts' $temp | cut -d\ -f1 | \
sed 's/[^[:digit:]]/g')"

/bin/echo -n "time=$(date +%s);"
/bin/echo -n "snt=$sent;re=$resent;rec=$received;dup=$dupacks;"
/bin/echo -n "oo=$outoforder;crep=$connectreq;cacc=$connectacc;"
echo "reto=$retmout"

) >> $logfile

exit 0