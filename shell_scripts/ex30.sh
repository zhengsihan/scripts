#!/bin/bash
# newquota -- 可以处理全字选项的quota前端

# quota有3种选项： -g、-v和-q，该脚本也允许使用全字选项： --group、--verbose和--quiet

flags=""
realquota="$(which quota)"

while [ $# -gt 0 ]
do
    case $1
    in
        --help ) echo "Usage: $0 [--group --verbose --quiet -gvq]" >&2
                    exit 1 ;;
        --group ) flags="$flags -g"; shift ;;
        --verbose ) flags="$flags -v"; shift ;;
        --quiet ) flags="$flags -q"; shift ;;
        -- ) shift; break ;;
        * ) break; # 跳出while循环
    esac
done

exec $realquota $flags "$@"