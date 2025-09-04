---
category: [博客建站]
tag: [argon,wordpress外观]
postType: post
status: publish
---

## 前言

经过前面文章的学习，相信小伙伴们已经搭建好了一个基础博客，界面啥的还都是默认的，但是颜值即正义嘛~漂亮的页面和丝滑的操作读文章也会开心很多，经过本文章的学习，大家会有一个炫酷好看博客的~

经过多方调研，最终选定了[Argon](https://github.com/solstice23/argon-theme)这款主题，首先它文档相对完善，国内用户多，能找到一些教程或魔改思路。界面美观，功能相对完整，自带文章目录（TOC）、代码高亮、文章点赞/打赏、分享功能。评论区美化，内置表情、Ajax 评论。支持 Banner 图、文章封面、卡片式排版等。访问速度也较快，前端资源经过优化，CSS/JS体积不算太大，支持懒加载、部分功能异步加载，利于性能和 SEO。内置基础 SEO 优化（标题、描述、Open Graph 等）。结构化数据支持较友好。

## Argon主题配置

### 安装

由于Argon是第三方主题，所以不能在wordpress插件市场里直接安装，需要下载主题压缩包上传安装。首先在[Github](https://github.com/solstice23/argon-theme/releases)下载压缩包，不能翻墙的小伙伴可以从这里下载。下载完成后直接在插件列表这里上传插件即可：

![image-20250902102206083](https://image.hyly.net/i/2025/09/02/ac2a4918d7fea604bb73bec9305619fc-0.webp)

![image-20250902102305595](https://image.hyly.net/i/2025/09/02/11316dc9cc32e40bfaf28eef1b7ae590-0.webp)

![image-20250902102407309](https://image.hyly.net/i/2025/09/02/237f252aa8da66d906cf7f81b64e4cc0-0.webp)

### 详细配置

安装完成后可以在左侧菜单栏找到**Argon主题选项**菜单就可以进行设置了，以下是我的详细设置，大家可以参考：

![image-20250902112325366](https://image.hyly.net/i/2025/09/02/05c2bf410266060d3a52e090637018f8-0.webp)

## 特效配置

除了Argon对页面的美化，我们还加入了一些自定义的美化，大家可以根据自己需要添加。他们都是基于`/usr/apps/blog/wordpressData/wp-content/themes/argon/footer.php`文件进行添加的。

已经通过两个文件——`common.php`和`timeRAM.php`托管平时经常编辑的特效代码，这和直接在footer.php里添加是等价的。在`footer.php`引用的方法类似于：

![image-20250902195817630](https://image.hyly.net/i/2025/09/02/3aacec7f2d124077679a87c9c08c2d42-0.webp)

![image-20250902200001777](https://image.hyly.net/i/2025/09/02/76754824884de8598f08f04edf8e9786-0.webp)

这样做的原因有两个：（1）分开托管逻辑比较清晰，源代码不容易因为更新丢失（禁用了argon自动更新，然后还有备份，其实还好）

### common.php文件

在`在footer.php`同级目录新建文件夹和文件`/specialEffects/common.php`，以下是详细内容，图省事可以直接复制使用，下方有详细说明。

```
 
<!-- 用法
    在footer.php中</body>标签前引用下列命令即可：第一个!记得去掉！
    <!?php require('./specialEffects/common.php'); ?>
-->
 
 
<!-- 数学公式支持-->
<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    tex2jax: {
      inlineMath: [['$','$'], ['\\(','\\)']],
      processEscapes: true
    }
  });
</script>
 
 
<!-- 设备判断JS脚本
    用法：https://github.com/hgoebl/mobile-detect.js#readme
    也可至bloghelper取得： https://fastly.jsdelivr.net/gh/huangwb8/bloghelper@latest/js/mobile-detect.js
-->
<script src="https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/js/mobile-detect.js"></script>
 
<!--全页特效开始-->
<script type="text/javascript">
 
    // 设备检测
    var md = new MobileDetect(window.navigator.userAgent);
 
    // PC生效，手机/平板不生效
    // md.mobile(); md.phone(); 
    if(!md.phone()){
 
        if(!md.tablet()){
 
            // 雪花
            // $.getScript("https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/js/xiaxue.js");
 
            // 樱花
           // $.getScript("https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/js/yinghua.js");
 
            // 小烟花特效
            // $.getScript("https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/js/mouse-click.js");
 
            // 大烟花特效 z-index:217483647; pointer-events: none; 
            // $.getScript("https://fastly.jsdelivr.net/gh/huangwb8/bloghelper@latest/mouse/mouse-click-02/mouse-canvas.js");
            // document.write('<style>#mouse-canvas {z-index:217483647; pointer-events: none;  box-sizing: border-box !important; display: block !important; position: fixed !important; left: 0; right: 0; top: 0; bottom: 0; width: 100%; height: 100vh;}</style>')
 
            // 鼠标移动的仙女棒特效
            $.getScript("https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/mouse/halo-dream/fairyDustCursor.min.js");
 
            // 鼠标移动的泡泡特效
            // $.getScript("https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/mouse/joe/censor10.js");
 
        }
 
        // 春节灯笼
        // document.write('<link href="https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/css/deng.css" rel="stylesheet">');
        // document.write('<div class="deng-box"><div class="deng"><div class="xian"></div><div class="deng-a"><div class="deng-b"><div class="deng-t">春节</div></div></div><div class="shui shui-a"><div class="shui-c"></div><div class="shui-b"></div></div></div></div>');
        // document.write('<div class="deng-box1"><div class="deng"><div class="xian"></div><div class="deng-a"><div class="deng-b"><div class="deng-t">快乐</div></div></div><div class="shui shui-a"><div class="shui-c"></div><div class="shui-b"></div></div></div></div>');  
 
        // 随机图API之动态壁纸
        // document.write('<style type="text/css" id="wp-custom-css">#content:before{opacity: 0;}</style>');
        // document.write('<video src="https://blognas.hwb0307.com/imgapi/index-animated.php" class="bg-video" autoplay="" loop="loop" muted=""></video>');
        // document.write('<style> video.bg-video {position: fixed; z-index: -1;left: 0;right: 0;top: 0;bottom: 0;width: 100vw;height: 100vh; object-fit: cover;pointer-events: none;transition: opacity .3s ease;}</style>')
    }
</script>
<!--全页特效结束-->
 
<!--鼠标悬停3D效果start-->
<div class="article.post:not(.post-full)" data-tilt></div>
<div class=".shuoshuo-preview-container" data-tilt></div>
<!-- <script type="text/javascript" src="https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/vanilla3D/vanilla-tilt_v1.7.3.js"></script> -->
<script type="text/javascript" src="https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/vanilla3D/vanilla-tilt.js"></script>
<script type="text/javascript">
    // 设备检测
    var md = new MobileDetect(window.navigator.userAgent);
 
    // PC生效，手机/平板不生效
    // md.mobile(); md.phone(); 
    if(!md.phone() && !md.tablet()){
        window.pjaxLoaded = function(){
            // 正文卡片
            VanillaTilt.init(document.querySelectorAll("article.post:not(.post-full)"),{
                reverse:                true,  // reverse the tilt direction
                max:                    8,     // max tilt rotation (degrees)
                startX:                 0,      // the starting tilt on the X axis, in degrees.
                startY:                 0,      // the starting tilt on the Y axis, in degrees.
                perspective:            1000,   // Transform perspective, the lower the more extreme the tilt gets.
                scale:                  1.02,      // 2 = 200%, 1.5 = 150%, etc..
                speed:                  600,    // Speed of the enter/exit transition
                transition:             false,   // Set a transition on enter/exit.
                axis:                   "y",    // What axis should be banned. Can be "x", "y", or null
                reset:                  true,   // If the tilt effect has to be reset on exit.
                easing:                 "cubic-bezier(.03,.98,.52,.99)",    // Easing on enter/exit.
                glare:                  false,  // if it should have a "glare" effect
                "max-glare":            0.8,      // the maximum "glare" opacity (1 = 100%, 0.5 = 50%)
                "glare-prerender":      false,  // false = VanillaTilt creates the glare elements for you, otherwise
                                                // you need to add .js-tilt-glare>.js-tilt-glare-inner by yourself
                "mouse-event-element":  null,   // css-selector or link to HTML-element what will be listen mouse events
                gyroscope:              true,   // Boolean to enable/disable device orientation detection,
                gyroscopeMinAngleX:     -45,    // This is the bottom limit of the device angle on X axis, meaning that a device rotated at this angle would tilt the element as if the mouse was on the left border of the element;
                gyroscopeMaxAngleX:     45,     // This is the top limit of the device angle on X axis, meaning that a device rotated at this angle would tilt the element as if the mouse was on the right border of the element;
                gyroscopeMinAngleY:     -45,    // This is the bottom limit of the device angle on Y axis, meaning that a device rotated at this angle would tilt the element as if the mouse was on the top border of the element;
                gyroscopeMaxAngleY:     45,     // This is the top limit of the device angle on Y axis, meaning that a device rotated at this angle would tilt the element as if the mouse was on the bottom border of the element;
            })
 
            // 说说卡片
            VanillaTilt.init(document.querySelectorAll(".shuoshuo-preview-container"),{
                 reverse:                true,  // reverse the tilt direction
                 max:                    5,     // max tilt rotation (degrees)
                 startX:                 0,      // the starting tilt on the X axis, in degrees.
                 startY:                 0,      // the starting tilt on the Y axis, in degrees.
                 perspective:            2000,   // Transform perspective, the lower the more extreme the tilt gets.
                 scale:                  1.02,      // 2 = 200%, 1.5 = 150%, etc..
                 speed:                  300,    // Speed of the enter/exit transition
                 transition:             false,   // Set a transition on enter/exit.
                 axis:                   "y",    // What axis should be banned. Can be "x", "y", or null
                 reset:                  true,   // If the tilt effect has to be reset on exit.
                 easing:                 "cubic-bezier(.03,.98,.52,.99)",    // Easing on enter/exit.
                 glare:                  false,  // if it should have a "glare" effect
                 "max-glare":            0.8,      // the maximum "glare" opacity (1 = 100%, 0.5 = 50%)
                 "glare-prerender":      false,  // false = VanillaTilt creates the glare elements for you, otherwise
                                                 // you need to add .js-tilt-glare>.js-tilt-glare-inner by yourself
                 "mouse-event-element":  null,   // css-selector or link to HTML-element what will be listen mouse events
                 gyroscope:              true,   // Boolean to enable/disable device orientation detection,
                 gyroscopeMinAngleX:     -45,    // This is the bottom limit of the device angle on X axis, meaning that a device rotated at this angle would tilt the element as if the mouse was on the left border of the element;
                 gyroscopeMaxAngleX:     45,     // This is the top limit of the device angle on X axis, meaning that a device rotated at this angle would tilt the element as if the mouse was on the right border of the element;
                 gyroscopeMinAngleY:     -45,    // This is the bottom limit of the device angle on Y axis, meaning that a device rotated at this angle would tilt the element as if the mouse was on the top border of the element;
                 gyroscopeMaxAngleY:     45,     // This is the top limit of the device angle on Y axis, meaning that a device rotated at this angle would tilt the element as if the mouse was on the bottom border of the element;
             })
        }
        $(window.pjaxLoaded);
        $(document).on('pjax:end', window.pjaxLoaded); 
    }
</script>
<!--鼠标悬停3D效果end-->
 
<!--鼠标名单开始-->
<!-- <script type="text/javascript">
    var a_idx = 0;
    jQuery(document).ready(function($) {
    $("body").click(function(e) {
    //        var a = new Array("❤腿堡-苯苯❤","❤ALSO STARRING-榕榕❤","❤腿堡-亚伯❤","❤腿堡-银露❤","❤腿堡-枫叶❤","❤腿堡-培根❤","❤腿堡-老丘❤","❤腿堡-倩倩❤","❤腿堡-小o❤","❤腿堡-蛇蛇❤","❤腿堡-培根❤","❤腿堡-十九❤","❤腿堡-萝卜卜❤","❤腿堡-千泓❤","❤腿堡-萌波❤","❤腿堡-经历❤","❤letter-韩露❤","❤腿堡-记忆❤","❤叛徒-绝恋❤","❤腿堡-小离❤","❤腿堡-七秒❤","❤腿堡/剑花-U哥❤","❤大佬-幕哥❤","❤退谷-糕糕❤","❤退谷-肥鸡❤","❤退谷-气气❤","❤退谷-小幻❤","❤退谷-狂总❤","❤剑花-君故-会刷buff❤","❤剑花-肥少❤","❤剑花-太阳❤","❤剑花-我腿❤","❤剑花-笙哥❤","❤剑花-零点夫妇❤","❤还有很多小伙伴记不太清了❤");     
        // var a = new Array("富强", "民主", "文明", "和谐", "自由", "平等", "公正", "法治", "爱国", "敬业", "诚信", "友善");
        // var a = new Array("❤为汝祈福❤", "❤早日康复❤");
        var a = new Array("❤身体健康❤", "❤万事如意❤", "❤心想事成❤", "❤笑口常开❤", "❤年年有余❤", "❤金榜题名❤", "❤前程似锦❤", "❤一帆风顺❤");
        var $i = $("<span/>").text(a[a_idx]);
        a_idx = (a_idx + 1) % a.length;
        var x = e.pageX,
        y = e.pageY;
        $i.css({
            "z-index": 999999999999999999999999999999999999999999999999999999999999999999999,
            // "z-index": -1,
            "top": y - 20,
            "left": x,
            "position": "absolute",
            "font-weight": "bold",
            "color": "#ff6651"
        });
        $("body").append($i);
        $i.animate({
            "top": y - 180,
            "opacity": 0
        },
        1500,
        function() {
            $i.remove();
        });
    });
    });
</script> -->
<!--鼠标名单结束-->
 
<!--鼠标指针特效2-->
<style type="text/css">
    .main-content img,body{cursor:url(https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/mouse/halo-dream/cursor/breeze/Arrow.cur),auto}.actions>div,.expand-done,.main-content figure>figcaption div,.navbar-above .navbar-nav .item,.navbar-searchicon,.navbar-slideicon,.photos .picture-details,.widget .ad-tag .click-close,a,button{cursor:url(https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/mouse/halo-dream/cursor/breeze/Hand.cur),auto}blockquote,code,h1,h2,h3,h4,h5,h6,hr,input[type=text],li,p,td,textarea,th{cursor:url(https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/mouse/halo-dream/cursor/breeze/IBeam.cur),auto}
</style>

<!-- 标题自动锚点: Start -->
<script>
window.addEventListener('load', function() {
    // 构建标题文本与 Argon ID 的映射表
    const headers = document.querySelectorAll('h1[id], h2[id], h3[id], h4[id], h5[id], h6[id]');
    const textToIdMap = new Map();
    headers.forEach(header => {
        const id = header.id;
        const text = header.textContent.trim();
        textToIdMap.set(text, id); // 标题文本 -> ID 映射
    });
 
    // 替换页面中的基于文本的锚点链接
    const links = document.querySelectorAll('a[href^="#"]');
    links.forEach(link => {
        const targetText = decodeURIComponent(link.getAttribute('href').slice(1)); // 获取锚点文本
        if (textToIdMap.has(targetText)) {
            link.setAttribute('href', `#${textToIdMap.get(targetText)}`); // 替换为 Argon 的 ID
        }
    });
 
    //文外跳转
    if (window.location.hash) {
        const hash = window.location.hash.slice(1);  // 去掉 #
        let targetElement;
        // 优先检查哈希值是否是一个有效的 ID
        targetElement = document.getElementById(hash);
        if (!targetElement) {
            // 如果哈希值是标题文本，检查映射表
            const decodedHash = decodeURIComponent(hash);  // 解码哈希值
            if (textToIdMap.has(decodedHash)) {
                const targetId = textToIdMap.get(decodedHash);  // 获取对应的 ID
                targetElement = document.getElementById(targetId);  // 查找对应 ID 的元素
            }
             // 替换图片的 src 属性
            const lazyImages = document.querySelectorAll('img.lazyload[data-original]');
            lazyImages.forEach(img => {
                img.src = img.getAttribute('data-original'); // 直接替换为真正的图片链接
            });
        }
        // 如果找到了目标元素，滚动到该元素
        if (targetElement) {
            targetElement.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
    }
});
</script>
<!-- 标题自动锚点: End -->
 
 
<!--网站输入效果-->
<script src="https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/js/input-with-fire.js"></script>
 
<!--主题搞笑字符-->
 <!--<script src="https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/js/onfocus.js"></script> -->
 
<!--文字抖动特效-->
<link href="https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/css/myface.css" rel="stylesheet">
 
<!--WordPress防镜像  -->
<img style="display:none" src=" " onerror='this.onerror=null;var currentDomain="hyly" + ".net"; var str1=currentDomain; str2="docu"+"ment.loca"+"tion.host"; str3=eval(str2) ;if( str1!=str3 ){ do_action = "loca" + "tion." + "href = loca" + "tion.href" + ".rep" + "lace(docu" +"ment"+".loca"+"tion.ho"+"st," + "currentDomain" + ")";eval(do_action) }' />

<img style="display:none" src=" " onerror='
this.onerror=null;
var currentDomain = "hyly.net";
var allowedDomains = [currentDomain, "www." + currentDomain];
var currentHost = document.location.host;
if (!allowedDomains.includes(currentHost)) {
    location.href = location.href.replace(currentHost, currentDomain);
}
' />

<!--正文自动编号-->
<style type="text/css">h1:not(.title){counter-reset:h2counter;counter-increment:h1counter;}h1:not(.title):not(.post-title)::before{content:counter(h1counter) " ";}h2{counter-reset:h3counter;counter-increment:h2counter;}h2:not(.comments-title):not(.post-comment-title)::before{content:counter(h1counter) "." counter(h2counter) " ";}h3{counter-reset:h4counter;counter-increment:h3counter;}h3:not(.text-black)::before{content:counter(h1counter) "." counter(h2counter) "." counter(h3counter) " ";}h4{counter-reset:h5counter;counter-increment:h4counter;}h4:not(.modal-title)::before{content:counter(h1counter) "." counter(h2counter) "." counter(h3counter) "." counter(h4counter) " ";}h5:not(.modal-title){counter-reset:h6counter;counter-increment:h5counter;}h5::before{content:counter(h1counter) "." counter(h2counter) "." counter(h3counter) "." counter(h4counter) "." counter(h5counter) " ";}h6:not(#leftbar_overview_author_name):not(#leftbar_overview_author_description){counter-increment:h6counter;}h6:not(#leftbar_overview_author_name):not(#leftbar_overview_author_description)::before{content:counter(h1counter) "." counter(h2counter) "." counter(h3counter) "." counter(h4counter) "." counter(h5counter) "." counter(h6counter) " ";}body{counter-reset:h1counter;}</style>
<!--滚动模糊-->
 <script>
window.addEventListener("scroll", function (e) {
  if (window.scrollY > window.innerHeight * 0.5) {
    document.querySelector("#content").classList.add("scrolled");
  } else {
    document.querySelector("#content").classList.remove("scrolled");
  }
});</script>
<style>
#content.scrolled::before, #content.scrolled::after {
  filter: blur(4px);
  transform: scale(1.02);
}
#content::before, #content::after {
  transition: filter .3s ease, transform .3s ease !important;
  filter: blur(0px);
  transform: scale(1.02);
}</style> 


<style type="text/css" id="wp-custom-css">
			
/*设置网站字体*/
/*原则上你可以设置多个字体，然后在不同的部位使用不同的字体*/
@font-face{
    font-family:btfFont;
  src: url(https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/fonts/13.woff2) format('woff2') 
  /*     src: url(https://bensz.onmicrosoft.cn/fonts/13.woff2) format('woff2')*/

}
body{
    font-family:"btfFont" !important
}

/*设置加粗字体颜色*/
strong {
    color: #A7727D;
}
html.darkmode strong {
    color: #FAAB78;
}

/*说说预览模式*/
pre {
    /*白天*/
    color: #A7727D;
}
html.darkmode pre {
    /*夜晚*/
    color: #FAAB78;
}

/* Github卡片样式*/
.github-info-card-header a {
    /*Github卡片抬头颜色*/
    color: black !important;
    font-size: 1.5rem;
}
html.darkmode .github-info-card-header a {
    /*Github卡片抬头颜色——夜间*/
    color: #FAAB78 !important;
    font-size: 1.5rem;
}
.github-info-card {
    /*Github卡片文字（非链接）*/
	font-size: 1rem;
    color: black !important;
}
html.darkmode .github-info-card {
    /*Github卡片文字（非链接）——夜间*/
	font-size: 1rem;
    color: #FAAB78 !important;
}
.github-info-card.github-info-card-full.card.shadow-sm {
    /*Github卡片背景色*/
    background-color: rgba(var(--themecolor-rgbstr), 0.1) !important;
}

/*横幅字体大小*/
.banner-title {
  font-size: 2.5em;
}
.banner-subtitle{
  font-size: 20px;
}

/*文章标题字体大小*/
.post-title {
	font-size: 30px
}

/*正文字体大小（不包含代码）*/
.post-content p{
	font-size: 1.25rem;
}
li{
    font-size: 1.2rem;
}

/*评论区字体大小*/
p {
	font-size: 1.2rem
}

/*评论发送区字体大小*/
.form-control{
	font-size: 1.2rem
}

/*评论勾选项目字体大小*/
.custom-checkbox .custom-control-input~.custom-control-label{
	font-size: 1.2rem
}
/*评论区代码的强调色*/
code {
  color: rgba(var(--themecolor-rgbstr));
}

/*说说字体大小和颜色设置*/
.shuoshuo-title {
	font-size: 25px;
/* 	color: rgba(var(--themecolor-rgbstr)); */
}

/*尾注字体大小*/
.additional-content-after-post{
    font-size: 1.2rem
}

/*========颜色设置===========*/

/*文章或页面的正文颜色*/
body{
	color:#364863
}

/*引文属性设置*/
blockquote {
	/*添加弱主题色为背景色*/
	background: rgba(var(--themecolor-rgbstr), 0.1) !important;
    width: 100%
}

/*引文颜色 建议用主题色*/
:root {
    /*也可以用类似于--color-border-on-foreground-deeper: #009688;这样的命令*/
	--color-border-on-foreground-deeper: rgba(var(--themecolor-rgbstr));
}

/*左侧菜单栏突出颜色修改*/
.leftbar-menu-item > a:hover, .leftbar-menu-item.current > a{
	background-color: #f9f9f980;
}
 
/*站点概览分隔线颜色修改*/
.site-state-item{
	border-left: 1px solid #aaa;
}
.site-friend-links-title {
	border-top: 1px dotted #aaa;
}
#leftbar_tab_tools ul li {
    padding-top: 3px;
    padding-bottom: 3px;
    border-bottom:none;
}
html.darkmode #leftbar_tab_tools ul li {
    border-bottom:none;
}

/*左侧栏搜索框的颜色*/
button#leftbar_search_container {
    background-color: transparent;
}

