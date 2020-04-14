#/!bin/bash
# show CGIenv -- 显示该系统中CGI脚本所处的CGI运行时环境。

echo "Content-type: text/html"
echo ""

# 下面是实际信息......
echo "<html><body bgcolor=\"white\"><h2>CGI Runtime Environment</h2>"
echo "<pre>"
env || print env
echo "</pre>"
echo "<h3>Input stream is:</h3>"
echo "<pre>"
cat - 
echo "(end of input stream)</pre></body></html>"

exit 0