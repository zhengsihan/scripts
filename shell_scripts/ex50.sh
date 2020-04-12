#!/bin/bash
# rotatelogs -- 对/var/log中的日志文件进行滚动归档，确保文件大小不会时空。
# 该脚本使用了配置文件，允许定制每个文件的滚动频率。
# 配置文件采用的格式为： logfilename=duration，
# 其中，duration（时长）以天为单位。如果配置文件中缺少特定日志文件所对应的条目，
# rotatelogs则按照不低于7天的频率轮替该文件。如果时长被设置为0，那么脚本
# 会忽略对应的日志文件。

logdir="/var/log" # 你所在系统的日志文件目录可能不一样。
config="$logdir/rotatelogs.conf"
mv="/bin/mv"
default_duration=7 # 我们将默认的轮替方案设置为7天。
count=0

duration=$default_duration

if [ ! -f $config ] ; then
    # 脚本没有配置文件？退出。你也可以放心地删除这行测试，
    # 当配置文件丢失时，直接选择忽略定制。
    echo "$0: no config file found. Can't proceed." >&2
    exit 1
fi

if [ ! -w $logdir -o ! -x $logdir ] ; then
    # -w测试写权限，-x测试执行权限。你需要在Unix或Linux的日志目录下
    # 创建新文件。如果对日志目录没有这些权限，则失败。
    echo "$0: you don't have the appropriate permissions in $logdir" >&2
    exit 1
fi

cd $logdir

# 尽管我们也想在find中使用像:digit:这样标准的集合写法，但很多
# find版本并不支持 POSIX字符集合标识，所以只能用[0-9]。

# 这是一条颇为复杂的find语句，在本节中会进一步解释。
# 如果你好奇的话，请继续往下阅读！
for name in $(find . -maxdepth 1 -type f -size +0c ! -name '*[0-9]*' ! -name '\.*' ! -name '*conf' -print | sed 's/^\.\///')
do
    count=$(( $count + 1 ))

    #从配置文件中获取特定的日志文件所对应的条目。
    duration="$(grep "^${name}=" $config|cut -d= -f2)"

    if [ -z "$duration" ]; then
        duration=$default_duration # 如果找不到匹配，则使用默认值。
    elif [ "$duration" = "0" ] ; then
        echo "Duration set to zero: skipping $name"
        continue
    fi

    # 设置轮替文件名。非常简单：
    back1="${name}.1"
    back2="${name}.2"
    back3="${name}.3"
    back4="${name}.4"

    # 如果最近滚动的日志文件（back1）在特定期间内被修改，则不对其执行
    # 轮替操作。这样的文件可以使用find命令的-mtime测试选项找到。
    if [ -f "$back1" ] ; then
        if [ -z "$(find \"$back1\") - mtime +$duration -print 2>/dev/null" ]
        then
            echo -n "$name's most recent backup is more recent than $duration "
            echo "days: skipping" ; continue
        fi
    fi

    echo "Rotating log $name (using a $duration day schedule)"

    # 从最旧的日志文件开始轮替，不过要注意一个或多个文件不存在的情况。
    if [ -f "$back3" ] ; then
        echo "... $back3 -> $back4" ; $mv -f "$back3" "$back4"
    fi
    if [ -f "$back2" ] ; then
        echo "... $back2 -> $back3" ; $mv -f "$back2" "$back3"
    fi
    if [ -f "$back1" ] ; then
        echo "... $back1 -> $back2" ; $mv -f "$back1" "$back2"
    fi
    if [ -f "$name" ] ; then
        echo "... $name -> $back1" ; $mv -f "$name" "$back1"
    fi
    touch "$name"
    chmod 0600 "$name" # 最后一步：处于隐私考虑，将文件权限修改为rw-------
done

if [ $count -eq 0 ] ; then
    echo "Nothing to do: no log files big enough or old enough to rotate"
fi

exit 0