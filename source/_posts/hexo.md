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
[NexT](http://theme-next.iissnan.com/) 因其 {% label info@精于心，简于形 %} 的风格，一直被广大用户所喜爱。

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
{% note warning %} 
如果没有安装成功，那可能就是墙的原因。建议下载 `Node.js` 直接安装。 <a id="download" href="https://nodejs.org/en/download/"><i class="fa fa-download"></i><span> Download Now</span>
</a>
{% endnote %}

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
$ git clone https://github.com/theme-next/hexo-theme-next themes/next
```
等待下载完成。
{% note warning %}
在 Hexo 中有两份主要的配置文件，其名称都是 _config.yml 。其中，一份位于站点根目录下，主要包含 Hexo 本身的配置；另一份位于主题目录下，这份配置由主题作者提供，主要用于配置主题相关的选项。
  我们将前者称为<span id="inline-green">站点配置文件</span>，后者称为<span id="inline-purple">主题配置文件</span>
  {% endnote %}

## 2、启用 NexT 主题
打开<span id="inline-green">站点配置文件</span>，找到 theme 字段，并将其值更改为 next 。
到此， NexT 主题安装完成。下一步我们将验证主题是否正确启用。在切换主题之后、验证之前，我们最好使用 `hexo clean` 来清除 Hexo 的缓存。

## 3、验证主题
首先启动 Hexo 本地站点，并开启调试模式（即加上 `--debug`），整个命令是 `hexo s --debug`。在服务启动的过程，注意观察命令行输出是否有任何异常信息。当命令行输出中提示：

``` bash
INFO  Hexo is running at http://0.0.0.0:4000/. Press Ctrl+C to stop.
```

此时即可使用浏览器访问 http://localhost:4000/ ，检查站点是否正确运行。

{% note success %}
当你看到站点的外观与下图所示类似时即说明你已成功安装 NexT 主题。这是 NexT 默认的 Scheme —— Muse
{% endnote %}
{% asset_img images/hexo-next-theme.png NexT Muse theme %}
现在，我们已经成功安装并启用了 NexT 主题。

{% note primary %}
关于更多基本操作和基础知识，请查阅 [Hexo](https://hexo.io/zh-cn/) 与 [NexT](http://theme-next.iissnan.com/) 官方文档.
{% endnote %}

# Local Search 配置

添加百度/谷歌/本地 自定义站点内容搜索

1. 安装 `hexo-generator-searchdb`，在站点的根目录下执行以下命令：

 ```
npm install hexo-generator-searchdb --save
```

2. 编辑<span id="inline-green">站点配置文件</span>，新增以下内容到任意位置：
```
search:
  path: search.xml
  field: post
  format: html
  limit: 10000
```

3. 编辑<span id="inline-purple">主题配置文件</span>，启用本地搜索功能：
```
local_search:
  enable: true
```

# 插件

这些功能之前是使用修改源代码方式，现在可以使用 “包/插件引入 + 选项配置” 的方式激活该功能。

> 插件路径定义在 themes\next\source\lib 目录下。

| 功能 | 插件 | 引入方式 | 配置项 |
| :-----  | :---- | :---- | :---- |
|字数统计	           |  [hexo-symbols-count-time](https://github.com/theme-next/hexo-symbols-count-time) |	包 | heme.symbols_count_time |
|图片浏览 | [theme-next-fancybox3](https://github.com/theme-next/theme-next-fancybox3)	| 插件 | theme.fancybox |
|顶部进度条 | [theme-next-pace](https://github.com/theme-next/theme-next-pace)	| 插件 | theme.pace  |
|leancloud访问计数	 | [leancloud-visitors](https://github.com/theme-next/hexo-leancloud-counter-security)	| 插件	| theme.leancloud_visitors |
|canvas-nest线条动画	 | [canvas-nest](https://github.com/theme-next/theme-next-canvas-nest)	| 插件	| theme.canvas_nest |

*1.引入方式*

以包方式引入比较简单，使用 命令 npm install <package-name> -save 即可。

以插件方式引入，在 `theme\next` 目录使用代码克隆命令。
```
git clone <github-url> source\lib\<plugin-name>
```

> canvas-next 将配置文件中颜色改为：0,0,0

*2.进度条*

进度条使用 [pace.js](https://github.hubspot.com/pace/) 插件，[点此](https://github.hubspot.com/pace/docs/welcome/) 查看每个配置的效果图。

# 鼠标点击小红心的设置
1. 将 [love.js](https://github.com/yqsailor/yqsailor.github.io/tree/master/js/love.js) 文件添加到 \themes\next\source\js 文件目录下。
2. 找到 `\themes\next\layout\_layout.swing` 文件， 在文件的后面，`</body>` 标签之前 添加以下代码：
```html
<!-- 页面点击小红心 -->
<script type="text/javascript" src="/js/love.js"></script>
```

# 修改文章内链接文本样式
将链接文本设置为蓝色，鼠标划过时文字颜色加深，并显示下划线。
找到文件 themes\next\source\css\_custom\custom.styl ，添加如下 css 样式：

```css
.post-body p a {
  color: #0593d3;
  border-bottom: none;
  &:hover {
    color: #0477ab;
    text-decoration: underline;
  }
}
```

# 自定义span label标签样式
自带的`label`不好看，自带写法如下
```
{% labe info@标签文字 %}
```

找到文件 themes\next\source\css\_custom\custom.styl ，添加如下 css 样式：

```css
// 颜色块-黄
span#inline-yellow {
  display:inline;
  padding:.2em .6em .3em;
  font-size:80%;
  font-weight:bold;
  line-height:1;
  color:#fff;
  text-align:center;
  white-space:nowrap;
  vertical-align:baseline;
  border-radius:0;
  background-color: #f0ad4e;
}

