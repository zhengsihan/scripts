#！/bin/bash
# docron -- 在日常时间有可能会关闭的系统上运行那些需要每天、每周、每月执行的系统cron作业。

rootcron="/etc/crontab" # 根据所使用的Unix或Linux版本的不同，这个路径会有很大差异。

if [ $# -ne 1 ] ; then
    echo "Usage: $0 [daily|weeekly|monthly]" >&2
    exit 1
fi 

# 该脚本只能由管理员运行。先前的脚本中测试了USER和LOGNAME，
# 但在此，我们直接检查用户ID。root的用户ID为0。

if [ "$(id -u)" -ne 0 ]
    # 或者也可以根据需要在这里使用$(whoami) != "root"。
    echo "$0: Command must be run as 'root'" >&2
    exit 1
fi

# 假设root用户拥有'daily'、'weekly'和'monthly'作业。
# 如果我们没有找到指定的匹配条目，则报错。如果存在匹配条目的话，
# 首先尝试获得对应的命令（这也是我想要的）。

jobs="$(awk "NF > 6 && /$1/ {for (i=7;i<=NF;i++) print \$i }" $rootcron)"

if [ -z "$job" ] ; then # 没有作业？真奇怪。好吧，这里出错了。
    echo "$0: Error: no $1 job found in $rootcron" >&2
    exit 1
fi

SHELL=$(which sh) # 与cron的默认设置一致。

eval $job # 作业完成后退出。