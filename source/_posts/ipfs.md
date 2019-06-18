---
title: IPFS
date: 2018-09-13 17:18:28
categories: Web
tags:
- IPFS
- Web
---
[IPFS](https://ipfs.io/)的全称是InterPlanetary File System星际文件系统，是一个点对点的网络超媒体协议。它的目标是成为更快、更安全、更开放的下一代互联网。
{% asset_img images/ipfs-cover.png %}

## IPFS介绍
### IPFS尝试解决HTTP目前存在的四个问题：
. 服务低效，成本高。这也是大部分P2P服务比中心化服务器优秀的地方。

. 网络服务受限于供应商，文件具有无法永久保存的风险，更无法历史回溯。

. 中心化的网络权力过于集中，网络控制和监管某些程度上限制了科技创新。

. 互联网服务大多依赖于骨干网络，一旦宕机大部分服务将无法使用。

### IPFS的野心是取代现在的HTTP，去创建一个全新的去中心化网络。
<!--more-->
在IPFS网络上，每个IPFS上的文件都具备一个唯一的哈希码。IPFS同时具备了文件去重和历史版本的功能，每个网络节点会存储自己感兴趣的内容，并且索引其它内容的位置，用户可以通过哈希码来寻找到每个文件的具体位置。此外IPFS本身还自带一个IPNS的域名，可以把你的内容和你的个人域名进行绑定。

## IPFS的下载与安装
可参考官网：https://ipfs.io/docs/install ，备注：目前需要科学上网才能访问

本文以mac环境下安装为例进行说明（mac下也可以用homebrew执行`brew install ipfs`进行安装），在terminal内输入以下命令进行下载与安装。本文时间(2018.9.13)的最新版本为v0.4.17，
```shell
  tar go-ipfs_v0.4.17_darwin-amd64.tar.gz
  cd go-ipfs
  ./install.sh
```
安装后使用help命令，可以测试是否成功。

`ipfs help`

### IPFS的启动
使用参考：https://ipfs.io/docs/getting-started

首先进行初始化，创建一个全局的本地仓库与配置文件。

`ipfs init`

然后需要开启IPFS的进程从而与网络保持连接状态。这里加上&是为了让进程在后台运行，可以在开启后同时按CTRL键C键回到之前界面。

`ipfs daemon &`

可以通过下面的命令查看我们在IPFS网络上已经连接的节点

`ipfs swarm peers`

## IPFS的使用
这里讲解一下hexo搭建的个人博客上传到IPFS网络上。hexo搭建个人博客请移步至hexo+next搭建个人博客，并发布到git pages

1、使用命令`ipfs id`查看你的电脑的ipfs id

2、修改全局配置_config.yml中的root为`/ipns/${ipfsId}`,其中的ipfsId为你电脑对应的ipfs id

3、在你的hexo搭建的博客根目录下执行如下命令打包生成对应的静态文件。

`hexo generate（hexo g也可以）`

4、通过ipfs add命令，直接把项目直接添加到IPFS网络。

`ipfs add -r public/`

{% asset_img images/ipfs-add.png %}

5、通过`ipfs name pulished`命令，把项目绑定到IPNS。

`ipfs name publish QmcmaC834fyeqXuxZmkKd2ukSLsZY5tprGffzCXrpKzAZ8`

 完成这一步后，你应该会在Terminal里看到如下运行结果，你的ipfs id标识了你的文件在网路上的位置。

`Published to 你的ipfs id: /ipfs/QmcmaC834fyeqXuxZmkKd2ukSLsZY5tprGffzCXrpKzAZ8`

6、现在你的文件已经在IPFS上了，网络为了避免垃圾资源过度的情况会在一段时间之后清空数据。为了保证我们的文件能够一直保持在IPFS网络上，我们需要执行pin命令，这样只要你的IPFS进程还开启着，数据就不会被垃圾回收。

`ipfs pin add -r QmcmaC834fyeqXuxZmkKd2ukSLsZY5tprGffzCXrpKzAZ8`

现在你的个人网站已经搭建在了一个完全去中心化的网络上了。你可以通过网址 https://gateway.ipfs.io/ipns/你的ipfsId 访问你的个人主页，也可以通过http://127.0.0.1:8080/ipns/你的ipfsId 。另外要注意的是，IPFS的网关目前需要科学上网才能连接，当然，在没有优化之前，访问会很慢，但可以打开。

7、 绑定独立域名
将博客发布到了IPFS运行的区块链节点上，但复杂的site_hash并不友好，我们可以使用IPNS技术，通过绑定独立域名来实现与现有的网站访问并无任何不一样的体现。我们假设你已经有一个可以正常使用的域名，如aa.com，没有域名的可以到任意域名服务商初购买。

有了域名之后，为域名aa.com添加TXT记录为**dnslink=/ipns/你的ipfsId**,同时将域名A记录指向任意ipfs节点的ip，如gateway.ipfs.io。

现在访问aa.com，你是不是发现已经可以正常访问你刚才生成的博客了。