/*========透明设置===========*/

/*白天卡片背景透明*/
.card{
	background-color:rgba(255, 255, 255, 0.85) !important;
	/*backdrop-filter:blur(6px);*//*毛玻璃效果主要属性*/
	-webkit-backdrop-filter:blur(6px);
}

/*小工具栏背景完全透明*/
/*小工具栏是card的子元素，如果用同一个透明度会叠加变色，故改为完全透明*/
.card .widget,.darkmode .card .widget,#post_content > div > div > div.argon-timeline-card.card.bg-gradient-secondary.archive-timeline-title{
	background-color:#ffffff00 !important;
	backdrop-filter:none;
	-webkit-backdrop-filter:none;
}
.emotion-keyboard,#fabtn_blog_settings_popup{
	background-color:rgba(255, 255, 255, 0.95) !important;
}
 
/*分类卡片透明*/
.bg-gradient-secondary{
	background:rgba(255, 255, 255, 0.1) !important;
	backdrop-filter: blur(10px);
	-webkit-backdrop-filter:blur(10px);
}
 
/*夜间透明*/
html.darkmode.bg-white,html.darkmode .card,html.darkmode #footer{
	background:rgba(66, 66, 66, 0.9) !important;
}
html.darkmode #fabtn_blog_settings_popup{
	background:rgba(66, 66, 66, 0.95) !important;
}

