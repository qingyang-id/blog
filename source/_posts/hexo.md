---
title: Hexo + Next 搭建个人博客
date: 2018-09-12 10:02:31
categories: Hexo
tags: [Hexo, Next]
comments: false
---
突然有了写博客的想法，今天就研究了下如何搭建自己的博客，之后看到了比较流行的组合为Hexo + Next + Git pages，于事就一步步搭建了自己的博客，中间也踩了很多坑，因此想把这个经过记录下来，希望能帮到一些想搭建自己的博客的同志们。

# 为什么选择Hexo

[Hexo](https://hexo.io/zh-cn/) 是一个快速、简洁且高效的静态站点生成框架，它基于 [Node.js](https://nodejs.org/en/) 。 它有以下特点：

- <i class="fa fa-bolt"></i><h6 style="display: inline;">　超快速度</h6>
<i>Node.js 所带来的超快生成速度，让上百个页面在几秒内瞬间完成渲染。</i>
- <i class="fa fa-pencil"></i><h6 style="display: inline;">　支持Markdown</h6>
<i>Hexo 支持 GitHub Flavored Markdown 的所有功能，甚至可以整合 Octopress 的大多数插件。</i>
- <i class="fa fa-cloud-upload"></i><h6 style="display: inline;">　一键部署</h6>
<i>只需一条指令即可部署到Github Pages，或其他网站</i>
- <i class="fa fa-cog"></i><h6 style="display: inline;">　丰富的插件</h6>
<i>Hexo 拥有强大的插件系统，安装插件可以让 Hexo 支持 Jade, CoffeeScript。</i>


通过 Hexo 你可以轻松地使用 Markdown 编写文章，除了 Markdown 本身的语法之外，还可以使用 Hexo 提供的 [标签插件](https://hexo.io/zh-cn/docs/tag-plugins.html) 来快速的插入特定形式的内容。

基于 Hexo 这个优秀的博客框架，很多优秀的开发者奉献出了它们基于 Hexo 开发的[主题](https://hexo.io/themes/)。
[NexT](http://theme-next.iissnan.com/) 因其 <span id="yu-1">精于心，简于形</span> 的风格，一直被广大用户所喜爱。

<!-- more -->
# 环境要求
安装 Hexo 相当简单。然而在安装前，您必须检查电脑中是否已安装:

> [Node.js](https://nodejs.org/en/)
> [Git](http://git-scm.com/)

## 安装 Git
* Mac：一般情况下自带git无需安装，如未安装使用 [Homebrew](http://mxcl.github.com/homebrew/)，[MacPorts](http://www.macports.org/) 或下载 [安装程序](http://sourceforge.net/projects/git-osx-installer/) 安装
* Windows：下载安装 git 。<a id="download" href="https://git-scm.com/download/win"><i class="fa fa-download"></i><span> Download Now</span></a>

## 安装 Node.js
安装 Node.js 的最佳方式是使用 [nvm](https://github.com/creationix/nvm)。（nvm：Node Version Manager）
### Mac 下安装 nvm
1、执行如下命令，需要先安装Git
```bash
$ cd ~/
$ git clone https://github.com/creationix/nvm.git .nvm
```
2、将以下代码添加到 `~/.bashrc`, `~/.profile`, 或者 `~/.zshrc` 文件中，然后执行命令`source ~/.bashrc`重启配置信息
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```
### Windows 下安装 nvm
首先需要下载安装[nvm-windows](https://github.com/coreybutler/nvm-windows)，<a id="download" href="https://github.com/coreybutler/nvm-windows/releases"><i class="fa fa-download"></i><span> Download Now</span>
</a>

安装完nvm以后，我们可以打开命令行中执行命令
``` bash
$ nvm
$ nvm install latest
```

执行完以后，重启命令行，执行命令 `node -v` ，如果出现版本号，那么 `Node.js` 就安装成功了。
{% note warning %} 如果没有安装成功，那可能就是墙的原因。建议下载 `Node.js` 直接安装。 <a id="download" href="https://nodejs.org/en/download/"><i class="fa fa-download"></i><span> Download Now</span>
</a>{% endnote %}

# 安装 Hexo

有了 Node.js ，我们可以使用 npm 安装 Hexo。
``` bash
$ npm install -g hexo-cli
```
安装 Hexo 完成后，我们首先需要为我们的项目创建一个<span id="inline-green">指定文件夹</span>（例如我创建了一个文件夹blog 。`/Users/yq/blog` ），在指定文件夹中执行下列命令， Hexo 将会在指定文件夹中新建所需要的文件。
``` bash
$ hexo init
```
等待安装，安装完成后，<span id="inline-green">指定文件夹</span> 的目录如下：
```
.
├── _config.yml
├── package.json
├── scaffolds
├── source
|   ├── _drafts
|   └── _posts
└──
```

我们继续执行命令
``` bash
$ hexo g
$ hexo s --debug
```
Hexo 将 source 文件夹中除 _posts 文件夹之外，开头命名为 _(下划线)的文件 / 文件夹和隐藏的文件将会被忽略。Markdown 和 HTML 文件会被解析并放到 public 文件夹，而其他文件夹会被拷贝过去。
这个时候，我们在浏览器中访问 http://localhost:4000/ ，就可以看到基于 Hexo 的默认主题的原型：
{% asset_img images/hexo-default-theme.png Hexo default theme %}


# 安装 NexT 主题

## 1、下载 NexT 主题

依旧是在当前目录下，执行如下命令：
``` bash
$ git clone https://github.com/iissnan/hexo-theme-next themes/next
```
等待下载完成。
{% note warning %}在 Hexo 中有两份主要的配置文件，其名称都是 _config.yml 。其中，一份位于站点根目录下，主要包含 Hexo 本身的配置；另一份位于主题目录下，这份配置由主题作者提供，主要用于配置主题相关的选项。
  我们将前者称为 **站点配置文件**，后者称为 **主题配置文件**{% endnote %}

## 2、启用 NexT 主题
打开 **站点配置文件** ，找到 theme 字段，并将其值更改为 next 。
到此， NexT 主题安装完成。下一步我们将验证主题是否正确启用。在切换主题之后、验证之前，我们最好使用 `hexo clean` 来清除 Hexo 的缓存。

## 3、验证主题
首先启动 Hexo 本地站点，并开启调试模式（即加上 `--debug`），整个命令是 `hexo s --debug`。在服务启动的过程，注意观察命令行输出是否有任何异常信息。当命令行输出中提示：

``` bash
INFO  Hexo is running at http://0.0.0.0:4000/. Press Ctrl+C to stop.
```

此时即可使用浏览器访问 http://localhost:4000/ ，检查站点是否正确运行。

{% note success %} 当你看到站点的外观与下图所示类似时即说明你已成功安装 NexT 主题。这是 NexT 默认的 Scheme —— Muse{% endnote %}
{% asset_img images/hexo-next-theme.png NexT Muse theme %}
现在，我们已经成功安装并启用了 NexT 主题。

{% note primary %} 关于更多基本操作和基础知识，请查阅 [Hexo](https://hexo.io/zh-cn/) 与 [NexT](http://theme-next.iissnan.com/) 官方文档.{% endnote %}

# 发布到GitHub
## 创建新仓库
Github Pages分为两类，用户或组织主页，项目主页。

创建用户或组织主页，只需创建一个名称为{yourusername}.github.io的新仓库即可。这边的yourusername填写自己的用户名。Github会识别并自动将该仓库设为Github Pages。用户主页是唯一的，填其他名称只会被当成普通项目。
创建项目主页。先新建一个仓库，名称随意，或是使用原有的仓库都可以。在项目主页 -> Settings -> Options -> Github Pages中，将Source选项置为master branch(*如果无法设置就先选择一个主题*)，然后Save，这个项目就变成一个Github Pages项目了。

{% asset_img images/git-pages-setting.png %}

## 安装deploy插件
``` bash
$ npm install hexo-deployer-git --save
```

## 配置发布信息
修改主题配置文件中的仓库信息
``` bash
deploy:
  type: git
  repo: <repository url>  # 仓库地址，例如我的是https://github.com/yqsailor/yqsailor.github.io
  branch: [branch] # 仓库分支，一般为master
  message: [message]  # git提交注释，此项可留空
```

# 总结
## 本地调试步骤
三部曲：
``` bash
$ hexo clean
$ hexo g
$ hexo s --debug
```
这种带 debug 的运行，如果出现错误，可以在命令行中看到错误提示信息。

## 部署步骤
三部曲：
``` bash
$ hexo clean
$ hexo g
$ hexo d
```
当然在部署之前，需要先配置好配置文件中的 deploy。


## 常用命令
``` bash
$ hexo new "postName"  #新建文章
$ hexo new page "pageName" # 新建页面
$ hexo generate # 生成静态页面至public目录
$ hexo server # 开启预览访问端口(默认端口4000，'ctrl+c'关闭server)
$ hexo deploy # 项目部署
$ hexo help # 查看帮助
$ hexo version # 查看Hexo的版本
```

## 简写命令
``` bash
$ hexo new == hexo n
$ hexo generate == hexo g
$ hexo server == hexo s
$ hexo deploy == hexo d
```


## 常见问题1
在 hexo 的配置和设置文件中，在冒号后面没留空格会导致出问题：
正确的设置：
```
author: yq
email: yqsailor@gmail.com
language: zh-Hans
```

## 常见问题2
关于 Git 提交中用户名和 Email 的设置
```
git config --global user.name "Your name"
git config --global user.email "Your email"
```

## 常见问题3

Hexo 中的图标使用的是 [Font Awesome](http://fontawesome.io/) ，所以，我们的博客已经自带了 Font Awesome 中的所有图标，基本可以满足我们的所有需求，我们可以去 Font Awesome 中查找我们想要使用的图标。
<i class="fa fa-github"></i> `<i class="fa fa-github"></i>`
<i class="fa fa-github fa-lg"></i> `<i class="fa fa-github fa-lg"></i>`
<i class="fa fa-github fa-2x"></i> `<i class="fa fa-github fa-2x"></i>`

<h5 style="color:#f63;"><i>最后要说的是：</i></h5>
<p id="div-border-top-green"><i>[博客源码](https://github.com/yqsailor/blog) ， 欢迎 star
</i></p>
