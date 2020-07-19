#!/bin/bash
# trimmailbox -- 这个简单的脚本用于确保用户邮箱中保存最近的4封邮件。
# 适用于Berkeley Mail(也称为Mailx或mail)，其他邮件商则需要修改！

keep=4 # 默认只保留4封最近的邮件。

totalmsgs="$(echo 'x' | mail | sed -n '2p' | awk '{print $2}')"

if [ $totalmsgs -lt $keep ] ; then
    exit 0 # 什么都不做
fi

topmsg="$(( $ totalmsgs - $keep ))"

mail > /dev/null << EOF
d1-$topmsg
q
EOF

exit 0