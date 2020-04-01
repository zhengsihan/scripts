#!/bin/bash
    # inpath -- 验证制定程序是否有效，或者能否在PATH目录列表中找到

    in_path()
    {
        # 尝试在环境变量PATH中找到给定的命令。如果找到，返回0；
        # 如果没有找到，则返回1。注意，该函数会临时修改IFS（内部字段分隔符），
        # 不过在函数执行完毕时会将其恢复原状。

        cmd = $1
        ourpath = $2
        result = 1
        oldIFS = $oldIFS
        IFS = ":"

        for directory in $ourpath
        do
            if [ -x $directory/$cmd ] ; then
                result = 0    # 如果执行到此处，那么表明我们已经找到了该命令。
            fi
        done

        IFS = $oldIFS
        return $result
    }

    checkForCmdInPath()
    {
        var = $1

        if [ "$var" != "" ] ; then
            if[ "${var:0:1}" = "/" ] then
                if[ ! -x $var ] ; then
                    return 1
                fi
            elif ! in_path $var "$PATH" ; then
                return 2
            fi
        fi
    }