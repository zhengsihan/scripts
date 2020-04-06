#!/bin/bash
    # scriptbc -- bc的包装器，可返回计算结果

    if ["$1" = "-p" ] ; then
        precision=$2
        shift 2
    else
        precision=2 # 默认精度。
    fi

    bc -q << EOF
        scale=$precision
        $*
        quit
    EOF

    exit 0