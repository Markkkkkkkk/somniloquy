---
category: [博客建站]
tag: [typora,markdown,图床,博客]
postType: post
status: publish
---

## 前言

在wordpress博客网站架构中，鉴于wordpress后台编写文章的低效性，文章都是通过本地编写markdown文件然后通过m2w接口上传到wordpress数据库的。既然文章是在本地电脑编写的，那么有一款趁手的markdown文件编写工具就很必要了，今天要介绍的就是Typora。

> 其实最爽的是用WPS智能文档在线写作，支持markdown，也扩展了更多的功能，但是奈何不能导出标准的markdown文件，所以不能直接上传到wordpress，所以大部分时间还是用Typora在电脑上写作。如果遇到在车上等其它不方便用电脑但又想及时记录的时候，就用手机WPS智能文档临时记录下吧，然后再粘贴复制到Typora里面去。

**核心功能**

1. **所见即所得（WYSIWYG）编辑**
	1. Typora 最大的特点是去掉了传统 Markdown 编辑器的“源码区 + 预览区”，用户在写作时直接看到最终排版效果。
2. **Markdown 完整支持**
	1. 支持标准 Markdown 语法和扩展，包括表格、任务列表、脚注、公式（LaTeX）、代码块语法高亮等。
3. **实时预览**
	1. 不需要切换预览模式，输入时就能即时看到最终渲染结果。
4. **导出与格式兼容**
	1. 支持导出为 PDF、Word、HTML、LaTeX、EPUB 等多种格式。
	2. 可以直接复制为带格式的富文本到 Word/微信/知乎等。
5. **写作辅助功能**
	1. 大纲视图（Outline）和文档目录（TOC）
	2. 数学公式支持（MathJax/LaTeX）
	3. Mermaid 流程图 / 序列图 / 甘特图
	4. 图片插入支持（可自动上传到图床）

## 软件安装与配置

