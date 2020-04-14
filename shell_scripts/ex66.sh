#!/bin/bash
# getdope -- 获取_The Straight Dope_专栏的最新内容。
# 如果需要，可以再cron中设置为每天运行一次。

now="$(date +%y%m%d)"
start="http://www.straightdope.com/ "
to="testing@yourdomain.com" # 根据实际情况修改。

# 首先，获取专栏的URL。
URL="$(curl -s "$start" | grep -A1 'teaser' | sed -n '2p' | cut -d \" -f2 | cut -d\" -f1)"

# 现在，根据URL生成电子邮件。
( cat << EOF
Subject: The Straight Dope for $(date "+%A, %d %B, %Y")
From: Ceil Adams <dont@reply.com>
Content-type: text/html
To: $to

EOF

curl "$URL"
) | /usr/sbin/sendmail -t

exit 0