// 颜色块-绿
span#inline-green {
  display:inline;
  padding:.2em .6em .3em;
  font-size:80%;
  font-weight:bold;
  line-height:1;
  color:#fff;
  text-align:center;
  white-space:nowrap;
  vertical-align:baseline;
  border-radius:0;
  background-color: #5cb85c;
}

// 颜色块-蓝
span#inline-blue {
  display:inline;
  padding:.2em .6em .3em;
  font-size:80%;
  font-weight:bold;
  line-height:1;
  color:#fff;
  text-align:center;
  white-space:nowrap;
  vertical-align:baseline;
  border-radius:0;
  background-color: #2780e3;
}

// 颜色块-紫
span#inline-purple {
  display:inline;
  padding:.2em .6em .3em;
  font-size:80%;
  font-weight:bold;
  line-height:1;
  color:#fff;
  text-align:center;
  white-space:nowrap;
  vertical-align:baseline;
  border-radius:0;
  background-color: #9954bb;
}
```

# 修改作者头像为圆形和鼠标悬浮旋转效果

修改<span id="inline-purple">主题配置文件</span>

```bash
avatar:
  # In theme directory (source/images): /images/avatar.gif
  # In site directory (source/uploads): /uploads/avatar.gif
  # You can also use other linking images.
  url: /images/avatar.jpeg # 头像地址
  # If true, the avatar would be dispalyed in circle.
  rounded: true # 头像设置为圆形
  # The value of opacity should be choose from 0 to 1 to set the opacity of the avatar.
  opacity: 1
  # If true, the avatar would be rotated with the cursor.
  rotated: true # 鼠标悬浮旋转
```

# 修改文章底部的那个带#号的标签
编辑<span id="inline-purple">主题配置文件</span>

```bash
tag_icon: true
```

# 百度统计

{% note warning %}
注意： baidu_analytics 不是你的百度 id 或者 百度统计 id
{% endnote %}

1. 登录 [百度统计](https://tongji.baidu.com) ，定位到站点的代码获取页面

2. 复制 hm.js? 后面那串统计脚本 id，如下图所示：

{% asset_img images/baidu_analytics.png %}

3. 编辑<span id="inline-purple">主题配置文件</span>， 修改字段 baidu_analytics，值设置成你的百度统计脚本 id。

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
修改<span id="inline-purple">主题配置文件</span>中的仓库信息
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
language: zh-CN
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

## 常见问题4

Hexo 中使用markdown语法的绝对图片路径在首页无法展示，可改用标签插件语法：
配置_config.yml
```
post_asset_folder: true
```
将_config.yml文件中的配置项post_asset_folder设为true后，执行命令$ hexo new post_name，在source/_posts中会生成文章post_name.md和同名文件夹post_name。将图片资源放在post_name中，文章就可以使用相对路径引用图片资源了。

图片`_posts/post_name/image.jpg`,可通过如下方式访问
```
{% asset_img image.jpg This is an image %}
```



<h5 style="color:#f63;"><i>最后要说的是：</i></h5>
{% note success %} 
[博客源码](https://github.com/yqsailor/blog)， 欢迎 star 
{% endnote %}
