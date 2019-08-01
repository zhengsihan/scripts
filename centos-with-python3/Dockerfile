FROM    centos:7.6.1810
MAINTAINER      Minus "zhengsihan.gz@outlook.com"

RUN     /bin/echo 'root:123456' |chpasswd
RUN     useradd zsh
RUN     /bin/echo 'zsh:123456' |chpasswd
RUN     /bin/echo -e "LANG=\"en_US.UTF-8\"" >/etc/default/local
EXPOSE  22
EXPOSE  80
CMD     /usr/sbin/sshd -D

#下载python3的依赖库
RUN yum install -y openssl-devel bzip2-devel expat-devel gdbm-devel readline-devel sqlite-devel gcc cc wget make libffi-devel

RUN cd /
RUN wget https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tgz
RUN wget https://raw.githubusercontent.com/zhengsihan/zsh-scripts/master/CentOS_7.6.1810/urlgrabber-ext-down
RUN wget https://raw.githubusercontent.com/zhengsihan/zsh-scripts/master/CentOS_7.6.1810/yum

RUN mkdir /usr/local/python3 -p
RUN tar xf Python-3.7.2.tgz
RUN sh Python-3.7.2/configure --prefix=/usr/local/python3
RUN make
RUN make install

#备份旧版python软链接，链接新版本python
#ls -l /usr/bin/python
#ls -l /usr/bin/python2
#ls -l /usr/bin/python2.7

#把python2的软链接链接到python3
RUN mv /usr/bin/python /usr/bin/python2.bak
RUN ln -s /usr/local/python3/bin/python3 /usr/bin/python
RUN ln -s /usr/local/python3/bin/pip3 /usr/bin/pip

#因为上面已经把python默认指向了python3，而yum需要python2.7支持，所以以下两个文档，第一行python改为python2.7；
#另外，权限也要修改，跟原先一致，否则会权限permission denied
#/usr/bin/yum
#/usr/libexec/urlgrabber-ext-down
RUN rm -rf /usr/bin/yum
RUN cp /yum /usr/bin/yum
RUN chmod -R 755 /usr/bin/yum

RUN rm -rf /usr/libexec/urlgrabber-ext-down
RUN cp /urlgrabber-ext-down /usr/libexec/urlgrabber-ext-down
RUN chmod -R 755 /usr/libexec/urlgrabber-ext-down
