#!/bin/bash
# moviedata -- 根据电影或电视剧片名，返回匹配列表。
# 如果用户指定的是IMDb数字索引号，则返回影片简介。
# 数据取自Internet电影数据库。

titleurl="http://www.imdb.com/title/tt"
imdburl="http://www.imdb.com/find?s=tt&exact=true&ref_=fn_tt_ex&q="
tempout="/tmp/moviedata.$$"

summarize_file()
{
    # 生成精彩的影片简介。
    grep "<title>" $tempout | sed 's/<[^>]*>//g;s/(more)//'
    grep --color=never -A2 '<h5>Plot:' $tempout | tail -1 | cut -d\< -f1 | fmt | sed 's/^/   /'
    exit 0
}

trap "rm -f $tempout" 0 1 15

if [ $# -eq 0] ; then
    echo "Usage: $0 {movie title | movie ID}" >&2
    exit 1
fi

#######
# 检查是否指定的是IMDb片名编号。
nodigits="$(echo $1 | sed 's/[[:digit:]]*//g')"

if [ $# -eq 1 -a -z "$nodigits" ] ; then
    lynx -source "$titleurl$1/combined" > $tempout
    summarize_film
    exit 0
fi

############
# 未指定IMDb片名编号，继续搜索......
fixedname="$(echo $@ | tr ' ' '+')" # 处理URL。

url="$imdburl$fixedname"

lynx -source $imdburl$fixedname > $tempout

# 没有结果？
fail="$(grep --color=never '<h1 class="findHeader">No ' $tempout)"

# 匹配的片名是否不止一个......
if [ ! -z "$fail" ] ; then
    echo "Failed: no results found for $1"
    exit 1
elif [ ! -z "$(grep '<h1 class="findHeader">Displaying' $tempout)" ] ; then
    grep --color=never '/title/tt' $tempout | sed 's/</</g' | grep