#！/bin/bash
# remember -- 一个易用的命令行提醒工具

rememberfile="$HOME/.remember"

if [ $# -eq 0 ] ; then
    # 提醒用户输入并将输入信息追加到文件.remember中
    echo "Enter note, end with ^D: "
    cat - >> $rememberfile
else
    # 将传入脚本的参数追加到文件.remember中
    echo "$@" >> $rememberfile
fi

exit 0