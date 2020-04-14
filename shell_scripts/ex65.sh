#!/bin/bash
# keviin-and-kell -- 动态建立Web页面，显示Bill Holbrook最新的四格漫画Kevin & Kell。
# <所引用的漫画已经得到了作者的许可>

month="$(date +%m)"
day="$(date +%d)"
year="$(date +%y)"

echo "Content-type: text/html"
echo ""

echo "<html><body bgcolor=white><center>"
echo "<table border=\"0\" cellpadding=\"2\" cellspacing=\"1\""
echo "<tr bgcolor=\"#000099\""
echo "<th><font color=white>Bill Holbrook's Kevin &amp; Kell</font></th></tr>"
echo "<tr><td><img "

# 典型的URL： http://www.kevinandkell.com/2016/strips/kk2016004.jpg
/bin/echo -n " src=\"http://www.kevinandkell.com/20${year}/"
echo "strips/kk20${year}${month}${day}.jpg\">"
echo "</td></tr><tr><td align=\"center\">"
echo "$copy; Bill Holbrook. Please see "
echo "<a href=\"http://www.kevinandkell.com/\">kenvinandkell.com</a>"
echo "for more strips, books, etc."
echo "</td></tr></table></center></body></html>"

exit 0