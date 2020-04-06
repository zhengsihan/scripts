#!/bin/bash
# DIR -- 模拟DOS中的DIR命令，显示指定目录的内容，接受一些标准的DIR标志

function usage
{
    cat << EOF >&2
        Usage: $0 [DOS flags] directory or directories
        Where:
            /D      sort by columns
            /H      show help for this shell script
            /N      show long listing format with filenames on right
            /OD     sort by oldest to newest
            /O-D    sort by newest to oldest
            /P      pause after each screenful of information
            /Q      show owner of the file
            /S      recursive listing
            /W      use wide listing format
    EOF
    exit 1

    ###################
    ### 主脚本部分
    postcmd=""
    flags=""

    while [ $# -gt 0 ]
    do
        case $1 in
            /D ) flags="$flags -x" ;;
            /H ) usage ;;
            /[NQW] ) flags="$flags -l" ;;
            /OD ) flags="$flags -rt" ;;
            /O-D ) flags="$flags -t" ;;
            /P ) postcmd="more" ;;
            /S ) flags="$flags -s" ;;
            * ) # 未知标志：指定的DIR标志可能有错，所以退出while循环。
        esac
        shift # 处理标志。看看是否还有其他标志
    done

    # 标志处理完毕，接下来处理命令：

    if [ ! -z "$postcmd" ] ; then
        ls $flags "$@" | $postcmd
    else
        ls $flags "$@"
    fi

    exit 0
}