大家可以从[官网](https://typoraio.cn/)下载安装，下载成功一步步点就安装完成了，应该不难。建议大家可以购买Typora的激活码，89元可以激活三台设备。如果还不能下决心的话可以先试用三十天再做决定。

### 主题设置

找一个好看的主题，可以让自己写文章更有动力，赏心悦目的主题也可以减少疲惫。就像WordPress博客一样，Typora也是有主题的，Typora官网提供了一些主题：[https://theme.typora.io](https://theme.typora.io/)。我自己用的这个主题叫[typora-vue-theme](https://github.com/blinkfox/typora-vue-theme)，是在Github里下载的。你也可以在Github里找一下别的Typora主题，估计开源的主题不少。**总有一款适合你**！我觉得`Vue`主题界面简洁清爽，颜色搭配也很协调，几经周转最终还是选择了它作为默认主题。下面，我以安装`typora-vue-theme`示范Typora主题的一般安装和使用方法！

首先，我们先进入`偏好设置`：

![image-20250826223842031](https://image.hyly.net/i/2025/08/26/595dfed8591563a36dea41dc11abc6d8-0.webp)

打开`主题文件夹`：

![image-20250826223913380](https://image.hyly.net/i/2025/08/26/ac2545298b9246d6ae209c7a6fcdf32a-0.webp)

最后，将主题css文件和对应的字体文件夹复制到themes目录下，重启Typora即可：

![img](https://image.hyly.net/i/2025/08/26/ecf733ed8521564b6dc80cc602eec163-0.webp)

如果成功，可以在主界面的`主题`选项中找到`Vue`主题，选中它就生效了：

![image-20250826224139122](https://image.hyly.net/i/2025/08/26/5640429bb2b0d172588663927b56e7cc-0.webp)

一般主题的README文档会说明如何安装。有些主题的安装就会复杂一些，比如[VLOOK主题](https://github.com/MadMaxChow/VLOOK)。但总体上，我觉得即便是技术小白也可以轻松地hold住给Typora安装自定义主题的操作。

### 自定义CSS

原生主题中加粗字体的颜色是纯黑，这与非加粗字体的对比不够强烈。我希望换一个颜色，这样看上去会比较明显，符合加粗强调的含义：

我们打开主题对应的CSS文件`vue.css`，找到`#write strong`参数，改为：

```
#write strong {
    padding: 0 1px;
    color: #CE7777;
}
```

这样，加粗文字的颜色就会发生变化：

![image-20250826224708484](https://image.hyly.net/i/2025/08/26/7071647ed00345455cc781285d8ebab4-0.webp)

### 快捷键

Typora默认的快捷键大多数都还好。自己目前只修改了一个快捷键，你想修改其它快捷键是类似操作。

修改快捷键的地方在`文件--偏好设置--通用--高级设置--conf.user.json`，可以用`Notepad++`打开。修改完保存并重启Typora即可生效：

![image-20250826225344116](https://image.hyly.net/i/2025/08/26/2aeba99d1aa58e677d307c44103b3d45-0.webp)

### 目录自动编号

> 参考[lipengzhou/typora-theme-auto-numbering: Typora 主题自动编号](https://github.com/lipengzhou/typora-theme-auto-numbering)

从`偏好设置——外观`中打开`主题文件夹`，将仓库的`base.user.css`和`github.user.css`放入主题文件夹即可：

![image](https://image.hyly.net/i/2025/08/26/a3059f96342cc329ec5b86f9fbf5811c-0.webp)

效果就是从h2开始按层级计数：

![image-20250826225824576](https://image.hyly.net/i/2025/08/26/a52e68028ebccc6b878b8e2e7beeba77-0.webp)

原始的目录自动编号是有一些小问题的，会造成下面的子集延续上面子集的编号，像这样：

![image-20250827100118557](https://image.hyly.net/i/2025/08/27/b2a8eb4ebcd76fd7933dbbad6e72d928-0.webp)

只需要修改`base.user.css`文件中的这里就可以了：

![image-20250827100224386](https://image.hyly.net/i/2025/08/27/bf9b2a16f949c06a36eb331c7bec01a0-0.webp)

## 基本语法

想了解详细基础语法的小伙伴可以看[这篇文章](https://www.runoob.com/markdown/md-tutorial.html)。

## 进阶使用

### 图床

写markdown怎么能少得了图床呢，关于图床的搭建大家可以看[这篇文章](https://hyly.net/article/code/wordpress/378/#header-id-16)。

图床搭建完成之后就是该如何使用了。我的基本路线是：在typora里粘贴图片然后通过picList调用接口的方式就可以把图片上传到图床了。

#### 图床工作流搭建

首先下载picList，能翻墙的小伙伴去[这里下载](https://github.com/Kuingsmile/PicList/releases)，条件不允许的可以在[这里下载](https://url62.ctfile.com/d/61737562-154661282-7f7d1f?p=8732)。

1. 安装后在插件设置中搜索`web-uploader 1.1.1` 并安装（下载插件可能需要[node.js](https://nodejs.org/zh-cn/)插件）。
2. 图床设置-自定义Web图床中按照如下方式填写，然后点击确定并设置为默认图床。
3. 登录图床后台->图床安全->高级设置->开启API上传。

![4128197507](https://image.hyly.net/i/2025/08/27/b732261c27bf1247013699fca0699848-0.webp)

```
API地址:https://png.cm/api/index.php // 输入你网站api地址
POST参数名: image
JSON路径: url
自定义Body: {"token":"1c17b11693cb5ec63859b091c5b9c1b2"} // 这里输入你网站生成的token
```

token生成位置在easyimage后台API设置处：

![image-20250827114921622](https://image.hyly.net/i/2025/08/27/cd5c1e6830fc4716bb2cb3a20c1261ab-0.webp)

然后typora上传图片的时候直接调用PicList上传图片到图床。

Windows系统：

1. 进入Typora`文件->偏好设置->图像`设置页面
2. 将上传服务设置为`PicList`
3. 在`PicList`中填写PicList的安装路径
4. 设置完毕之后有个验证上传，可以验证一下。全部成功之后就可以直接在typora里粘贴图片上传到图床了。

![image-20250827115426585](https://image.hyly.net/i/2025/08/27/de891e8f654f030770b5b7385f842834-0.webp)

![PixPin_2025-08-27_11-55-20](https://image.hyly.net/i/2025/08/27/aaad2e59d1d03194716557d2eb3ab895-0.webp)

### 表情

> 可以参考[markdown表情包](https://www.webfx.com/tools/emoji-cheat-sheet/)

比如😅🤣🥰😂挺有趣的！由于在使用Ajax的Argon主题时其显示并不正常（即表情显示为字符串)，因此我并不是很常用。大家可以试试看！

或者大家也可以使用颜文字，这样限制就少了，我一般都是在博客评论区找现成的颜文字，或者大家也可以在第三方平台找一些粘贴到文章里表达自己的情绪。随便找个文章，就像这种：

![image-20250827120422432](https://image.hyly.net/i/2025/08/27/cf00f3bdda7e1787ea5b28831389c45e-0.webp)

### 在Markdown中使用HTML

Markdown对HTML的兼容性不错。 字体、图片、表格、视频等，自定义程度更强！

#### 字体

写一些奇怪的字：

```
<font face="黑体" color="#009688" size=6>我们是看故事的人，故事里的人是我们。</font>
```

<font face="黑体" color="#009688" size=6>我们是看故事的人，故事里的人是我们。</font>

#### 图片

插入一个图片：

```
<img src="https://chevereto.hwb0307.com/images/2023/03/19/bbmb-80.jpg" alt="bbmb-80.jpg" border="0" />
```

<img src="https://chevereto.hwb0307.com/images/2023/03/19/bbmb-80.jpg" alt="bbmb-80.jpg" border="0" />

#### 表格

强烈建议使用html代码进行表格的表述，这样对HTML的兼容性会更好。 比如：

```
<table style="border:1px solid black; margin-left:auto; margin-right:auto;"><tr><td> </td><td>API</td><td>Access Token</td></tr><tr><td>基本要求</td><td>OpenAI帐号+ 绑定国外的虚拟信用卡</td><td>仅OpenAI帐号</td></tr><tr><td>收费情况</td><td>使用收费</td><td>免费</td></tr><tr><td>基础Prompt</td><td>支持</td><td>不支持</td></tr><tr><td>超参数支持</td><td>Temprature/Top_p</td><td>不支持</td></tr><tr><td>单位时间请求数</td><td>较高，适合多人使用</td><td>较低，适合个人使用</td></tr><tr><td>响应速度</td><td>较快</td><td>较慢</td></tr><tr><td>绕过Cloudflare的反向代理</td><td>不需要</td><td>需要</td></tr><tr><td>Cloudflare WARP</td><td>不需要</td><td>部分需要</td></tr></table><br>
```

效果如下：

<table style="border:1px solid black; margin-left:auto; margin-right:auto;"><tr><td> </td><td>API</td><td>Access Token</td></tr><tr><td>基本要求</td><td>OpenAI帐号+ 绑定国外的虚拟信用卡</td><td>仅OpenAI帐号</td></tr><tr><td>收费情况</td><td>使用收费</td><td>免费</td></tr><tr><td>基础Prompt</td><td>支持</td><td>不支持</td></tr><tr><td>超参数支持</td><td>Temprature/Top_p</td><td>不支持</td></tr><tr><td>单位时间请求数</td><td>较高，适合多人使用</td><td>较低，适合个人使用</td></tr><tr><td>响应速度</td><td>较快</td><td>较慢</td></tr><tr><td>绕过Cloudflare的反向代理</td><td>不需要</td><td>需要</td></tr><tr><td>Cloudflare WARP</td><td>不需要</td><td>部分需要</td></tr></table><br>

如果不使用把表格转换成HTML的话文章发布到wordpress显示可能会有点问题，就像这样：

![image-20250827121206030](https://image.hyly.net/i/2025/08/27/96a759354e50c8b2c052ebbb92c8df1c-0.webp)

我们可以在[Markdown 表格 转换为 HTML 表格 – 在线表格转换工具](https://tableconvert.com/zh-cn/markdown-to-html)中对表格进行各种格式的转换，建议转换为压缩HTML：

![msedge_nxy7oRzvfT](https://image.hyly.net/i/2025/08/27/4a6f3f65766efa656cf5e657a13c1088-0.webp)

一般地，我们还需要使用CSS定义表格样式。比如，在本例中，我使用了`style="border:1px solid black; margin-left:auto; margin-right:auto;"`，其定义了边宽和表格居中。

经过转换，表格格式就正常了：

![image-20250827122432098](https://image.hyly.net/i/2025/08/27/725b3a86571fb60f6d765397caaf4d80-0.webp)

如果遇到之前已经有markdown文件创建了表格而且表格很多的情况下，这样一个个转换比较麻烦，还有一种方法就是直接全选之前的markdown表格，复制为HTML格式，然后`Ctrl+Shift+V`无格式粘贴就可以了，不能`Ctrl+V`直接粘贴，这样是不行的：

![PixPin_2025-09-13_21-05-38](https://image.hyly.net/i/2025/09/13/2cfea9bb47d88f13f9e3bb63c2f4ce98-0.webp)

#### 视频

markdown里甚至可以嵌入视频！比如，嵌入一个B站视频：

```
<div style="position: relative; padding: 30% 45%;">
<iframe src="//player.bilibili.com/player.html?aid=248179775&bvid=BV1ov41157UQ&cid=342169071&page=1&as_wide=1&high_quality=1&danmaku=0&autoplay=0" scrolling="no" border="0" frameborder="no" framespacing="0" allowfullscreen="true" style="position: absolute; width: 100%; height: 100%; left: 0; top: 0;"> </iframe>
</div><br>
```

<div style="position: relative; padding: 30% 45%;">
<iframe src="//player.bilibili.com/player.html?aid=248179775&bvid=BV1ov41157UQ&cid=342169071&page=1&as_wide=1&high_quality=1&danmaku=0&autoplay=0" scrolling="no" border="0" frameborder="no" framespacing="0" allowfullscreen="true" style="position: absolute; width: 100%; height: 100%; left: 0; top: 0;"> </iframe>
</div><br>

嵌入一个Youtube视频：

```
<div style="position: relative; padding: 30% 45%;">
<iframe src="https://www.youtube-nocookie.com/embed/aBCZuoXKzm4" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen style="position: absolute; width: 100%; height: 100%; left: 0; top: 0;"></iframe>
</div><br>
```

<div style="position: relative; padding: 30% 45%;">
<iframe src="https://www.youtube-nocookie.com/embed/aBCZuoXKzm4" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen style="position: absolute; width: 100%; height: 100%; left: 0; top: 0;"></iframe>
</div><br>

链接可以在视频的分享图标里获得：

![img](https://image.hyly.net/i/2025/08/27/6b08283e869d48b6ce1972bf4b56d083-0.webp)

上述代码在PC端/移动端进行了优化，效果不错。大家可以试试看！

#### 音频

> Resource: [【爱如潮水】指弹 不小心暴露了年龄。。。_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV15b4y1a7Dr)

举个简单的例子：

```
<audio controls>
  <source src="https://nextcloud.hwb0307.com/apps/sharingpath/test/public/audio/music-01.m4a" type="audio/mpeg">
</audio>
```

<audio controls>
  <source src="https://nextcloud.hwb0307.com/apps/sharingpath/test/public/audio/music-01.m4a" type="audio/mpeg">
</audio>

## 其它设置

![image-20250827151516399](https://image.hyly.net/i/2025/08/27/a6f6f99dd17a63fc72ec45cf52d24783-0.webp)

![image-20250827152712445](https://image.hyly.net/i/2025/08/27/43f68bf14716a828873ac13c068ce9ff-0.webp)

![image-20250827152732232](https://image.hyly.net/i/2025/08/27/c0af5e98db41781257284d39c3cf04dc-0.webp)

![image-20250827152755454](https://image.hyly.net/i/2025/08/27/1a79528f2b2ebdc3e61296d01ab66c8a-0.webp)

## 小结

Typora作为写博客工作流里一个重要的节点，我们要好好整一下，俗话说工欲善其事，必先利其器嘛。大家在使用过程中有什么疑问也欢迎在文章下方留言与我互动~喜欢本文章也欢迎点赞转发！

## 拓展阅读

1. [Typora 地表最强Markdown编辑器之一](https://blognas.hwb0307.com/skill/1734)

