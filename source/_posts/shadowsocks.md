---
title: Linux 搭建 Shadowsocks VPN服务
date: 2019-06-18 17:00:01
categories: 工具
tags: [Shadowsocks, Linux]
---
# 前言

公司的VPN被封了，因此就注册了AWS，搭建自己的shadowsocks代理服务器，实现科学上网。AWS为新用户提供了一年每月750小时和30G流量的1核1G服务器，当然也可以选择google云，也为新用户提供了一年的免费试用。

# 安装PIP

## Debian/Ubuntu下使用

本教程使用Python 3为载体，因Python 3对应的包管理器pip3并未预装，首先安装pip3：

Ubuntu16 安装pip
```
sudo apt install python3-pip
```

Ubuntu18 安装pip
```
sudo apt-get update

sudo apt-get install python3-pip
```

## Centos下使用
```
sudo yum install -y epel-release
sudo yum install python3-pip
```
<!--more-->

# 安装Shadowsocks

因Shadowsocks作者不再维护pip中的Shadowsocks（定格在了2.8.2），我们使用下面的命令来安装最新版的Shadowsocks：

```bash
sudo pip3 install --upgrade git+https://github.com/shadowsocks/shadowsocks.git@master
```

安装完成后可以使用下面这个命令查看Shadowsocks版本：

```bash
sudo ssserver --version
```
目前会显示“Shadowsocks 3.0.0”。

# 创建配置文件
创建Shadowsocks配置文件所在文件夹：

```bash
sudo mkdir /etc/shadowsocks
```

然后创建配置文件：
```bash
sudo vi /etc/shadowsocks/config.json
```
复制粘贴如下内容（注意修改密码“password”）：
```json
{
    "server":"0.0.0.0",
    "server_port":8388,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"123456",
    "timeout":300,
    "method":"chacha20",
    "fast_open": false
}
```
"server" ；服务器IP，不用更改
"server_port" ；服务器端口，即用于给用户连接的端口，范围0-65535，任选一个端口，只要不与常用端口冲突就行，不过不推荐使用80\443等网站用端口，也不推荐大多数ss的默认端口8388
"local_address" ；本机地址，不用更改
"local_port" ；本地端端口，不用更改
"password" ；账户的密码
"timeout" ；超时时间（秒），不用改
"method" ；加密方式，推荐用 chacha20 ，不用默认的 rc4-md5 或者 aes-256-cfb，因为默认的太多人用，容易被墙
"fast_open" ；true 或 false。如果服务器 Linux 内核在 3.7+，可以开启 fast_open 以降低延迟。开启方法： echo 3 > > /proc/sys/net/ipv4/tcp_fastopen 开启之后，将 fast_open 的配置设置为 true 即可
多个账号：
```json
{  
    "server":"0.0.0.0",  
    "port_password":{  
     "8381":"xxx",  // xxx为端口对应的密码 
     "8382":"xxx",  
     "8383":"xxx",  
     "8384":"xxx"  
     },  
    "local_address": "127.0.0.1",
    "local_port":1080,
    "timeout":300,  
    "method":"chacha20",  
    "fast_open": false  
}
```

# 测试Shadowsocks配置
启动shadowsocks
```bash
ssserver -c /etc/shadowsocks/config.json
```
在Shadowsocks客户端添加服务器，如果你使用的是我提供的那个配置文件的话，地址为服务器外网IP，端口号为8388，加密方法为chacha20，密码为你设置的密码。然后设置客户端使用全局模式，浏览器登录Google试试应该能直接打开了。

