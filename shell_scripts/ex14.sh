#!/bin/bash
# fmt -- 文本格式化使用工具，可用作nroff的包装器
# 加入两个使用选项： -w X，指定行宽； -h，允许连字符

while getopts "hw:" opt; do
    case $opt in
        h ) hyph=1 ;;
        w ) width="$OPTARG" ;;
    esac
done
shift $(($OPTIND -1))

nroff << EOF
.ll ${width:-72}
.na
.hy ${hyph:-0}
.pl 1
$(cat "$@")
EOF

exit 0