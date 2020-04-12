#!/bin/bash
# githubuser -- 根据指定的GitHub用户名，获取该用户的信息。

if [ $# -ne 1 ] ; then
    echo "Usage: $0 <username>"
    exit 1
fi

# -s选项可以禁止curl正常的详细信息输出。
curl -s "https://api.github.com/users/$1" | \
        awk -F '"' '
            /\"name\":/ {
                print $4" is the name of the Github user."
            }
            /\"followers\":/{
                split($3, a, " ")
                sub(/,/, "", a[2])
                print "They have "a[2]" followers."
            }
            /\"following\":/{
                split($3, a, " ")
                sub(/./, "", a[2])
                print "They are following "a[2]" other users."
            }
            /\"created_at\":/{
                print "Their account was created on "$4"."
            }
            '
exit 0