这时浏览器访问[ip138](http://ip138.com)就会显示Shadowsocks服务器的IP啦！

测试完毕，按Ctrl + C关闭Shadowsocks。

如果无法使用，可能是端口未开放，防火墙需开放8388端口

# 配置Systemd管理Shadowsocks
新建Shadowsocks管理文件

```Bash
sudo vim /etc/systemd/system/shadowsocks-server.service
```
复制粘贴：
```bash
[Unit]
Description=Shadowsocks Server
After=network.target

[Service]
ExecStart=/usr/local/bin/ssserver -c /etc/shadowsocks/config.json
Restart=on-abort

[Install]
WantedBy=multi-user.target
```

保存文件并退出。

启动Shadowsocks：

```Bash
sudo systemctl start shadowsocks-server
```

设置开机启动Shadowsocks：

```Bash
sudo systemctl enable shadowsocks-server
```

查看Shadowsocks状态：

```Bash
sudo systemctl status shadowsocks-server
```

至此，Shadowsock服务器端的基本配置已经全部完成了！


# 优化
这部分属于进阶操作，在你使用Shadowsocks时感觉到延迟较大，或吞吐量较低时，可以考虑对服务器端进行优化。

## 开启BBR
BBR系Google最新开发的TCP拥塞控制算法，目前有着较好的带宽提升效果，甚至不比老牌的锐速差。

## 升级Linux内核
BBR在Linux kernel 4.9引入。首先检查服务器kernel版本：

```Bash
uname -r
```
如果其显示版本在4.9.0之下，则需要升级Linux内核，否则请忽略下文。

更新包管理器：

```Bash
sudo apt update
```
查看可用的Linux内核版本：

```Bash
sudo apt-cache showpkg linux-image
```
找到一个你想要升级的Linux内核版本，如“linux-image-4.10.0-22-generic”：

```Bash
sudo apt install linux-image-4.10.0-22-generic
```
等待安装完成后重启服务器：

```Bash
sudo reboot
```
删除老的Linux内核：

```Bash
sudo purge-old-kernels
```
开启BBR
运行lsmod | grep bbr，如果结果中没有tcp_bbr，则先运行：

```Bash
modprobe tcp_bbr
echo "tcp_bbr" >> /etc/modules-load.d/modules.conf
```
运行：

```Bash
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
```
运行：

```Bash
sysctl -p
```
保存生效。运行：

```Bash
sysctl net.ipv4.tcp_available_congestion_control
sysctl net.ipv4.tcp_congestion_control
```
若均有bbr，则开启BBR成功。

优化吞吐量
新建配置文件：

```Bash
sudo nano /etc/sysctl.d/local.conf
```
复制粘贴：
```bash
# max open files
fs.file-max = 51200
# max read buffer
net.core.rmem_max = 67108864
# max write buffer
net.core.wmem_max = 67108864
# default read buffer
net.core.rmem_default = 65536
# default write buffer
net.core.wmem_default = 65536
# max processor input queue
net.core.netdev_max_backlog = 4096
# max backlog
net.core.somaxconn = 4096

# resist SYN flood attacks
net.ipv4.tcp_syncookies = 1
# reuse timewait sockets when safe
net.ipv4.tcp_tw_reuse = 1
# turn off fast timewait sockets recycling
net.ipv4.tcp_tw_recycle = 0
# short FIN timeout
net.ipv4.tcp_fin_timeout = 30
# short keepalive time
net.ipv4.tcp_keepalive_time = 1200
# outbound port range
net.ipv4.ip_local_port_range = 10000 65000
# max SYN backlog
net.ipv4.tcp_max_syn_backlog = 4096
# max timewait sockets held by system simultaneously
net.ipv4.tcp_max_tw_buckets = 5000
# turn on TCP Fast Open on both client and server side
net.ipv4.tcp_fastopen = 3
# TCP receive buffer
net.ipv4.tcp_rmem = 4096 87380 67108864
# TCP write buffer
net.ipv4.tcp_wmem = 4096 65536 67108864
# turn on path MTU discovery
net.ipv4.tcp_mtu_probing = 1

net.ipv4.tcp_congestion_control = bbr
```
运行：

```Bash
sysctl --system
```
编辑之前的shadowsocks-server.service文件：

```Bash
sudo nano /etc/systemd/system/shadowsocks-server.service
```
在ExecStart前插入一行，内容为：

```bash
ExecStartPre=/bin/sh -c 'ulimit -n 51200'
```
即修改后的shadowsocks-server.service内容为：
```bash
[Unit]
Description=Shadowsocks Server
After=network.target

[Service]
ExecStartPre=/bin/sh -c 'ulimit -n 51200'
ExecStart=/usr/local/bin/ssserver -c /etc/shadowsocks/config.json
Restart=on-abort

[Install]
WantedBy=multi-user.target
```
Ctrl + O保存文件，Ctrl + X退出。

重载shadowsocks-server.service：

```Bash
sudo systemctl daemon-reload
```
重启Shadowsocks：

```Bash
sudo systemctl restart shadowsocks-server
```
开启TCP Fast Open
TCP Fast Open可以降低Shadowsocks服务器和客户端的延迟。实际上在上一步已经开启了TCP Fast Open，现在只需要在Shadowsocks配置中启用TCP Fast Open。

编辑config.json：

```Bash
sudo nano /etc/shadowsocks/config.json
```
将fast_open的值由false修改为true。Ctrl + O保存文件，Ctrl + X退出。

重启Shadowsocks：

```Bash
sudo systemctl restart shadowsocks-server
```
注意：TCP Fast Open同时需要客户端的支持，即客户端Linux内核版本为3.7.1及以上；你可以在Shadowsocks客户端中启用TCP Fast Open。

至此，Shadowsock服务器端的优化已经全部完成了！
