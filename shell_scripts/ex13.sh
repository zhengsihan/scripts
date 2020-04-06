#!/bin/bash
# hilow -- 一个简单的猜数游戏

biggest=100 # 可能的最大数
guess=0 # 玩家猜测的数
guesses=0 # 猜测的次数
number=$(( $$ % $biggest )) # 1到$biggest之间的随机数
echo "Guess a number between 1 and $biggest"

while [ "$guess" -ne $number ] ; do
    /bin/echo -n "guess？ " ; read answer
    if [ "$guess" -lt $number ] ; then
        echo "... bigger!"
    elif [ "$guess" -gt $number ] ; then
        echo "... smaller!"
    fi
    gueses=$(( $guesses + 1 ))
done

echo "Right!! Guessed $number in $guesses guesses."

exit 0