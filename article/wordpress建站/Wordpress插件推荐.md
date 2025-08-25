---
category: [博客建站]
tag: [wordpress插件]
postType: post
status: publish
---

# 前言

当初决定使用Wordpress有一个关键点就是其拥有强大的插件系统，可以像可替换武器库一样给wordpress这个基础配备强大的火力，这也是吸引我的一点。符合我当初博客选定的要求：

> 选型要求：花20%的精力就能达到80%的效果。并且博客平台有一定想象拓展空间，可以更精进一步。当然使用人数要多社区活跃，解决问题也好解决。

# Akismet

Akismet 是 WordPress 官方出品的一个反垃圾插件/服务，主要用来自动过滤垃圾评论和垃圾表单提交。这个插件默认就已经安装了，只需要启用就可以了，没有安装的可以在插件市场搜索安装启用：

![image-20250821193340632](https://image.hyly.net/i/2025/08/21/7bf7cce5a4687b7c340b4e082e4313f8-0.webp)

使用倒是挺简单的，在wordpress后台左侧菜单栏设置->Akismet 反垃圾评论菜单栏打开设置。页面如下：

![image-20250821193813067](https://image.hyly.net/i/2025/08/21/f296966651249204418198862ea7795a-0.webp)

首先需要注册一个账号，完成之后会有一个密钥填写进去，然后设置下评论的基础选项就可以了，因为博主自己也没有遇到过垃圾评论的情况，也不知道好不好用，不过既然官网推荐的，先安装上吧，有总比没有强。╮(╯▽╰)╭

# Custom Post Type UI

Custom Post Type UI主要用来创建和管理自定义文章类型和自定义分类法。

 **作用：**

1. **创建自定义文章类型**
	1. WordPress 默认只有几种文章类型，比如 **文章（post）、页面（page）、附件（attachment）**。
	2. 如果你的网站需要额外的内容类型（比如：产品、案例、视频、活动、课程、FAQ 等），就可以用 CPT UI 来创建。
2. **创建和管理自定义分类法**
	1. 除了默认的 **分类（category）** 和 **标签（tag）**，你还可以定义自己的分类体系，比如：产品品牌、难度等级、课程分类等。
3. **可视化操作**
	1. 不用自己写 PHP 代码（`register_post_type()`、`register_taxonomy()`），直接在后台界面点选设置就能生成。
	2. 节省时间，也降低了出错概率。
4. **和其他插件配合**
	1. 常常和 **Advanced Custom Fields (ACF)** 一起使用：
		1. CPT UI 负责创建“内容类型”
		2. ACF 负责为这些内容类型添加更多自定义字段（比如价格、作者、视频链接）。

我使用它主要是我要给我的说说添加分类，文章有分类，进而通过分类来添加菜单，但是说说没有，如下图：可能这对大部分人来说不重要，但这对我来说是刚需！

![image-20250821205444282](https://image.hyly.net/i/2025/08/21/552cf797332eae7ab8af8bbc3c25216e-0.webp)

## 使用

首先在插件市场安装启用：

![image-20250821205835266](https://image.hyly.net/i/2025/08/21/b631b7c388877a48de80500b49989ff1-0.webp)

其次先注册一个分类，附加到说说类型上。只需要填写上半部分就可以，下面默认就行，下方的截图我附加上了每项都是什么意思的中文说明。

![image-20250821210659180](https://image.hyly.net/i/2025/08/21/6e990b424b0e1d36acd573f12f3f7047-0.webp)

![image-20250821210743971](https://image.hyly.net/i/2025/08/22/3af2fb38ab1d2465f4c023f1cdcd2c2a-0.webp)

发说说的时候就会有分类选项：

![image-20250821211149550](https://image.hyly.net/i/2025/08/21/aa527bd7ff17a7422a44a7b842bce8c9-0.webp)

说说菜单栏下也会多个说说分类菜单可以查看已经创建的分类：

![image-20250821214444631](https://image.hyly.net/i/2025/08/21/42312c11e20299dd94d056bf246f1191-0.webp)

## 根据分类查询说说

文件位于`/usr/apps/blog/wordpressData/wp-content/themes/argon/functions.php`，接下来还应在functions.php文件添加以下配置：

```
//给说说添加分类搜索。
function fix_custom_post_type_category_archive($query) {
    if (!is_admin() && $query->is_main_query() && is_tax('shuoshuo_category')) {
        $query->set('post_type', array('shuoshuo'));
    }
}
add_action('pre_get_posts', 'fix_custom_post_type_category_archive');
```

这个配置是为了实现可以根据分类搜索出说说，实际效果如下：

![image-20250822112124658](https://image.hyly.net/i/2025/08/22/aa5ddd654866504548448793bb6e22ca-0.webp)

至此就能实现wordpress后台发布说说时添加分类，然后前端页面根据分类搜索出对应分类的说说了。

##  实现说说接口增删改查功能
如果是后台编写说说并发布的小伙伴到这里就可以了。但是我们是通过m2w工具接口上传说说/文章到wordpress，所以为了提供说说上传接口能正确的添加说说分类，我们还需要创建说说的增删改查函数并赋予正确的分类。同样是在`functions.php`文件最后边添加：

```
// 在 REST API 中注册自定义路由,实现说说的增删改
function register_shuoshuo_route() {
    register_rest_route('wp/v2', '/shuoshuo', [
        // 创建说说的 POST 请求
        'methods' => 'POST',
        'callback' => 'create_shuoshuo_callback',
        'permission_callback' => function() {
        // 检查当前用户是否有发布文章的权限
        if (current_user_can('publish_posts')) {
            return true; // 用户有权限
        } else {
            return new WP_Error('rest_forbidden', __('You cannot create a shuoshuo because you do not have the required permissions.'), ['status' => 403]);
        }
    },
    ]);
    
    // 修改说说的 PUT 请求
    register_rest_route('wp/v2', '/shuoshuo', [
        'methods' => 'PUT',
        'callback' => 'update_shuoshuo_callback',
        'permission_callback' => function() {
            // 检查当前用户是否有发布文章的权限
            if (current_user_can('publish_posts')) {
                return true; // 用户有权限
            } else {
                return new WP_Error('rest_forbidden', __('You cannot update a shuoshuo because you do not have the required permissions.'), ['status' => 403]);
            }
        },
    ]);

    
    // 删除说说的 DELETE 请求
    register_rest_route('wp/v2', '/shuoshuo/(?P<title>.+)', [
        'methods' => 'DELETE',
        'callback' => 'delete_shuoshuo_callback',
        'permission_callback' => function() {
            // 检查当前用户是否有删除文章的权限
            if (current_user_can('delete_posts')) {
                return true; // 用户有权限
            } else {
                return new WP_Error('rest_forbidden', __('You cannot delete a shuoshuo because you do not have the required permissions.'), ['status' => 403]);
            }
        },
    ]);
    // 获取说说列表
    register_rest_route('wp/v2', '/shuoshuo', [
        'methods' => 'GET',
        'callback' => 'get_shuoshuo_list_callback',
        'permission_callback' => '__return_true', // 不需要登录也能访问
        'args' => [
            'page' => [
                'default' => 1,
                'sanitize_callback' => 'absint',
            ],
            'per_page' => [
                'default' => 10,
                'sanitize_callback' => 'absint',
            ],
        ]
    ]);

}
add_action('rest_api_init', 'register_shuoshuo_route');


#创建说说函数
function create_shuoshuo_callback($data) {
    // 从请求中获取数据
    //还是要title吧虽然前端展示页显的有点杂乱，但是后台管理页面没有标题，都是无标题的了，更不好管理。
    $title = sanitize_text_field($data['title']);
    $content = sanitize_textarea_field($data['content']);
    $categories = isset($data['categories']) ? $data['categories'] : array(); // 说说分类
    //暂时说说先没有标签
    //$tags = isset($data['tags']) ? $data['tags'] : array(); // 说说标签
    $status = sanitize_text_field($data['status']);

    // 创建新说说
    $post_data = array(
        'post_title'   => $title,
        'post_content' => $content,
        'post_status'  => $status,
        'post_type'    => 'shuoshuo',  // 这里假设“说说”是 WordPress 的标准文章类型
         'tax_input'    => [
            'shuoshuo_category' => $categories,  // 将分类传入税onomies字段
        ],
        // 'post_category' => $category,
        // 'tags_input'   => $tags,
    );

    // 插入说说
    $post_id = wp_insert_post($post_data);

    // 返回响应
    if ($post_id) {
        return new WP_REST_Response('说说创建成功', 200);
    } else {
        return new WP_REST_Response('创建说说失败', 500);
    }
}
//修改说说
function update_shuoshuo_callback($data) {
    // 根据 title 查找现有的说说
    $title = sanitize_text_field($data['title']);
    $content = sanitize_textarea_field($data['content']);
    $categories = isset($data['categories']) ? $data['categories'] : array(); // 获取文章分类
    $tags = isset($data['tags']) ? $data['tags'] : array(); // 获取文章标签

    // 查找标题匹配的文章
    $args = array(
        'post_type' => 'shuoshuo',  // 确保搜索自定义文章类型
        'post_title' => $title,  // 查找标题
        'posts_per_page' => 1,  // 只查找一个文章
        'post_status' => 'publich',  // 查找所有状态的文章
    );

    $post_query = new WP_Query($args);
    if ($post_query->have_posts()) {
        $post = $post_query->posts[0];  // 获取找到的第一个文章

        // 更新文章数据
        $post_data = array(
            'ID'            => $post->ID,  // 文章 ID
            'post_title'    => $title,
            'post_content'  => $content,
             'tax_input'    => [
            'shuoshuo_category' => $categories,  // 将分类传入税onomies字段
        ],
            // 'tags_input'    => $tags,     // 更新标签
        );

        // 更新文章
        $updated_post_id = wp_update_post($post_data);

        // 返回响应
        if ($updated_post_id) {
            return new WP_REST_Response('说说更新成功', 200);
        } else {
            return new WP_REST_Response('更新说说失败', 500);
        }
    } else {
        return new WP_REST_Response('未找到标题为 "' . $title . '" 的说说', 404);
    }
}
// 删除说说的回调函数
function delete_shuoshuo_callback(WP_REST_Request $request) {
    //$title = sanitize_text_field($data['title']); // 获取说说的标题
    $title = sanitize_text_field( $request->get_param('title') );
    // 查找匹配的文章
    $args = array(
        'post_type' => 'shuoshuo',  // 自定义文章类型
        'post_title' => $title,     // 查找标题匹配的文章
        'posts_per_page' => 1,      // 限制只查找一个
        'post_status' => 'any',     // 查找所有状态的文章
    );

    $post_query = new WP_Query($args);
    if ($post_query->have_posts()) {
        $post = $post_query->posts[0];  // 获取找到的第一篇文章

        // 删除文章
        $deleted_post = wp_delete_post($post->ID, true); // 第二个参数为 `true` 代表强制删除，不放入回收站

        // 返回响应
        if ($deleted_post) {
            return new WP_REST_Response('说说删除成功', 200);
        } else {
            return new WP_REST_Response('删除说说失败', 500);
        }
    } else {
        return new WP_REST_Response('未找到标题为 "' . $title . '" 的说说', 404);
    }
}
// 获取说说列表的回调
function get_shuoshuo_list_callback($request) {
    $page = $request->get_param('page');
    $per_page = $request->get_param('per_page');

    $args = [
        'post_type'      => 'shuoshuo',
        'post_status'    => 'publish',
        'paged'          => $page,
        'posts_per_page' => $per_page,
    ];

    $query = new WP_Query($args);

    $data = [];
    foreach ($query->posts as $post) {
        $data[] = [
            'id'      => $post->ID,
            'title'   => get_the_title($post),
            'content' => apply_filters('the_content', $post->post_content),
            'date'    => get_the_date('', $post),
            'link'    => get_permalink($post),
        ];
    }
     // 设置响应头
    $response = rest_ensure_response($data);
    $response->header('x-wp-total', (int) $query->found_posts); // 总条数
    $response->header('x-wp-totalpages', (int) $query->max_num_pages); // 总页数（可选）

    return $response;
}
```

添加这些就可以实现用m2w工具对说说的增删改查了，m2w具体如何使用看这篇文章。

# GTranslate

GTranslate是一个可以让博客文章实现多语言的插件，它是调用谷歌翻译API然后实现对全站的翻译，但是有个小问题就是如果是国内用户访问网站使用翻译的话，因为国内访问不了谷歌翻译API，所以它是不能使用的，只有国外用户使用翻译才能正确翻译，但是网站默认语言是中文的，所以这好像也不算是个问题哈~

## 安装配置

首先在插件市场进行安装启用：

![image-20250822150720998](https://image.hyly.net/i/2025/08/22/53eabd1fc753f230bef14a6000f4e1e6-0.webp)

在设置->GTranslate里就可以进行插件的基本设置，也不太复杂，大家点点就知道怎么回事，我的设置如下：

![image-20250822150949519](https://image.hyly.net/i/2025/08/22/0fcea4af4177bc800d7a0dd6121ba8f6-0.webp)

必须是自己电脑能翻墙到国外网络，或本来就是国外网络翻译才有用。在前端页面的展示效果如下：

![image-20250822151400173](https://image.hyly.net/i/2025/08/22/e714be555fe896e78238f94f69efdd70-0.webp)

这个插件好处就是可以当前页面全部翻译，简单省事。而不像有的插件，你必须自己一个个中文对照的英文键值对填入插件，它才给翻译。

# Permalink Manager Lite

它的作用主要是管理和自定义站点的固定链接，说说/文章/页面/分类链接等。比方说想按照大分类/小分类/id，这样来构造文章的固定链接，或者想给某个页面/文章一个不属于上述规则的特殊固定链接，这个插件就都可以做到。wordpress默认的固定链接结构则很死板，没法更多的定制化。

![image-20250822152333321](https://image.hyly.net/i/2025/08/22/11a5abc41e7b89c35c67d538c2807d90-0.webp)

## 使用配置

首先插件市场进行安装启用：

![image-20250822152447649](https://image.hyly.net/i/2025/08/22/83836e5910d0564ca69c6eb4e604a6af-0.webp)

比较实用的就是修改固定链接的永久结构，可以修改页面/说说/标签/自己添加的说说分类固定链接结构。修改完之后要点重新生成/重置之后历史链接才会按照新规则重新生成一次。

这里没有文章，是因为使用m2w工具上传的文章，在wordpress后台能看到是有分类的，前端页面也是有分类的，但是文章链接却不是设置的大分类/小分类/id这种形式，所以这里去掉了，采用上图wordpress固定链接那种形式。

![image-20250822152559054](https://image.hyly.net/i/2025/08/22/c6acc442cc3e2abb365c8e16f6552f44-0.webp)

可以在URI编辑器这里修改某个文章/页面等的固定链接，达到定制化的效果：

![image-20250822160025220](https://image.hyly.net/i/2025/08/22/fc6ca61ce71245a083c88cbcd73f5b49-0.webp)

# W3 Total Cache

W3 Total Cache 是一个WordPress 缓存优化插件，用于提升网站加载速度和性能。它通过缓存技术减少服务器负担，提高页面的响应速度，尤其对于流量较大的站点非常有帮助。安装了这个插件基本上就不用再安装其他的缓存提速插件了，这款就非常的强大！

## 主要功能

1. **页面缓存 (Page Cache)**
	1. 缓存整个页面的 HTML 输出，减少每次访问时都需要从头开始生成页面。
	2. 提升页面加载速度，减少数据库查询和 PHP 处理。
2. **数据库缓存 (Database Cache)**
	1. 缓存数据库查询结果，减少每次加载页面时对数据库的访问，提高查询响应速度。
3. **对象缓存 (Object Cache)**
	1. 缓存动态内容生成的结果，比如 WordPress 内部的查询、用户信息等，提高数据访问速度。
4. **浏览器缓存 (Browser Cache)**
	1. 指示浏览器缓存静态资源（如图片、CSS、JS 文件），减少每次访问时的加载时间。
	2. 可以通过设置过期时间和缓存策略，提升用户体验。
5. **CDN 集成 (Content Delivery Network)**
	1. 支持与 **CDN**（内容分发网络）集成，将静态资源（如图片、CSS、JavaScript 文件）缓存到全球多个节点，减轻主服务器压力，加速用户访问。
	2. 常与 Cloudflare、MaxCDN 等 CDN 服务搭配使用。
6. **最小化和压缩 (Minify and Compress)**
	1. 自动压缩和合并 CSS、JavaScript 文件，减少页面资源的大小，加快加载速度。
	2. 通过最小化代码，减少 HTTP 请求次数，进一步提升性能。
7. **延迟加载 (Lazy Load)**
	1. 延迟加载图片和其他资源，直到它们在用户的视野内，减少初次加载的时间。
8. **分布式缓存支持 (Reverse Proxy Cache)**
	1. 支持与 **Varnish**、**Nginx**、**Apache** 等反向代理服务器的集成，进一步优化缓存策略。

## 使用配置

首先是插件市场搜索安装启用：

![image-20250822162844690](https://image.hyly.net/i/2025/08/22/c2f3f0f237a1f1e8645a9d6d10320613-0.webp)

如果提示注册的话先去注册一个账户。首先来到仪表盘页面，我是能打开的都打开了：

![image-20250822164921338](https://image.hyly.net/i/2025/08/22/645f7683a2eac30d9f81417d2abf5a12-0.webp)

### 常规配置

因为配置项有很多，大家按照我截图的参照着来就行了：

![image-20250822173724461](https://image.hyly.net/i/2025/08/22/55db46642394260cca7e4e8da6d1977d-0.webp)

> TIPS：一定不要勾选用户体验->延迟加载图像这个选项，会造成站点概览页面头像的显示和页面底部赞赏码的显示。

### 页面缓存高级设置

![image-20250822174010648](https://image.hyly.net/i/2025/08/22/a49f46d2fe454ca1cc8b12d332873cee-0.webp)

### 压缩高级设置

![image-20250822174135506](https://image.hyly.net/i/2025/08/22/55eeddd15601ed80d6beea4cfdb629a7-0.webp)

### 数据库缓存高级设置

数据库缓存是把数据库从磁盘中查出来的结果缓存到内存中，从而提高查询速度，能尽快的给用户返回结果，所以它提示数据库缓存尽量不要选择磁盘存储，要选择Redis或Memcached。但是W3 Total Cache插件跟Redis数据库配置不太友好，没有Memcached一样只需要填写容器名称加端口号就能链接了。详细Memcached的安装可以看这篇文章。

![image-20250822174548658](https://image.hyly.net/i/2025/08/22/13889f4dc7c41bf94c735cb08d586b1b-0.webp)

数据库缓存高级配置详细如下：

![image-20250822174320419](https://image.hyly.net/i/2025/08/22/26dd84b96a7d928f493ce665dc3aec78-0.webp)

### 对象缓存高级设置

对象缓存主要是一些键值对什么的，跟数据库缓存配置差不多，也是选了Memcached作为内存缓存。详细的Memcached配置可以看这篇文章。

![image-20250822175225545](https://image.hyly.net/i/2025/08/22/fc8d65849bfa55347aaf1b835100b2ba-0.webp)

### 浏览器缓存高级设置

这个基本上都是默认配置，大家只需要跟自己的配置简单对照下异同即可。

![image-20250822180554053](https://image.hyly.net/i/2025/08/22/52852494842532b78624acd457bb0827-0.webp)

### Network Performance & Security powered by Cloudflare高级设置

W3 Total Cache这个配置是跟Cloudflare连接，起到统一管理作用，需要取得Cloudflare密钥然后填入这里：

![image-20250822181611443](https://image.hyly.net/i/2025/08/22/5230f58e5714f6c4e8332c0cbed79559-0.webp)

密钥获取设置方式如下：

#### 获取 Cloudflare API Key 的方法

1. 登录 Cloudflare 控制台
2. 进入“我的个人资料”，点击右上角头像 → My Profile（我的资料）
3. 找到 API Tokens / Keys，在左边栏选择 API Tokens，你会看到两类：
	1. Global API Key（全局 API 密钥）
	2. API Tokens（推荐的自定义令牌）
4. 复制 Global API Key（最常用）
	1. 找到 Global API Key → 点击 View → 输入 Cloudflare 登录密码 → 复制密钥。
	2. 这个密钥权限比较大，W3TC 一般用它。
5. 推荐做法：生成 API Token（更安全）
	1. 点击 Create Token
	2. 选择 Edit Cloudflare Workers 或 Cache Purge 模板（按需要选择）。
	3. 设置允许操作的站点 → 生成 API Token。

然后找到上图的位置输入：

- Email Address（你的 Cloudflare 登录邮箱）
- API Key（上面获取的 Global API Key 或 Token）

保存后，W3TC 就能帮你自动清理 Cloudflare 缓存、同步优化设置。

#### 详细高级配置

![image-20250822182542442](https://image.hyly.net/i/2025/08/22/1da74cace5043b551a8ad3867fdf82aa-0.webp)

# Wordfence Security

这个已经在[服务器与博客网站安全](https://hyly.net/categroy/article/code/wordpress/353/#header-id-7)这篇文章里详细介绍过了，这里就不再赘述了。

# WordPress Popular Posts

这个插件你可以理解为 “文章热度榜”工具，主要是用来提高网站文章曝光率和用户粘性 —— 把最受欢迎的文章展示出来，引导访客继续浏览，从而提升 PV 和停留时间。功能如下：

1. **展示热门文章**
	1. 根据文章的 **浏览次数**、**评论数**、**平均浏览量** 等排序，把最受欢迎的内容展示出来。
	2. 可以放在 **侧边栏、小工具区、页脚**，甚至直接调用到主题模板里。
2. **自定义排行规则**
	1. 可以设定时间范围：最近 24 小时 / 7 天 / 30 天 / 全部时间。
	2. 选择按 **浏览量** 或 **评论数** 来计算“热门”。
3. **支持缩略图和摘要**
	1. 热门文章列表里，可以显示文章缩略图、标题、发布日期、评论数、作者等信息。
4. **缓存与性能优化**
	1. 内置缓存，避免每次都实时查询数据库，提升加载速度。
	2. 兼容缓存插件（W3TC、WP Super Cache 等）。
5. **开发者友好**
	1. 提供 **短代码** 和 **PHP 模板标签**，方便插入到任何位置。
	2. 也能配合自定义样式，让热门文章模块更符合主题风格。

## 使用配置

首先插件市场安装启用：

![image-20250822185012128](https://image.hyly.net/i/2025/08/22/ce70703c70d983011be2f613583397d8-0.webp)

其次在左侧菜单栏外观->小工具那里去配置，你可以选择是放在左侧栏小工具还是右侧栏小工具里面，然后点击加号添加一个区块：

![image-20250822185717617](https://image.hyly.net/i/2025/08/22/39d15f86baba16f166e8f3d05efe93e2-0.webp)

我是在右侧栏小工具添加的热门文章，添加完成可以按照这样设置：

![image-20250822185958046](https://image.hyly.net/i/2025/08/22/fa9d7498f7be9c4ac544c4b2640fe3e9-0.webp)

最后发布几篇文章，每篇文章有不同的浏览量，就会在博客页面上出现这个最热文章小工具了。效果如下所示：



