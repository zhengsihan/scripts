#!/bin/bash
# killall -- 向匹配指定进程名的所有进程发送特定信号。

# 默认情况下，脚本只杀死属于同一用户的进程，除非你是root。
# -s SIGNAL可以指定发送给进程的信号，-u USER可以指定用户，
# -t TTY可以指定tty，-n只报告操作结果，不报告具体过程。

signal="-INT" # 默认发送中断信号（SIGINT）。
user=""
tty=""
donothing=0

while getopts "s:u:t:n" opt; do
    case "$opt" in
        # 注意下面的技巧： 实际的kill命令需要的是-SIGNAL，
        # 但我们想要用户指定的是SIGNAL，所以要在前面加上"-"。
        s ) signal="-$OPTARG";
        u ) if [ ! -z "$tty" ] ; then
                # 逻辑错误：你不能同时指定用户和TTY设备。
                echo "$0: error: -u and -t are mutually exclusive." >&2
                exit 1
            fi
            user=$OPTARG;
        t ) if [ ! -z "$user" ] ; then
                echo "$0: error: -u and -t are mutually exclusive." >&2
                exit 1
            fi
            tty=$2;
        n ) donothing=1;
        ? ) echo "Usage: $0 [-s signal][-u user|-t tty] [-n] pattern" >&2
            exit 1
    esac
done

# getopts的选项处理完成......
shift $(( $OPTIND - 1 ))

# 如果用户没有指定任何起始参数（之前测试的是选项）。
if [ $# -eq 0 ] ; then
    echo "Usage: $0 [-s signal] [-u user|-t tty] [-n] pattern" >&2
    exit 1
fi

# 现在我们需要根据指定的TTY设备、指定用户，或者当前用户生成匹配进程的ID列表。
if [ ! -z "$tty" ] ; then
    pids=$(ps cu -t $tty | awk "/ $1$/ {print \$2 }")
elif [ ! -z "$user" ] ; then
    pids=$(ps cu -U $user | awk "/ $1$/ { print \$2 }")
else
    pids=$(ps cu -U ${USER:-LOGNAME} | awk "/ $1$/ { print \$2 }")
fi

# 没找到匹配的进程？这简单!
if [ -z "$pids" ] ; then
    echo "$0: no processes match pattern $1" >&2
    exit 1
fi

for pid in $pids
do
    # 向id为$pid的进程发送信号$signal：如果进程已经结束，或是用户没有
    # 杀死特定进程的权限，等等，那么kill命令可能会有所抱怨。不过没有关系，
    # 反正任务至少是完成了。
    if [ $donothing -eq 1 ] ; then
        echo "kill $signal $pid" # -n选项：“显示，但不执行”。
    else
        kill $signal $pid
    fi
done

exit 0