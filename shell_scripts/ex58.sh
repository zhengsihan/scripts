#!/bin/bash
# weather -- 使用Wunderground API获取给定的邮政编码所在地的天气情况。

if [ $# -ne 1 ] ; then
    echo "Usage: $0 <zipcode>"
    exit 1
fi

apikey="*****" # 这不是真正的API密钥 -- 你得自己去申请。

weather=`curl -s "https://api.wunderground.com/api/$apikey/conditions/q/$1.xml"`
state=`xmllint --xpath //response/current_observation/display_location/full/text\(\) <(echo $weather)`
zip=`xmllint --xpath //response/current_observation/display_location/zip/text\(\) <(echo $weather)`
current=`xmllint --xpath //response/current_observation/temp_f/text\(\) <(echo $weather)`
condition=`xmllint --xpath //response/current_observation/weather/text\(\) <(echo $weather)`

echo $state" ("$zip") : Current temp "$current"F and "$condition" outside."

exit 0