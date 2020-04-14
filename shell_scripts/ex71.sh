#!/bin/bash
# apm -- Apache Password Manager (Apache密码管理器)允许管理员轻松地为Apache
# 配置中的子目录添加、更新或删除账户名和密码（目录中的配置文件叫做.htaccess）。

echo "Content-type: text/html"
echo ""
echo "<html><title>Apache Password Manager Utility</title><body>"

basedir=$(pwd)
myname=$(basename $0)
footer="$basedir/apm-footer.xhtml"
htaccess="$basedir/.htaccess"

htpasswd="$(which htpasswd) -b"

# 为安全起见，强烈建议你加入一下代码：
# 
# if [ "$REMOTE_USER" != "admin" -a -s $htpasswd ] ; then
#   echo "Error: You must be user <b>admin</b> to use APM."
#   exit 0
#fi

# 从.htaccess文件中获取密码文件名。
if [ ! -r "$htaccess" ] ; then
    echo "Error: cannot read $htaccess file."
    exit 1
fi

passwdfile="$(grep "AuthUserFile" $htaccess | cut -d\ -f2)"
if [ ! -r $passwdfile ] ; then
    echo "Error: can't read password file: can't make updates."
    exit 1
elif [ ! -w $ passwdfile ] ; then
    echo "Error: can't write to password file: can't update."
    exit 1
fi

echo "<center><h1 style='background:#ccf;border-radius:3px;border:1px solid #99c;padding:3px;'>"
echo "Apache Password Manager</h1>"

action="$(echo $QUERY_STRING | cut -c3)"
user="$(echo $QUERY_STRING|cut -d\& -f2|cut -d = -f2 | tr '[[:upper:]]' '[[:lower:]]')"

case "$action" in
    A ) echo "<h3>Adding New User <u>$user</u></h3>"
        if [ ! -z "$(grep -E "^${user}:" $passwdfile)" ] ; then
            echo "Error: user <b>$user</b> already appears in the file."
        else
            pass="$(echo $QUERY_STRING|cut -d\& -f3|cut -d= -f2)"
            if[ ! -z "$(echo $pass | tr -d '[[:uppser:][:lower:][:digit:]]')"] ; then
                echo "Error: passwords can only contain a-z A-Z 0-9 ($pass)"
            else
                $htpasswd $passwdfile "$user" "$pass"
                echo "Added!<br>"
            fi
        fi
        ;;
    U ) echo "<h3>Updating Password for user <u>$user</u></h3>"
        if [ -z "$(grep -E "^${user}:" $passwdfile)" ] ; then
            echo "Error: user <b>$user</b> isn't in the password file?"
            echo "searched for &quot;^${user}:&quot; in $passwdfile"
        else    
            pass="$(echo $QUERY_STRING | cut -d\& -f3 | cut -d = -f2)"
            if [ ! -z "$(echo $pass | tr -d '[[:uppser:][:lower:][:digit:]]')"] ; then
                echo "Error: passwords can only contain a-z A-Z 0-9 ($pass)"
            else
                grep -vE "^${user}:" $passwdfile | tee $passwdfile > /dev/null
                $htpasswd $passwdfile "$user" "$pass"
                echo "Updated!<br>"
            fi
        fi
        ;;
    D ) echo "<h3>Deleting User <u>$user</u></h3>"
        if [ -z "$(grep -E "^${user}:" $passwdfile)" ] ; then
            echo "Error: user <b>$user</b> isn't in the password file?"
        elif [ "$user" = "admin" ] ; then
            echo "Error: you can't delete the 'admin' account."
        else
            grep -vE "^${user}:" $passwdfile | tee $passwdfile >/dev/null
            echo "Deleted!<br>"
        fi
        ;;
esac

#总是列出密码文件中的当前用户......
echo "<br><br><table border='1' cellspacing='0' width='80%' cellpadding='3'>"
echo "<tr bgcolor='#cccccc'><th colspan='3'>List "
echo "of all current users</td></tr>"
oldIFS=$oldIFS
IFS=":" # 修改IFS......
while read acct pw ; do
    echo "<tr><th>$acct</th><td align=center><a href=\"$myname?a=D&u=$acct\">"
    echo "[delete]</a></td></tr>"
done < $passwdfile
echo "</table>"
IFS=$oldIFS # ......恢复IFS

# 建立包含所有账户名的下拉列表......
optiontring="$(cut -d: -f1 $passwdfile | sed 's/^/<option>/' | tr '\n' ' ')"
if [ ! -r $footer ] ; then
    echo "Warning: can't read $footer"
else
    # ......输出页脚
    sed -e "s/--myname--/$myname/g" -e "s/--options--/$optionstring/g" < $footer
fi

exit 0