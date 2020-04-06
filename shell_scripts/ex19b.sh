#!/bin/sh
# locate -- 在locate的数据库中查找指定的样式

locatedb="/tmp/locate.db"

exec grep -i "$@" $locatedb