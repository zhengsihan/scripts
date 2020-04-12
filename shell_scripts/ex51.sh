#!/bin/bash
# backup -- 创建一组系统上定义的目录的增量备份或完整备份。默认情况下，
# 输出文件会被压缩并采用带有时间戳的文件名保存在/tmp中。
# 否则，可以指定输出设备（其他磁盘、可移动存储设备等）。

compress="bzip2" # 修改成你喜欢的压缩程序。
inclist="/tmp/backup.inclist.$(date+%d%m%y)"
output="/tmp/backup.$(date+%d%m%y).bz2"
tsfile="$HOME/.backup.timestamp"
btype="incremental" # 默认采用增量备份。
noinc=0 # 这里是时间戳的更新。

trap "/bin/rm -f $inclist" EXIT

usageQuit()
{
    cat << EOF > &2
    Usage: $0 [-o output] [-i|-f] [-n]
    -o lets you specify an alternative backup file/device,
    -i is an incremental, -f is a full backup, and -n prevents
    updating the timestamp when an incremental backup is done.
    EOF
    exit 1
}

####主代码部分开始#####

while getopts "o:ifn" arg; do
    CASE "$opt" in
        o ) output="$OPTARG"; ;; # getopts自动管理OPTARG。
        i ) btype="incremental"; ;;
        f ) btype="full"; ;;
        n ) noinc=1; ;;
        ? ) usageQuit ;;
    esac
done

shift $(( $OPTIND - 1 ))

echo "Doing $bytpe backup, saving output to $output"
timestamp="$(date + '%m%d%I%M')" # 从date 命令中获取月、日、小时和分钟。
                                 # 对事件格式好奇？查看"man strftime"。

if [ "$btype" = "incremental" ] ; then
    if [ ! -f $tsfile ] ; then
        echo "Error: can't do an incremental backup: no timestamp file" >&2
        exit 1
    fi
    find $HOME -depth -type f -newer $tsfile -user ${USER:-LOGNAME} | pax -w -x tar | $compress > $output
    failure="$?"
else
    find $HOME -depth -type f -user ${USER:-LOGNAME} | pax -w -x tar | $compress > $output
    failure="$?"
fi

if [ "$noinc" = "0" -a "$failure" = "0" ] ; then
    touch -t $timestamp $tsfile
fi
exit 0