/*标签背景
.post-meta-detail-tag {
	background:rgba(255, 255, 255, 0.5)!important;
}*/


/*========排版设置===========*/

/*左侧栏层级置于上层*/
#leftbar_part1 {
    z-index: 1;
}

/*分类卡片文本居中*/
#content > div.page-information-card-container > div > div{
	text-align:center;
}
 
/*子菜单对齐及样式调整*/
.dropdown-menu .dropdown-item>i{
    width: 10px;
}
.dropdown-menu>a {
	color:var(--themecolor);
}
.dropdown-menu{
	min-width:max-content;
}
.dropdown-menu .dropdown-item {
	padding: .5rem 1.5rem 0.5rem 1rem;
}
.leftbar-menu-subitem{
	min-width:max-content;
}
.leftbar-menu-subitem .leftbar-menu-item>a{
	padding: 0rem 1.5rem 0rem 1rem;
}
 
/*左侧栏边距修改*/
.tab-content{
	padding:10px 0px 0px 0px !important;
}
.site-author-links{
	padding:0px 0px 0px 10px ;
}
/*目录位置偏移修改*/
#leftbar_catalog{
	margin-left: 0px;
}
/*目录条目边距修改*/
#leftbar_catalog .index-link{
	padding: 4px 4px 4px 4px;
}
/*左侧栏小工具栏字体缩小*/
#leftbar_tab_tools{
	font-size: 14px;
}
 
/*正文图片边距修改*/
article figure {margin:0;}
/*正文图片居中显示*/
.fancybox-wrapper {
    margin: auto;
}
/*正文表格样式修改*/
article table > tbody > tr > td,
article table > tbody > tr > th,
article table > tfoot > tr > td,
article table > tfoot > tr > th,
article table > thead > tr > td,
article table > thead > tr > th{
	padding: 8px 10px;
	border: 1px solid;
}
/*表格居中样式*/
.wp-block-table.aligncenter{margin:10px auto;}
 
/*回顶图标放大*/
button#fabtn_back_to_top, button#fabtn_go_to_comment, button#fabtn_toggle_blog_settings_popup, button#fabtn_toggle_sides, button#fabtn_open_sidebar{
	font-size: 1.2rem;
}
 
/*顶栏菜单*/
/*这里也可以设置刚刚我们设置的btfFont字体。试试看！*/
.navbar-nav .nav-link {
	font-size: 1.2rem;
	font-family: 'btfFont';
}
.nav-link-inner--text {
	/*顶栏菜单字体大小*/
	font-size: 1.1rem;
}
.navbar-nav .nav-item {
	margin-right:0;
}
.mr-lg-5, .mx-lg-5 {
	margin-right:1rem !important;
}
.navbar-toggler-icon {
	width: 1.5rem;
	height: 1.5rem;
}
.navbar-expand-lg .navbar-nav .nav-link {
	padding-right: 0.9rem;
	padding-left: 1rem;
}

/*顶栏图标*/
.navbar-brand {
	font-family: 'Noto Serif SC',serif;
	font-size: 1.25rem;
	/*顶栏图标边界微调*/
	margin-right: 0rem; /*左右偏移*/
	padding-bottom: 0.3rem;
}
.navbar-brand img { 
  /* 图片高度*/
	height: 24px;
}

/*隐藏wp-SEO插件带来的线条阴影（不一定要装）*/
*[style='position: relative; z-index: 99998;'] {
    display: none;
}

/*头像调大*/
#leftbar_overview_author_image{
  width: 180px !important;
  height: 180px !important;
}

/*网站黑白色（悼念）需要添加在最底部否则容易与其它样式冲突*/
/* html {
	filter: grayscale(100%);
	-webkit-filter: grayscale(100%);
	-moz-filter: grayscale(100%);
	-ms-filter: grayscale(100%);
	-o-filter: grayscale(100%);
	filter: url("data:image/svg+xml;utf8,#grayscale");
	filter:progid:DXImageTransform.Microsoft.BasicImage(grayscale=1);
	-webkit-filter: grayscale(1);
} */		
</style>


```

#### 全屏雪花/樱花/烟花特效

这里提供的特效，在手机等设备是不生效的。因为手机的界面太小，特效会导致观看效果很差。设备判断主要利用mobile-detect项目提供的JS脚本（随机图API的php脚本也是类似的）。

用法也是编辑footer.php文件。还是刚刚那个界面。在末尾</body>上方（这样可以最后加载特效，以免影响其他内容的访问速度），添加以下代码（要用某个特效，记得将代码前面的注释符//去除）：

```
<!--全页特效开始-->
<script type="text/javascript">
 
    // 设备检测
    var md = new MobileDetect(window.navigator.userAgent);
 
    // PC生效，手机/平板不生效
    // md.mobile(); md.phone(); 
    if(!md.phone()){
 
        if(!md.tablet()){
 
            // 雪花
            // $.getScript("https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/js/xiaxue.js");
 
            // 樱花
           // $.getScript("https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/js/yinghua.js");
 
            // 小烟花特效
            // $.getScript("https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/js/mouse-click.js");
 
            // 大烟花特效 z-index:217483647; pointer-events: none; 
            // $.getScript("https://fastly.jsdelivr.net/gh/huangwb8/bloghelper@latest/mouse/mouse-click-02/mouse-canvas.js");
            // document.write('<style>#mouse-canvas {z-index:217483647; pointer-events: none;  box-sizing: border-box !important; display: block !important; position: fixed !important; left: 0; right: 0; top: 0; bottom: 0; width: 100%; height: 100vh;}</style>')
 
            // 鼠标移动的仙女棒特效
            $.getScript("https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/mouse/halo-dream/fairyDustCursor.min.js");
 
            // 鼠标移动的泡泡特效
            // $.getScript("https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/mouse/joe/censor10.js");
 
        }
 
        // 春节灯笼
        // document.write('<link href="https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/css/deng.css" rel="stylesheet">');
        // document.write('<div class="deng-box"><div class="deng"><div class="xian"></div><div class="deng-a"><div class="deng-b"><div class="deng-t">春节</div></div></div><div class="shui shui-a"><div class="shui-c"></div><div class="shui-b"></div></div></div></div>');
        // document.write('<div class="deng-box1"><div class="deng"><div class="xian"></div><div class="deng-a"><div class="deng-b"><div class="deng-t">快乐</div></div></div><div class="shui shui-a"><div class="shui-c"></div><div class="shui-b"></div></div></div></div>');  
 
        // 随机图API之动态壁纸
        // document.write('<style type="text/css" id="wp-custom-css">#content:before{opacity: 0;}</style>');
        // document.write('<video src="https://blognas.hwb0307.com/imgapi/index-animated.php" class="bg-video" autoplay="" loop="loop" muted=""></video>');
        // document.write('<style> video.bg-video {position: fixed; z-index: -1;left: 0;right: 0;top: 0;bottom: 0;width: 100vw;height: 100vh; object-fit: cover;pointer-events: none;transition: opacity .3s ease;}</style>')
    }
