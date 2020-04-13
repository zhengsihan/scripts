#!/bin/bash
# zipcode -- 根据邮政编码，识别出对应的城市和州。
# 数据取自city-data.com，在该站点中，每个邮政编码都有自己的页面。

baseURL="http://www.city-data.com/zips"

/bin/echo -n "ZIP code $1 is in "

curl -s -dump "$baseURL/$1.xhtml" | grep -i '<title>' | cut -d\( -f2 | cut -d\) -f1