</script>
<!--全页特效结束-->
```

更新文件后生效。效果图如下：

- **雪花**：这个特效还挺适合冬天用的！

![img](https://image.hyly.net/i/2025/09/02/56ee4778f70e01df331e26c602d3b85a-0.gif)

- **樱花**：截屏时比较小，所以显得比较密集。一般情况下还可以的。

![img](https://image.hyly.net/i/2025/09/02/cb82086b2931b77886984308a66807dc-0.gif)

其实，这个樱花的图片换成其它图片就会有不一样的效果。你替换`img.src`参数背后的数据（是16进制？）即可换成另外一种图片。比如，我偶然发现有个[博主](https://www.limina.top/)的效果是满屏咸鱼，很秀，哈哈（最近看的时候发现已经取消了）！

![img](https://image.hyly.net/i/2025/09/02/9ddb4932a42e4fcf99d41ca2e1c941b9-0.webp)

鼠标大烟花特效：

> `z-index`和`position`参数决定了特效在哪一层显示，可按需修改。

![msedge_vFxnoQUTYW](https://image.hyly.net/i/2025/09/02/761d96c879233c41cb1c57fbb887ea3e-0.gif)

鼠标小烟花特效：

![img](https://image.hyly.net/i/2025/09/02/b9f38c10444542b8fc2c794d7ae611b5-0.gif)

#### 鼠标指针特效之仙女棒

来源于halo的[dream主题](https://github.com/nineya/halo-theme-dream)鼠标移动特效“仙女棒”，特效美观，自然：

![img](https://image.hyly.net/i/2025/09/02/1d7b15c6b36e0dac13241977907eab62-0.gif)

首先，在`雪花/樱花特效`里添加代码（保证只在PC端使用这个特效），它是仙女棒特效的来源，完全基于js生成，所以直接引用大佬们写好的脚本即可。将下列代码加到上面的`雪花/樱花/烟花特效`的JS框里：

```
// 鼠标移动的仙女棒特效
            $.getScript("https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/mouse/halo-dream/fairyDustCursor.min.js");
```

如图所示：

![Code_rB6mTUFAp2](https://image.hyly.net/i/2025/09/02/48bc8c579b3d94564c68963fec5ad189-0.webp)

鼠标外观在`footer.php`里加入这个代码即可：

```
<!--鼠标指针特效2-->
<style type="text/css">
    .main-content img,body{cursor:url(https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/mouse/halo-dream/cursor/breeze/Arrow.cur),auto}.actions>div,.expand-done,.main-content figure>figcaption div,.navbar-above .navbar-nav .item,.navbar-searchicon,.navbar-slideicon,.photos .picture-details,.widget .ad-tag .click-close,a,button{cursor:url(https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/mouse/halo-dream/cursor/breeze/Hand.cur),auto}blockquote,code,h1,h2,h3,h4,h5,h6,hr,input[type=text],li,p,td,textarea,th{cursor:url(https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/mouse/halo-dream/cursor/breeze/IBeam.cur),auto}
</style>
```


#### 卡片3D特效

> 来自中秋明月的[个人博客](https://iphoto.store/)。源项目地址：[vanilla-tilt.js](https://github.com/micku7zu/vanilla-tilt.js)

卡片的3D特效如下图：

![img](https://image.hyly.net/i/2025/09/02/3ca0e127fe9896f4b22dba2d0e220c78-0.gif)

基本原理大概是定义一个函数，它有多个参数可以调整某个对象的位置、角度等属性，然后通过JS调用。在Argon主题中，所有的卡片都来自`.card`类。所以，如果你使用`VanillaTilt.init(document.querySelectorAll(".card")`，那么所有的卡片都会动起来。不过，我只需要让文章卡片`article.post:not(.post-full)`和说说卡片`.shuoshuo-preview-container`动起来，所以仅定义了这两个对象的运作。您也可以自定义其它对象，这个就不展开说明了。

具体脚本我已经搬过来了：

```
<!--鼠标悬停3D效果start-->
<div class="article.post:not(.post-full)" data-tilt></div>
<div class=".shuoshuo-preview-container" data-tilt></div>
<!-- <script type="text/javascript" src="https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/vanilla3D/vanilla-tilt_v1.7.3.js"></script> -->
<script type="text/javascript" src="https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/vanilla3D/vanilla-tilt.js"></script>
<script type="text/javascript">
    // 设备检测
    var md = new MobileDetect(window.navigator.userAgent);
 
    // PC生效，手机/平板不生效
    // md.mobile(); md.phone(); 
    if(!md.phone() && !md.tablet()){
        window.pjaxLoaded = function(){
            // 正文卡片
            VanillaTilt.init(document.querySelectorAll("article.post:not(.post-full)"),{
                reverse:                true,  // reverse the tilt direction
                max:                    8,     // max tilt rotation (degrees)
                startX:                 0,      // the starting tilt on the X axis, in degrees.
                startY:                 0,      // the starting tilt on the Y axis, in degrees.
                perspective:            1000,   // Transform perspective, the lower the more extreme the tilt gets.
                scale:                  1.02,      // 2 = 200%, 1.5 = 150%, etc..
                speed:                  600,    // Speed of the enter/exit transition
                transition:             false,   // Set a transition on enter/exit.
                axis:                   "y",    // What axis should be banned. Can be "x", "y", or null
                reset:                  true,   // If the tilt effect has to be reset on exit.
                easing:                 "cubic-bezier(.03,.98,.52,.99)",    // Easing on enter/exit.
                glare:                  false,  // if it should have a "glare" effect
                "max-glare":            0.8,      // the maximum "glare" opacity (1 = 100%, 0.5 = 50%)
                "glare-prerender":      false,  // false = VanillaTilt creates the glare elements for you, otherwise
                                                // you need to add .js-tilt-glare>.js-tilt-glare-inner by yourself
                "mouse-event-element":  null,   // css-selector or link to HTML-element what will be listen mouse events
                gyroscope:              true,   // Boolean to enable/disable device orientation detection,
                gyroscopeMinAngleX:     -45,    // This is the bottom limit of the device angle on X axis, meaning that a device rotated at this angle would tilt the element as if the mouse was on the left border of the element;
                gyroscopeMaxAngleX:     45,     // This is the top limit of the device angle on X axis, meaning that a device rotated at this angle would tilt the element as if the mouse was on the right border of the element;
                gyroscopeMinAngleY:     -45,    // This is the bottom limit of the device angle on Y axis, meaning that a device rotated at this angle would tilt the element as if the mouse was on the top border of the element;
                gyroscopeMaxAngleY:     45,     // This is the top limit of the device angle on Y axis, meaning that a device rotated at this angle would tilt the element as if the mouse was on the bottom border of the element;
            })
 
            // 说说卡片
            VanillaTilt.init(document.querySelectorAll(".shuoshuo-preview-container"),{
                 reverse:                true,  // reverse the tilt direction
                 max:                    5,     // max tilt rotation (degrees)
                 startX:                 0,      // the starting tilt on the X axis, in degrees.
                 startY:                 0,      // the starting tilt on the Y axis, in degrees.
                 perspective:            2000,   // Transform perspective, the lower the more extreme the tilt gets.
                 scale:                  1.02,      // 2 = 200%, 1.5 = 150%, etc..
                 speed:                  300,    // Speed of the enter/exit transition
                 transition:             false,   // Set a transition on enter/exit.
                 axis:                   "y",    // What axis should be banned. Can be "x", "y", or null
                 reset:                  true,   // If the tilt effect has to be reset on exit.
                 easing:                 "cubic-bezier(.03,.98,.52,.99)",    // Easing on enter/exit.
                 glare:                  false,  // if it should have a "glare" effect
                 "max-glare":            0.8,      // the maximum "glare" opacity (1 = 100%, 0.5 = 50%)
                 "glare-prerender":      false,  // false = VanillaTilt creates the glare elements for you, otherwise
                                                 // you need to add .js-tilt-glare>.js-tilt-glare-inner by yourself
                 "mouse-event-element":  null,   // css-selector or link to HTML-element what will be listen mouse events
                 gyroscope:              true,   // Boolean to enable/disable device orientation detection,
                 gyroscopeMinAngleX:     -45,    // This is the bottom limit of the device angle on X axis, meaning that a device rotated at this angle would tilt the element as if the mouse was on the left border of the element;
                 gyroscopeMaxAngleX:     45,     // This is the top limit of the device angle on X axis, meaning that a device rotated at this angle would tilt the element as if the mouse was on the right border of the element;
                 gyroscopeMinAngleY:     -45,    // This is the bottom limit of the device angle on Y axis, meaning that a device rotated at this angle would tilt the element as if the mouse was on the top border of the element;
                 gyroscopeMaxAngleY:     45,     // This is the top limit of the device angle on Y axis, meaning that a device rotated at this angle would tilt the element as if the mouse was on the bottom border of the element;
             })
        }
        $(window.pjaxLoaded);
        $(document).on('pjax:end', window.pjaxLoaded); 
    }
</script>
<!--鼠标悬停3D效果end-->
```

对于Argon主题的使用者，这样就可以了！在Argon主题中，`window.pjaxLoaded`函数内的命令会避免使用Pjax并在切换页面时强制刷新，这个必须要用才可以保证特效的完美运行。如果是其它主题的话，你改一下控制对象的名字即可，具体情况具体分析。**你也可以自己改动一下参数，看看效果如何**。蛮有趣的一个特效！

#### 鼠标文字特效

和雪花特效是一样的用法。在末尾`</body>`上方加入。当然`a`变量中的文字就自定义了！你可以改成自己喜欢的文字。

```
<!--鼠标名单开始-->
<!-- <script type="text/javascript">
    var a_idx = 0;
    jQuery(document).ready(function($) {
    $("body").click(function(e) {
    //        var a = new Array("❤腿堡-苯苯❤","❤ALSO STARRING-榕榕❤","❤腿堡-亚伯❤","❤腿堡-银露❤","❤腿堡-枫叶❤","❤腿堡-培根❤","❤腿堡-老丘❤","❤腿堡-倩倩❤","❤腿堡-小o❤","❤腿堡-蛇蛇❤","❤腿堡-培根❤","❤腿堡-十九❤","❤腿堡-萝卜卜❤","❤腿堡-千泓❤","❤腿堡-萌波❤","❤腿堡-经历❤","❤letter-韩露❤","❤腿堡-记忆❤","❤叛徒-绝恋❤","❤腿堡-小离❤","❤腿堡-七秒❤","❤腿堡/剑花-U哥❤","❤大佬-幕哥❤","❤退谷-糕糕❤","❤退谷-肥鸡❤","❤退谷-气气❤","❤退谷-小幻❤","❤退谷-狂总❤","❤剑花-君故-会刷buff❤","❤剑花-肥少❤","❤剑花-太阳❤","❤剑花-我腿❤","❤剑花-笙哥❤","❤剑花-零点夫妇❤","❤还有很多小伙伴记不太清了❤");     
        // var a = new Array("富强", "民主", "文明", "和谐", "自由", "平等", "公正", "法治", "爱国", "敬业", "诚信", "友善");
        // var a = new Array("❤为汝祈福❤", "❤早日康复❤");
        var a = new Array("❤身体健康❤", "❤万事如意❤", "❤心想事成❤", "❤笑口常开❤", "❤年年有余❤", "❤金榜题名❤", "❤前程似锦❤", "❤一帆风顺❤");
        var $i = $("<span/>").text(a[a_idx]);
        a_idx = (a_idx + 1) % a.length;
        var x = e.pageX,
        y = e.pageY;
        $i.css({
            "z-index": 999999999999999999999999999999999999999999999999999999999999999999999,
            // "z-index": -1,
            "top": y - 20,
            "left": x,
            "position": "absolute",
            "font-weight": "bold",
            "color": "#ff6651"
        });
        $("body").append($i);
        $i.animate({
            "top": y - 180,
            "opacity": 0
        },
        1500,
        function() {
            $i.remove();
        });
    });
    });
</script> -->
<!--鼠标名单结束-->
```

后面有小伙伴说影响双击选中单词，我就没上这个特效了。
#### 文内外跳转

> 理论上适用于h1-h6标签；仅限argon主题。感谢[鸦鸦](https://crowya.com/)的改进！

以用类似markdown的方式添加关于标题的锚点。这在**浏览一些具有多个标题的长文（比如本文）的时候可能会比较方便**。在footer.php中添加以下代码即可：

```

<!-- 标题自动锚点: Start -->
<script>
window.addEventListener('load', function() {
    // 构建标题文本与 Argon ID 的映射表
    const headers = document.querySelectorAll('h1[id], h2[id], h3[id], h4[id], h5[id], h6[id]');
    const textToIdMap = new Map();
    headers.forEach(header => {
        const id = header.id;
        const text = header.textContent.trim();
        textToIdMap.set(text, id); // 标题文本 -> ID 映射
    });
 
    // 替换页面中的基于文本的锚点链接
    const links = document.querySelectorAll('a[href^="#"]');
    links.forEach(link => {
        const targetText = decodeURIComponent(link.getAttribute('href').slice(1)); // 获取锚点文本
        if (textToIdMap.has(targetText)) {
            link.setAttribute('href', `#${textToIdMap.get(targetText)}`); // 替换为 Argon 的 ID
        }
    });
 
    //文外跳转
    if (window.location.hash) {
        const hash = window.location.hash.slice(1);  // 去掉 #
        let targetElement;
        // 优先检查哈希值是否是一个有效的 ID
        targetElement = document.getElementById(hash);
        if (!targetElement) {
            // 如果哈希值是标题文本，检查映射表
            const decodedHash = decodeURIComponent(hash);  // 解码哈希值
            if (textToIdMap.has(decodedHash)) {
                const targetId = textToIdMap.get(decodedHash);  // 获取对应的 ID
                targetElement = document.getElementById(targetId);  // 查找对应 ID 的元素
            }
             // 替换图片的 src 属性
            const lazyImages = document.querySelectorAll('img.lazyload[data-original]');
            lazyImages.forEach(img => {
                img.src = img.getAttribute('data-original'); // 直接替换为真正的图片链接
            });
        }
        // 如果找到了目标元素，滚动到该元素
        if (targetElement) {
            targetElement.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
    }
});
</script>
<!-- 标题自动锚点: End -->
```

使用的时候，在markdown文件中的某个位置添加类似一个内部链接：

```
新增[正文自动添加序号](#正文自动添加序号)，可使长文层次更加分明。
```

然后通过m2w之类的方法上传文章后，就可以实现该功能。个人感觉效果还是不错的。

实际上，通过修改html等参数，还可以实现不同的动画过渡方式； 但我现在已经满足了，就怎么简单怎么来吧 (～￣▽￣)～

不过，这个代码暂时存在几个bug：

- 如果直接访问`http://url#标题`（包括从其它页面跳转过来），图片加载不出来或者不能完美跳转；或者说，**暂时不能完美地支持文外跳转**。因此，如果需要刷新当前页面，可能需要用`Ctrl + ←`来返回至初级URL后才可以刷新，否则将影响图片的展示。
- 屏幕顶部可能出现屏闪
- 容易在移动端里显示异常

日后再想办法修复吧，或者看看其它小伙伴的意见！

#### 文字输入撒花特效

主要参考突突的教程：https://wangwangyz.site/archives/1059

效果类似：

![msedge_Q0bNhsbKDi](https://image.hyly.net/i/2025/09/02/6737eed6d315e9977824931504bb6246-0.gif)

在末尾`</body>`上方加入代码：

```
<!--网站输入效果-->
<script src="https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/js/input-with-fire.js"></script>
```

#### 网站标题可爱字符

主要参考[likepoems](https://likepoems.com/liuyan#comment-61)大佬的网站。类似效果为：

![chrome_mvq9V4FIPf](https://image.hyly.net/i/2025/09/02/96dbd7ab6508bd2db09896e686974663-0.gif)

注意看左边的网站，它在退出/进入网站页面时，会有些可爱字符。

在末尾`</body>`上方加入代码：

```
<!--主题搞笑字符-->
 <!--<script src="https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/js/onfocus.js"></script> -->
```

#### 文字颤抖

效果大致如下：

![chrome_ShoIxttdUV](https://image.hyly.net/i/2025/09/02/a2a15dc39274dbb27b23764ea5ee7210-0.gif)

源代码来自[希卡米 | HiKami](https://hikami.moe/)，我只是大佬代码的搬运工。大致的原理是定义一个`.my-face` class，然后直接在html中调用类的函数。首先，我们在footer.php中添加css脚本：

```
<!--文字抖动特效-->
<link href="https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/css/myface.css" rel="stylesheet">
```

然后，在页脚内容中添加类似命令（以Argon为例）：

```
<div class=""><span class="my-face">Copyright ©2022 版权所有 苯神仔୧(๑•̀⌄•́๑)૭</span></div>
```

后台的填写类似于：

![chrome_pdXQHz2dy7](https://image.hyly.net/i/2025/09/02/3f43f02de157842436f2030e4be3d818-0.webp)

#### WordPress防镜像

有时候别人会把域名`CNAME`解析到我们的域名上边来，然后做镜像站，为了防止这样可以在页面上判断如果根域名不是源站重新跳转刷新下页面，设置如下：

```
<!--WordPress防镜像  -->
<img style="display:none" src=" " onerror='this.onerror=null;var currentDomain="hyly" + ".net"; var str1=currentDomain; str2="docu"+"ment.loca"+"tion.host"; str3=eval(str2) ;if( str1!=str3 ){ do_action = "loca" + "tion." + "href = loca" + "tion.href" + ".rep" + "lace(docu" +"ment"+".loca"+"tion.ho"+"st," + "currentDomain" + ")";eval(do_action) }' />

<img style="display:none" src=" " onerror='
this.onerror=null;
var currentDomain = "hyly.net";
var allowedDomains = [currentDomain, "www." + currentDomain];
var currentHost = document.location.host;
if (!allowedDomains.includes(currentHost)) {
    location.href = location.href.replace(currentHost, currentDomain);
}
' />
```

#### 正文自动添加序号

效果如下：

![msedge_UHYcZ0Jsjl](https://image.hyly.net/i/2025/09/02/ac163c6e9889874e50f567f6d8ea10ea-0.webp)

和大多数特效代码一样，下面内容加至`footer.php`中：

```
<!--正文自动编号-->
<style type="text/css">h1:not(.title){counter-reset:h2counter;counter-increment:h1counter;}h1:not(.title):not(.post-title)::before{content:counter(h1counter) " ";}h2{counter-reset:h3counter;counter-increment:h2counter;}h2:not(.comments-title):not(.post-comment-title)::before{content:counter(h1counter) "." counter(h2counter) " ";}h3{counter-reset:h4counter;counter-increment:h3counter;}h3:not(.text-black)::before{content:counter(h1counter) "." counter(h2counter) "." counter(h3counter) " ";}h4{counter-reset:h5counter;counter-increment:h4counter;}h4:not(.modal-title)::before{content:counter(h1counter) "." counter(h2counter) "." counter(h3counter) "." counter(h4counter) " ";}h5:not(.modal-title){counter-reset:h6counter;counter-increment:h5counter;}h5::before{content:counter(h1counter) "." counter(h2counter) "." counter(h3counter) "." counter(h4counter) "." counter(h5counter) " ";}h6:not(#leftbar_overview_author_name):not(#leftbar_overview_author_description){counter-increment:h6counter;}h6:not(#leftbar_overview_author_name):not(#leftbar_overview_author_description)::before{content:counter(h1counter) "." counter(h2counter) "." counter(h3counter) "." counter(h4counter) "." counter(h5counter) "." counter(h6counter) " ";}body{counter-reset:h1counter;}</style>
```

#### Argon主题点击概要也可以进入文章

在默认情况下，我们的文章只能通过点击标题（绿色框）进入。按这个设置后，你点击概要（红色框）也可以进入文章！

![img](https://image.hyly.net/i/2025/09/02/ccface61055bafe9d23f8594e4cc377b-0.webp)

主要参考：https://wangwangyz.site/archives/835。首先，在主题文件编辑器里修改`post-content`对象后面添加一行代码`onclick="pjaxNavigate('<?php the_permalink(); ?>')" style="cursor: pointer"`：

![msedge_ThRzuXIkBl](https://image.hyly.net/i/2025/09/02/ef81d50a269ede66980e1d12459522e2-0.webp)

`pjaxNavigate`函数的作用是为了保持[Pjax](https://github.com/defunkt/jquery-pjax)效果，即点击链接的时候不会自动刷新页面。我们通过JavaScript定义`pjaxNavigate`函数来调用`pjax`：

```
// 使用 PJAX 进行页面跳转，
function pjaxNavigate(url) {
    $.pjax({
      url: url,       // 要跳转的页面 URL
    });
}
```

如果你使用argon主题，可以放在这个位置（`footer.php`之类的地方也可以）：

![img](https://image.hyly.net/i/2025/09/02/81b0c1dfc4fcc75c6b3e280eabfb3302-0.webp)

#### 字体

字体可以在[字体天下](https://www.fonts.net.cn/)、[100font](https://www.100font.com/)等网站里免费下载。通过[转换](https://cloudconvert.com/ttf-to-woff2)网站获得woff2格式文件。你可以上传到网站根目录或者某个CDN里，然后添加下列额外CSS（具体方法见下）：

```
/*设置网站字体*/
/*原则上你可以设置多个字体，然后在不同的部位使用不同的字体*/
@font-face{
    font-family:btfFont;
    src: url(https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/fonts/13.woff2) format('woff2')
}
body{
    font-family:"btfFont" !important
}
```

这里展示所用的`13.woff2`是**汉唐仪美人体**，它并不是`免费商用字体`。个人博客毕竟是公开的，最好还是使用`免费商用字体`，以免未来有版权纠纷。你也可以在[bloghelper](https://github.com/huangwb8/bloghelper/tree/main/fonts)里看看我之前找过的某些字体，都蛮漂亮的。`font-family: "LXGW WenKai Screen", sans-serif;` 也是个不错的字体。**下文的额外CSS包含了字体设置**，多加注意。

#### 小工具-时间进度条

> 仅限argon主题。

效果如下：

![image-20250902213143051](https://image.hyly.net/i/2025/09/02/0138cef14234f7c65e5a349f81ebe5c8-0.webp)

大致原理是基于html/css/js定义一个时间进度条`b`。然后，将`b`插入到`sidebar.php`的`id="leftbar_part2"`前面，从而实现在左侧栏的目标位置（站点概览的窗口上方）植入`b`。

具体做法如下：

- 下载`progress-wrapper.php`文件。下载地址：[Alist](https://alistrn2.hwb0307.com/softwares/bloghelper/progress-wrapper); [Github](https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/progress-wrapper/progress-wrapper.php)。
- 将`progress-wrapper.php`保存在WordPress根目录下的某个位置。比如，我放的位置是`./specialEffects/progress-wrapper.php`。
- 在主题编辑器中找到`sidebar.php`文件。
- 在`sidebar.php`的`<div id="leftbar_part2" class="widget widget_search card bg-white shadow-sm border-0">`标签前引用命令：`<?php require('./specialEffects/progress-wrapper.php'); ?>`，如图所示：

![Code_ICbJXxK3Rz](https://image.hyly.net/i/2025/09/02/6e2d58c38821856d48a1fe9e2dff790c-0.webp)

其中，`./specialEffects/progress-wrapper.php`是我实际使用的路径，请根据实际情况修改。

此外，`progress-wrapper.php`中有一些重要的参数，可根据实际情况自定义。详见下图：

![Code_T0RS9fREcf](https://image.hyly.net/i/2025/09/02/8f0537a7b77dc847fbac239c8d43ec78-0.webp)

百分比有2种模式，一种是`yearprogress_progresstext`，另一种是`yearprogress_progresstext_full`。`full`会返回一个更加精确的数字：



![msedge_NYshTrFF15](https://image.hyly.net/i/2025/09/02/e78742136e8a0d84a3ca588a633fade5-0.gif)



这个模式效果也不错 (☆ω☆) (☆ω☆) (☆ω☆)。

代码已经给出，大家根据需要也可以自定义，这里不再赘述。总体上，时间进度条小工具的添加和修改并不复杂。请试试看！以下是`progress-wrapper.php`的内容：

```
<!-- 用法
    在sidebar.php中<div id="leftbar_part2" class="widget widget_search card bg-white shadow-sm border-0">标签前引用下列命令即可.
    注意，第一个!记得去掉！
    <!?php require('./specialEffects/progress-wrapper.php'); ?>
-->

<!-- 换行符 -->
<style type="text/css">
    .high01{
        line-height: 0.6rem
    }
</style>

<!-- 主体 -->
<div class="high01"><br></div>
<!--<div class="card bg-white shadow-sm border-0">-->
<div id="leftbar_part1" class="card bg-white shadow-sm border-0">
<div class="progress-wrapper" style="padding: 0.8rem">
        <div class="progress-info">
            <div class="progress-label">
                <span id="yearprogress_yearname" style="color: var(--themecolor); background-color: rgba(var(--themecolor-rgbstr), 0.1); font-size: 1rem"></span>
            </div>
            <div id="yearprogress_text_container" class="progress-percentage">
                <!--<span id="yearprogress_progresstext" style="color: var(--themecolor); font-size: 1rem"></span> -->
                <span id="yearprogress_progresstext_full" style="color: var(--themecolor); font-size: 1rem"></span>
            </div>
        </div>
        <div class="progress" style="background-color: #CE7777">
            <div id="yearprogress_progressbar" class="progress-bar" style="background-color: var(--themecolor)"></div>
            <!-- style="background-color: #CE7777" -->
        </div>
    </div>
    <script no-pjax="">
        function yearprogress_refresh() {
            let year = new Date().getFullYear();
            $("#yearprogress_yearname").text(year);
            let from = new Date(year, 0, 1, 0, 0, 0);
            let to = new Date(year, 11, 31, 23, 59, 59);
            let now = new Date();
            let progress = (((now - from) / (to - from + 1)) * 100).toFixed(7);
            let progressshort = (((now - from) / (to - from + 1)) * 100).toFixed(2);
            $("#yearprogress_progresstext").text(progressshort + "%");
            $("#yearprogress_progresstext_full").text(progress + "%");
            $("#yearprogress_progressbar").css("width", progress + "%");
        }
        yearprogress_refresh();
        if (typeof yearProgressIntervalHasSet == "undefined") {
            var yearProgressIntervalHasSet = true;
            setInterval(function () {
                yearprogress_refresh();
            }, 500);
        }
    </script>
    <style>
        #yearprogress_text_container {
            width: 100%;
            height: 22px;
            overflow: hidden;
            user-select: none;
        }

        #yearprogress_text_container>span {
            transition: all 0.3s ease;
        }

        /* #yearprogress_text_container:hover>span {
            transform: translateY(-20px);
        } */
    </style>
</div>
<!-- <div class="high01"><br></div> -->
```

以上设置时间进度条会有重叠的情况，据测试，argon主题判断向上隐藏某卡片时依据其ID标签是否为`left_part1`。因此，基本的思路是给时间进度条添加该标签，然后将旧标签删除（原来是属于搜索框的）。修复方法如下：

给时间进度条添加`leftbar_part1`的标签：

![Code_FgGYs4357N](https://image.hyly.net/i/2025/09/02/18a719918f75a18d8d7e41fd2b54f015-0.webp)

将sidebar.php中原来的left_part1对应的ID标签删除：

![Code_CWOTA8kuXo](https://image.hyly.net/i/2025/09/02/cca0f22aa40bb79e37fa910245801d15-0.webp)

由[jacky567](https://jacky567.top/)提供解决方案：修改`argontheme.js`代码，改变`part1OffsetTop`的赋值。用于解决**移动端菜单栏不能自动隐藏**的bug。

![Code_C1poLKNcqw](https://image.hyly.net/i/2025/09/02/b7b6ccaaaa72f67914dfeffd7d62518c-0.webp)

新代码为：

```
let part1OffsetTop = document.getElementById('open_sidebar').offsetParent == null?$('#leftbar_part1').offset().top:0;
```

修改并保存后即时生效。注意事项：

- 后面两处代码的开头没有`let`
- 如果您使用了CDN托管argon主题资源，您应该去CDN托管的后台里修改`argontheme.js`文件

#### 额外CSS

> 仅限argon主题。

额外CSS一般用于增加一些自定义样式，比较改大某些字体的属性（大小、颜色）。这里修改的好处就是主题切换、升级时，该设置也不会丢失。

如果你想自定义CSS，最好通过**Chrome/Edge浏览器+F12键**探索一下。下面的内容部分参考了鸦鸦的[Argon 主题修改记录](https://crowya.com/681)，我还进行了一些增删。有这些CSS加持，整个主题视觉效果好得多！

我们可以从后台左侧栏的`外观——自定义`，找到`额外CSS`：

![image-20220504182202850](https://image.hyly.net/i/2025/09/02/08a847ea44c1d02dd09d3d016b8436f5-0.webp)

在左下方空白处填写（按需增删）：

```
<style type="text/css" id="wp-custom-css">
			
/*设置网站字体*/
/*原则上你可以设置多个字体，然后在不同的部位使用不同的字体*/
@font-face{
    font-family:btfFont;
  src: url(https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/fonts/13.woff2) format('woff2') 
  /*     src: url(https://bensz.onmicrosoft.cn/fonts/13.woff2) format('woff2')*/

}
body{
    font-family:"btfFont" !important
}

/*设置加粗字体颜色*/
strong {
    color: #A7727D;
}
html.darkmode strong {
    color: #FAAB78;
}

/*说说预览模式*/
pre {
    /*白天*/
    color: #A7727D;
}
html.darkmode pre {
    /*夜晚*/
    color: #FAAB78;
}

/* Github卡片样式*/
.github-info-card-header a {
    /*Github卡片抬头颜色*/
    color: black !important;
    font-size: 1.5rem;
}
html.darkmode .github-info-card-header a {
    /*Github卡片抬头颜色——夜间*/
    color: #FAAB78 !important;
    font-size: 1.5rem;
}
.github-info-card {
    /*Github卡片文字（非链接）*/
	font-size: 1rem;
    color: black !important;
}
html.darkmode .github-info-card {
    /*Github卡片文字（非链接）——夜间*/
	font-size: 1rem;
    color: #FAAB78 !important;
}
.github-info-card.github-info-card-full.card.shadow-sm {
    /*Github卡片背景色*/
    background-color: rgba(var(--themecolor-rgbstr), 0.1) !important;
}

/*横幅字体大小*/
.banner-title {
  font-size: 2.5em;
}
.banner-subtitle{
  font-size: 20px;
}

/*文章标题字体大小*/
.post-title {
	font-size: 30px
}

/*正文字体大小（不包含代码）*/
.post-content p{
	font-size: 1.25rem;
}
li{
    font-size: 1.2rem;
}

/*评论区字体大小*/
p {
	font-size: 1.2rem
}

/*评论发送区字体大小*/
.form-control{
	font-size: 1.2rem
}

/*评论勾选项目字体大小*/
.custom-checkbox .custom-control-input~.custom-control-label{
	font-size: 1.2rem
}
/*评论区代码的强调色*/
code {
  color: rgba(var(--themecolor-rgbstr));
}

/*说说字体大小和颜色设置*/
.shuoshuo-title {
	font-size: 25px;
/* 	color: rgba(var(--themecolor-rgbstr)); */
}

/*尾注字体大小*/
.additional-content-after-post{
    font-size: 1.2rem
}

/*========颜色设置===========*/

/*文章或页面的正文颜色*/
body{
	color:#364863
}

/*引文属性设置*/
blockquote {
	/*添加弱主题色为背景色*/
	background: rgba(var(--themecolor-rgbstr), 0.1) !important;
    width: 100%
}

/*引文颜色 建议用主题色*/
:root {
    /*也可以用类似于--color-border-on-foreground-deeper: #009688;这样的命令*/
	--color-border-on-foreground-deeper: rgba(var(--themecolor-rgbstr));
}

/*左侧菜单栏突出颜色修改*/
.leftbar-menu-item > a:hover, .leftbar-menu-item.current > a{
	background-color: #f9f9f980;
}
 
/*站点概览分隔线颜色修改*/
.site-state-item{
	border-left: 1px solid #aaa;
}
.site-friend-links-title {
	border-top: 1px dotted #aaa;
}
#leftbar_tab_tools ul li {
    padding-top: 3px;
    padding-bottom: 3px;
    border-bottom:none;
}
html.darkmode #leftbar_tab_tools ul li {
    border-bottom:none;
}

/*左侧栏搜索框的颜色*/
button#leftbar_search_container {
    background-color: transparent;
}

/*========透明设置===========*/

/*白天卡片背景透明*/
.card{
	background-color:rgba(255, 255, 255, 0.85) !important;
	/*backdrop-filter:blur(6px);*//*毛玻璃效果主要属性*/
	-webkit-backdrop-filter:blur(6px);
}

/*小工具栏背景完全透明*/
/*小工具栏是card的子元素，如果用同一个透明度会叠加变色，故改为完全透明*/
.card .widget,.darkmode .card .widget,#post_content > div > div > div.argon-timeline-card.card.bg-gradient-secondary.archive-timeline-title{
	background-color:#ffffff00 !important;
	backdrop-filter:none;
	-webkit-backdrop-filter:none;
}
.emotion-keyboard,#fabtn_blog_settings_popup{
	background-color:rgba(255, 255, 255, 0.95) !important;
}
 
/*分类卡片透明*/
.bg-gradient-secondary{
	background:rgba(255, 255, 255, 0.1) !important;
	backdrop-filter: blur(10px);
	-webkit-backdrop-filter:blur(10px);
}
 
/*夜间透明*/
html.darkmode.bg-white,html.darkmode .card,html.darkmode #footer{
	background:rgba(66, 66, 66, 0.9) !important;
}
html.darkmode #fabtn_blog_settings_popup{
	background:rgba(66, 66, 66, 0.95) !important;
}

/*标签背景
.post-meta-detail-tag {
	background:rgba(255, 255, 255, 0.5)!important;
}*/


/*========排版设置===========*/

/*左侧栏层级置于上层*/
#leftbar_part1 {
    z-index: 1;
}

/*分类卡片文本居中*/
#content > div.page-information-card-container > div > div{
	text-align:center;
}
 
/*子菜单对齐及样式调整*/
.dropdown-menu .dropdown-item>i{
    width: 10px;
}
.dropdown-menu>a {
	color:var(--themecolor);
}
.dropdown-menu{
	min-width:max-content;
}
.dropdown-menu .dropdown-item {
	padding: .5rem 1.5rem 0.5rem 1rem;
}
.leftbar-menu-subitem{
	min-width:max-content;
}
.leftbar-menu-subitem .leftbar-menu-item>a{
	padding: 0rem 1.5rem 0rem 1rem;
}
 
/*左侧栏边距修改*/
.tab-content{
	padding:10px 0px 0px 0px !important;
}
.site-author-links{
	padding:0px 0px 0px 10px ;
}
/*目录位置偏移修改*/
#leftbar_catalog{
	margin-left: 0px;
}
/*目录条目边距修改*/
#leftbar_catalog .index-link{
	padding: 4px 4px 4px 4px;
}
/*左侧栏小工具栏字体缩小*/
#leftbar_tab_tools{
	font-size: 14px;
}
 
/*正文图片边距修改*/
article figure {margin:0;}
/*正文图片居中显示*/
.fancybox-wrapper {
    margin: auto;
}
/*正文表格样式修改*/
article table > tbody > tr > td,
article table > tbody > tr > th,
article table > tfoot > tr > td,
article table > tfoot > tr > th,
article table > thead > tr > td,
article table > thead > tr > th{
	padding: 8px 10px;
	border: 1px solid;
}
/*表格居中样式*/
.wp-block-table.aligncenter{margin:10px auto;}
 
/*回顶图标放大*/
button#fabtn_back_to_top, button#fabtn_go_to_comment, button#fabtn_toggle_blog_settings_popup, button#fabtn_toggle_sides, button#fabtn_open_sidebar{
	font-size: 1.2rem;
}
 
/*顶栏菜单*/
/*这里也可以设置刚刚我们设置的btfFont字体。试试看！*/
.navbar-nav .nav-link {
	font-size: 1.2rem;
	font-family: 'btfFont';
}
.nav-link-inner--text {
	/*顶栏菜单字体大小*/
	font-size: 1.1rem;
}
.navbar-nav .nav-item {
	margin-right:0;
}
.mr-lg-5, .mx-lg-5 {
	margin-right:1rem !important;
}
.navbar-toggler-icon {
	width: 1.5rem;
	height: 1.5rem;
}
.navbar-expand-lg .navbar-nav .nav-link {
	padding-right: 0.9rem;
	padding-left: 1rem;
}

/*顶栏图标*/
.navbar-brand {
	font-family: 'Noto Serif SC',serif;
	font-size: 1.25rem;
	/*顶栏图标边界微调*/
	margin-right: 0rem; /*左右偏移*/
	padding-bottom: 0.3rem;
}
.navbar-brand img { 
  /* 图片高度*/
	height: 24px;
}

/*隐藏wp-SEO插件带来的线条阴影（不一定要装）*/
*[style='position: relative; z-index: 99998;'] {
    display: none;
}

/*头像调大*/
#leftbar_overview_author_image{
  width: 180px !important;
  height: 180px !important;
}

/*网站黑白色（悼念）需要添加在最底部否则容易与其它样式冲突*/
/* html {
	filter: grayscale(100%);
	-webkit-filter: grayscale(100%);
	-moz-filter: grayscale(100%);
	-ms-filter: grayscale(100%);
	-o-filter: grayscale(100%);
	filter: url("data:image/svg+xml;utf8,#grayscale");
	filter:progid:DXImageTransform.Microsoft.BasicImage(grayscale=1);
	-webkit-filter: grayscale(1);
} */		
</style>
```

如果你不太懂某一项的意义，可以评论区留言咨询，有空我会解答！

如果你对我正在使用的额外CSS感兴趣，也可以直接查看我博客网页的源代码，**搜索`wp-custom-css`即可快速定位**：

![chrome_0dEZyK2GCm](https://image.hyly.net/i/2025/09/02/ff6637b40bdf191058b6e4cd9f948d1e-0.webp)

#### font awesome v7

v7有一些特别的图标。在`/usr/apps/blog/wordpressData/wp-content/themes/argon/functions.php`里添加以下代码：

```
//保留旧版本图标并引入新版本图标库
function enqueue_font_awesome_shim() {
    wp_enqueue_style( 'fa7', 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.0/css/all.min.css' );
    wp_enqueue_style( 'fa7-v4-shims', 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.0/css/v4-shims.min.css' );
}
add_action( 'wp_enqueue_scripts', 'enqueue_font_awesome_shim' );
```

在这里搜索图标：https://fontawesome.com/search。与v4版本相比有很多新的图标。

#### 悼念色

遇到国家重要人物逝世、抗战纪念日等重大时点，为了表示悲悼，很多网站会选择全黑白的配色。效果如下：

![msedge_de9fvZAeB8](https://image.hyly.net/i/2025/09/03/0194fa0ee2333a4c0c9fc9d9e6297ecc-0.gif)

只需要在**额外CSS的最底部**（否则容易和其它CSS代码冲突）添加下列代码即可：

```
/*网站黑白色（悼念）*/
html {
    filter: grayscale(100%);
    -webkit-filter: grayscale(100%);
    -moz-filter: grayscale(100%);
    -ms-filter: grayscale(100%);
    -o-filter: grayscale(100%);
    filter: url("data:image/svg+xml;utf8,#grayscale");
    filter:progid:DXImageTransform.Microsoft.BasicImage(grayscale=1);
    -webkit-filter: grayscale(1);
}
```

该CSS代码对于任何WordPress主题都是适用的。

#### 春节灯笼挂件

> 参考《[WordPress 博客添加春节红灯笼挂件](https://wuzuhua.cn/3574.html)》

效果大致如下：

![msedge_dGHptIn4oK](https://image.hyly.net/i/2025/09/03/89caae8425ff1286c7ba91ee6cbbb5dd-0.gif)

**方法一**：在footer.php的`</body>`标签前加入下列HTML代码：

```
<!--春节灯笼-->
<link href="https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/css/deng.css" rel="stylesheet">
<div class="deng-box">
<div class="deng">
<div class="xian"></div>
<div class="deng-a">
<div class="deng-b"><div class="deng-t">春节</div></div>
</div>
<div class="shui shui-a"><div class="shui-c"></div><div class="shui-b"></div></div>
</div>
</div>
 
<div class="deng-box1">
<div class="deng">
<div class="xian"></div>
<div class="deng-a">
<div class="deng-b"><div class="deng-t">快乐</div></div>
</div>
<div class="shui shui-a"><div class="shui-c"></div><div class="shui-b"></div></div>
</div>
</div>
```

**方法二**：像我一样，为了利用js的设备判断，在js中加入代码：

```
// 春节灯笼
document.write('<link href="https://cdn.jsdelivr.net/gh/huangwb8/bloghelper@latest/css/deng.css" rel="stylesheet">');
document.write('<div class="deng-box"><div class="deng"><div class="xian"></div><div class="deng-a"><div class="deng-b"><div class="deng-t">春节</div></div></div><div class="shui shui-a"><div class="shui-c"></div><div class="shui-b"></div></div></div></div>');
document.write('<div class="deng-box1"><div class="deng"><div class="xian"></div><div class="deng-a"><div class="deng-b"><div class="deng-t">快乐</div></div></div><div class="shui shui-a"><div class="shui-c"></div><div class="shui-b"></div></div></div></div>');
```

如下图所示：

![image-20230101163417424](https://image.hyly.net/i/2025/09/02/f7bcf41a6a6bb8467b27ca29764e417d-0.webp)

####  运行时间、耗时及占用内存

在`footer.php`同级目录新建文件夹和文件`/specialEffects/timeRAM.php`，以下是详细内容，图省事可以直接复制使用，下方有详细说明。

```
<!--耗时及占用内存开始-->
<span id="momk"></span><span id="momk" style="color: #ff0000;"></span>
<script type="text/javascript">
function NewDate(str) {
str = str.split('-');
var date = new Date();
date.setUTCFullYear(str[0], str[1] - 1, str[2]);
date.setUTCHours(0, 0, 0, 0);
return date;
}
function momxc() {
var birthDay =NewDate("2025-07-01");
var today=new Date();
var timeold=today.getTime()-birthDay.getTime();
var sectimeold=timeold/1000
var secondsold=Math.floor(sectimeold);
var msPerDay=24*60*60*1000; var e_daysold=timeold/msPerDay;
var daysold=Math.floor(e_daysold);
var e_hrsold=(daysold-e_daysold)*-24;
var hrsold=Math.floor(e_hrsold);
var e_minsold=(hrsold-e_hrsold)*-60;
var minsold=Math.floor((hrsold-e_hrsold)*-60); var seconds=Math.floor((minsold-e_minsold)*-60).toString();
document.getElementById("momk").innerHTML = "本站已安全运行："+daysold+"天"+hrsold+"小时"+minsold+"分"+seconds+"秒<br>";
setTimeout(momxc, 1000);
}momxc();
</script>
<style>
#momk{animation:change 10s infinite;font-weight:800; }
@keyframes change{0%{color:#5cb85c;}25%{color:#556bd8;}50%{color:#e40707;}75%{color:#66e616;}100% {color:#67bd31;}}
</style>
<?php printf(' | 耗时 %.3f 秒 | 查询 %d 次 | 内存 %.2f MB |',timer_stop( 0, 3 ),get_num_queries(),memory_get_peak_usage() / 1024 / 1024);?>
<br>
<!--耗时及占用内存结束-->
```

添加后显示效果如下：

![image-20250902201210232](https://image.hyly.net/i/2025/09/02/1385a1c7a8907cefd2fd25ba8a777d94-0.webp)

#### 禁用wordpress大小写转换器

问题源于我文章名都是用**wordpress**小写或者不标准的大小写，发布文章的时候WordPress会转换成标准的**WordPresss**文章名，导致发布的名称不对，再次使用m2w发布文章的时候获取文章列表跟本地的对比就对比不上，文章就会重新发布。解决起来也很简单，只需要在`funtions.php`添加以下代码即可：

```
# 禁用 capital_P_dangit 过滤器，这个函数专门用来 自动把“Wordpress”修正成“WordPress”。
remove_filter( 'the_title', 'capital_P_dangit', 11 );
remove_filter( 'the_content', 'capital_P_dangit', 11 );
remove_filter( 'comment_text', 'capital_P_dangit', 31 );
```

## Wordpress页面配置

新近成立的个人博客通常还会有一些特殊页面，比如`关于我`、`留言板`、`说说`、`友情链接`、`归档`、`隐私政策`等。它会让你的博客布局更加丰满、更加成熟一些。它们均可以通过`页面`来进行配置。

在后台，我们可以通过`页面`进入并添加和设置新页面，页面可以设置wordpress里的特色页面和一般页面，主要是通过模板来选择的：

![image-20250902230024787](https://image.hyly.net/i/2025/09/02/e6bf1bbff6c0eb78ed23205c76982e03-0.webp)

### 留言板

首先我们添加一个页面，标题写为留言板然后把模板设置为留言板就可以了：

![image-20250902230847964](https://image.hyly.net/i/2025/09/02/737677317b1e380456a256e7cbc5dfc0-0.webp)

同时进行一些简单的文章设置就可以了：

![image-20250902230928096](https://image.hyly.net/i/2025/09/02/f77e28aa933762ad9e3c55399905f23a-0.webp)

接下来把它添加到菜单里就可以了，等会我们统一添加。

### 关于我

我们新建一个`关于我`的页面用于自我介绍。我觉得这个页面是比较重要的，它可以**让访客快速了解你**。

作为展示，我随便写些内容进去：

![image-20250902231129037](https://image.hyly.net/i/2025/09/02/201c8d063e33534c797f042027b0c7aa-0.webp)

模板用默认的就行。`文章设置`可以自己自定义，这个看自己喜好。

### 友情链接

**友情链接其实是非常重要的**！这或许是一个最简单的SEO了！简单来说，就是互加一些志同道合的朋友，在一定程度上可以增加自己网站的曝光度。知乎上也有相关的问题及回答，比如：[友情链接有什么用？详解友链的四大作用？](https://zhuanlan.zhihu.com/p/254930811)。自己去了解吧！

在Argon里，友情链接的实现非常简洁。不知道其它主题是不是也是类似！

我们要先安装启用一个插件，叫`iframe`。这个插件是用于进行`shortcode`的插入:

![image-20220428145402733](https://image.hyly.net/i/2025/09/02/d28fc49d394472ae5e2d07478b3561c0-0.webp)

我们用默认模板新建一个页面，并且添加一个`简码`。类似于：

![image-20220428145555758](https://image.hyly.net/i/2025/09/02/937a1177826982f61622e45b8fef8195-0.webp)

我们在里面加入：

![image-20250902231827987](https://image.hyly.net/i/2025/09/02/0967a35f833a6db6bc85725c7941d1e7-0.webp)

除了简码之外的文本内容可以根据自己情况修改：

```
<blockquote class="wp-block-quote is-layout-flow wp-block-quote-is-layout-flow">
<p>下列友链与本博客相互独立，并不代表Mark认同并支持友链博客的观点。如果小伙伴们发现友链内有<strong>不寻常内容</strong>（如涉黄赌毒）可评论区留言提醒，在此先谢过了！Mark将视情况严重程度予以删除。互联网远不是一片净土，更不是法外之地，希望小伙伴们保持思想独立和积极心态！另外，我偶尔会清理不能访问的站点，不会特别通知站长，敬请见谅喔 (ฅ´ω`ฅ)</p>
</blockquote>
<h1 class="wp-block-heading has-text-align-center" id="h-多财多亿的小伙伴们">多财多亿的小伙伴们</h1>


[friendlinks sort="rating" order="DESC" /]


<h1 class="wp-block-heading has-text-align-center" id="h-欢迎交换友链">欢迎交换友链(～￣▽￣)～ </h1>
<ul class="wp-block-list">
<li>站点名称：梦呓</li>
<li>站点地址：https://hyly.net/</li>
<li>站点描述：我们是看故事的人，故事里的人是我们。</li>
<li>站点图标：https://hyly.net/wp-content/uploads/logo.jpg</li>
</ul>
<h1 class="wp-block-heading has-text-align-center" id="h-友链交换原则">友链交换原则( *︾▽︾)</h1>
<ul class="wp-block-list">
<li>必选：<strong>全站使用https。恕不添加http个人网站</strong>。（技术和安全上有一个小门槛）</li>
<li>必选：互相添加（话说这世上真的有白嫖党吗）</li>
<li>必选：颜值高（话说有人觉得自己的博客颜值不高的吗）</li>
<li>必选：颜值高 （话说有人觉得自己的博客颜值不高的吗）</li>
<li>必选：颜值高（话说有人觉得自己的博客颜值不高的吗）</li>
<li>可选：博客内容为类似话题</li>
<li><strong>大家把友链按照格式在下方评论留言即可，博主看到会添加的，不能添加也会在下边评论回复。</strong></li>
</ul>
```

这里，可以在`链接`里添加内容：

![image-20250902232612207](https://image.hyly.net/i/2025/09/02/aedbd9ab2e337bf684aaf90172c570ae-0.webp)

比如，你可以试试添加我的友链：

```
站点名称：梦呓
站点地址：https://hyly.net/
站点描述：我们是看故事的人，故事里的人是我们。
站点图标：https://hyly.net/wp-content/uploads/logo.jpg
```

如图所示：

![image-20250902232811297](https://image.hyly.net/i/2025/09/03/e71623a44ae16c9accfe0b34f4c47e7a-0.webp)

记得按`添加链接`保存。弄好之后效果是这样的，这是我添加了一个别人的友链：

![image-20250902232333006](https://image.hyly.net/i/2025/09/02/846de967e4a1f4a8d76c76f6940b1bc3-0.webp)

当然，这个页面你可以加一些内容进去。比如加上你的友链信息、加你友链的限制条件等等。这个你模仿一下别人吧！没有什么固定的规则，全凭个人喜好。

在实际操作中，我比较喜欢使用额外参数。比如，我页面中的实际代码是：

```
[friendlinks sort="rating" order="DESC" /]
```

这个的意思是说，我要按评分进行倒序排序。如果你想将喜欢的博主往前排，就将TA的评分值调低一些，这样TA就会排在比较前面。

更多的参数设置可以看argon文档的[友链参数](https://argon-docs.solstice23.top/#/shortcode/friendlinks?id=参数)。

最后，还有一种[旧短代码](https://argon-docs-old.solstice23.top/shortcode/friendlinks-old)的使用方式，大家也可以试试看：

```
[sfriendlinks] link|https://www.ruanyifeng.com/blog/|阮一峰|阮一峰的网络日志|https://www.ruanyifeng.com/blog/images/person2_s.jpg [/sfriendlinks]
```

结果如下：

![image-20250902233122202](https://image.hyly.net/i/2025/09/02/91dc3523afafb2bf00f4adbc32ef12a7-0.webp)

### 归档/时光轴

新建一个归档页面，模板主要选为**归档时间轴**即可：

![image-20250903103123449](https://image.hyly.net/i/2025/09/03/d3b41e2646ba40012bf730d5f39fbb8c-0.webp)

`归档`页面的效果大致是这样的：

![image-20250903103203554](https://image.hyly.net/i/2025/09/03/77f301a871f5e60619ba76f3290c1b3b-0.webp)

记得刚刚开始设置的时候，对于`页面`的概念不是很理解，不太清楚它和`文章`的区别。现在我知道，**WordPress页面适合用来适合一些数量和内容均比较有限的信息**。其实和文章没有太大的区别！

## Wordpress菜单配置

![image-20250903103737048](https://image.hyly.net/i/2025/09/03/177f07134dcb878fe1b2b63ed843e2e2-0.webp)

设置完效果是这样的：

![image-20250903104157688](https://image.hyly.net/i/2025/09/03/4c74753a9c48c52150fb783ef9dda521-0.webp)

## 小工具配置

小工具可以在外观->小工具这里可以配置的：

![image-20250903105037250](https://image.hyly.net/i/2025/09/03/e9c7ef29f734e099c98d5600e307b0c7-0.webp)

## 小结

相信大家经过上面的设置，博客会变得比之前炫酷多了，如果配置过程中有什么问题可以在文章下方留言，喜欢的小伙伴也麻烦多点赞转发哈~

## 扩展阅读

1. [Docker系列 WordPress系列 特效](https://blognas.hwb0307.com/linux/docker/744)
