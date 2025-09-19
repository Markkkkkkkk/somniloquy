---
category: [博客建站]
tag: [wordpress,插件]
postType: post
status: publish
---

## 前言

当初决定使用Wordpress有一个关键点就是拥有强大的插件系统，可以像可替换武器库一样给wordpress这个基础配备强大的火力，这也是吸引我的一点。符合我当初博客选定的要求：

> 选型要求：花20%的精力就能达到80%的效果。并且博客平台有一定想象拓展空间，可以更精进一步。当然使用人数要多社区活跃，解决问题也好解决。

## Akismet

Akismet 是 WordPress 官方出品的一个反垃圾插件/服务，主要用来自动过滤垃圾评论和垃圾表单提交。这个插件默认就已经安装了，只需要启用就可以了，没有安装的可以在插件市场搜索安装启用：

![image-20250821193340632](https://image.hyly.net/i/2025/08/21/7bf7cce5a4687b7c340b4e082e4313f8-0.webp)

使用倒是挺简单的，在wordpress后台左侧菜单栏设置->Akismet 反垃圾评论菜单栏打开设置。页面如下：

![image-20250821193813067](https://image.hyly.net/i/2025/08/21/f296966651249204418198862ea7795a-0.webp)

首先需要注册一个账号，完成之后会有一个密钥填写进去，然后设置下评论的基础选项就可以了，因为博主自己也没有遇到过垃圾评论的情况，也不知道好不好用，不过既然官网推荐的，先安装上吧，有总比没有强。╮(╯▽╰)╭

## AMP

AMP 是一种针对移动设备优化的网页格式，旨在加快网页加载速度，从而提供更流畅的移动端用户体验。简而言之，AMP 让网页在移动设备上更快地加载，提升移动端用户体验和搜索引擎排名。

AMP（Accelerated Mobile Pages，加速移动页面）是 Google 推出的一种网页精简技术，核心目标是：

1. 让网页在移动端加载更快（限制了很多 JS/CSS，页面非常轻量）。
2. 移动搜索结果里，AMP 页面会优先显示，并带有 ⚡ 标识。

**AMP 用来做什么？**

1. 提升移动端加载速度：AMP 页面通常比普通页面快很多。
2. 提高移动端用户体验：减少跳出率。
3. 可能的搜索曝光优势：以前 Google 在新闻、Top Stories 里偏好 AMP 页面，现在虽然不是硬性要求，但快的网站依然更容易排在前面。
4. 适合新闻/媒体/门户站：因为文章数量多、流量大，用户以移动端为主，AMP 能显著提升加载速度。

因此我们为了提高网站文章在移动端的访问速度和在移动端搜索引擎的文章排名，我们有必要安装AMP插件。虽然我想当然的觉得PC用户肯定比移动用户多，且网站访问速度优化和文章质量才是搜索排名最关键的，不过介于没有代价和少量代价就能带来很多好处的原则，所以还是选择安装AMP。

### 安装配置

首先在插件市场搜索**AMP**安装启用：

![image-20250918163326607](https://image.hyly.net/i/2025/09/18/aae84e6596ab5e4b9b6060500f9ace1c-0.webp)

其次我们打开配置向导：

![image-20250918163424365](https://image.hyly.net/i/2025/09/18/b66a07410f7ea35a004b54b38693085a-0.webp)

按照配置向导操作如下：

![image-20250918163501415](https://image.hyly.net/i/2025/09/18/edc6869664cd72f8784ba945337bef30-0.webp)

![image-20250918163523906](https://image.hyly.net/i/2025/09/18/947f5f0b82105fcabbd16815d5749335-0.webp)

选择Reader模式:

![image-20250918163555462](https://image.hyly.net/i/2025/09/18/ff132edd84da220cb638fafad93442f4-0.webp)

这三种模式区别如下：

1. Reader：用一个简化的“AMP 专用”主题来生成 AMP 页面（AMP 与非-AMP 使用不同模板/主题）。适合主题极不兼容 AMP 或只想快速拿到轻量 AMP 的情况。
2. Transitional（以前叫 Paired）：同一站点保留“非 AMP 主主题”，同时为相同 URL 生成 AMP 版本（两套页面：非AMP 为 canonical，AMP 为 paired URL）。兼容性/视觉接近主站但仍有两套版本，适合逐步迁移或保持现有主题功能。
3. Standard：整个站点“以 AMP 为主”（所有 URL 都直接 serve AMP HTML），只有一套版本。适合主题/插件都 AMP 兼容或愿意投入开发改造为 AMP-first 的站点。

所以我们选择Reader模式，这样不会影响PC端的阅读体验，而且移动端可以生成正常版本（供想要体验的用户使用，有丰富的CSS和JS）和AMP版本（供搜索引擎加快收录排名使用和想要极速打开页面的用户使用）两种页面，相当于两种好处都尽力占了。

选择AMP页面版本的主题样式，大家可以根据自己喜好选择不同的尝试以下，不过这里我选择默认的了：

![image-20250918164045220](https://image.hyly.net/i/2025/09/18/1ff0642ee1a7dfe59071d15a09baa1d6-0.webp)

最后查看在移动端AMP版本页面的预览效果，最下边还有个退出移动版的选项，这样就可以给移动端用户首先呈现的是AMP页面，可以提高打开速度和搜索引擎排名吸引用户点击进来，如果用户有更高的追求可以点击退出移动版AMP查看完整功能的页面。

![image-20250918164412466](https://image.hyly.net/i/2025/09/18/4cbae0842a43aebaa9e795b92812d25e-0.webp)

最后是AMP的完整设置，供大家参考：

![image-20250918164512545](https://image.hyly.net/i/2025/09/18/06418e7559a918518a1e9a3eb25f46f1-0.webp)

## Custom Post Type UI

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

### 使用

首先在插件市场安装启用：

![image-20250821205835266](https://image.hyly.net/i/2025/08/21/b631b7c388877a48de80500b49989ff1-0.webp)

其次先注册一个分类，附加到说说类型上。只需要填写上半部分就可以，下面默认就行，下方的截图我附加上了每项都是什么意思的中文说明。

![image-20250821210659180](https://image.hyly.net/i/2025/08/21/6e990b424b0e1d36acd573f12f3f7047-0.webp)

![image-20250821210743971](https://image.hyly.net/i/2025/08/22/3af2fb38ab1d2465f4c023f1cdcd2c2a-0.webp)

发说说的时候就会有分类选项：

![image-20250821211149550](https://image.hyly.net/i/2025/08/21/aa527bd7ff17a7422a44a7b842bce8c9-0.webp)

说说菜单栏下也会多个说说分类菜单可以查看已经创建的分类：

![image-20250821214444631](https://image.hyly.net/i/2025/08/21/42312c11e20299dd94d056bf246f1191-0.webp)

### 根据分类查询说说

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

###  实现说说接口增删改查功能
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

添加这些就可以实现用m2w工具对说说的增删改查了，m2w具体如何使用看[这篇文章](https://hyly.net/article/code/wordpress/399)。

## Easy Updates Manager

它是 WordPress 的一个更新管理插件，作用是 集中控制和管理站点所有更新。

核心功能：

1. 可以一键开启或关闭 **核心程序、主题、插件、翻译文件** 的自动更新；
2. 支持精细化设置（比如只允许某些插件/主题自动更新）；
3. 提供延迟更新、更新日志和通知控制等功能；
4. 帮助管理员避免因自动更新导致的兼容性问题，同时保持站点安全性。

我的wordpress安装了很多插件，然后大部分常用的插件都启用了自动更新，更新之后会给我发送邮件，我觉得挺烦人的，就找到这个插件可以细粒度的控制更新，更重要的是可以关闭更新成功邮件通知，要是失败了可以通知我。

插件市场搜索`Easy Updates Manager`即可安装启用，使用方式是在已安装插件里点更新进入：

![image-20250829231948728](https://image.hyly.net/i/2025/08/29/4788cdae0b2f532be013a0f7f294d814-0.webp)

以下是相关配置，这是常规配置的截图，插件/主题/日志/高级等可以自己根据情况调整：

![image-20250829232513359](https://image.hyly.net/i/2025/08/29/831bcf00a022565818f348398c179e77.webp)

## GTranslate

GTranslate是一个可以让博客文章实现多语言的插件，它是调用谷歌翻译API然后实现对全站的翻译，但是有个小问题就是如果是国内用户访问网站使用翻译的话，因为国内访问不了谷歌翻译API，所以它是不能使用的，只有国外用户使用翻译才能正确翻译，但是网站默认语言是中文的，所以这好像也不算是个问题哈~

### 安装配置

首先在插件市场进行安装启用：

![image-20250822150720998](https://image.hyly.net/i/2025/08/22/53eabd1fc753f230bef14a6000f4e1e6-0.webp)

在设置->GTranslate里就可以进行插件的基本设置，也不太复杂，大家点点就知道怎么回事，我的设置如下：

![image-20250822150949519](https://image.hyly.net/i/2025/08/22/0fcea4af4177bc800d7a0dd6121ba8f6-0.webp)

必须是自己电脑能翻墙到国外网络，或本来就是国外网络翻译才有用。在前端页面的展示效果如下：

![image-20250822151400173](https://image.hyly.net/i/2025/08/22/e714be555fe896e78238f94f69efdd70-0.webp)

这个插件好处就是可以当前页面全部翻译，简单省事。而不像有的插件，你必须自己一个个中文对照的英文键值对填入插件，它才给翻译。

## Permalink Manager Lite

它的作用主要是管理和自定义站点的固定链接，说说/文章/页面/分类链接等。比方说想按照大分类/小分类/id，这样来构造文章的固定链接，或者想给某个页面/文章一个不属于上述规则的特殊固定链接，这个插件就都可以做到。wordpress默认的固定链接结构则很死板，没法更多的定制化。

![image-20250822152333321](https://image.hyly.net/i/2025/08/22/11a5abc41e7b89c35c67d538c2807d90-0.webp)

### 使用配置

首先插件市场进行安装启用：

![image-20250822152447649](https://image.hyly.net/i/2025/08/22/83836e5910d0564ca69c6eb4e604a6af-0.webp)

比较实用的就是修改固定链接的永久结构，可以修改页面/说说/标签/自己添加的说说分类固定链接结构。修改完之后要点重新生成/重置之后历史链接才会按照新规则重新生成一次。

这里没有文章，是因为使用m2w工具上传的文章，在wordpress后台能看到是有分类的，前端页面也是有分类的，但是文章链接却不是设置的大分类/小分类/id这种形式，所以这里去掉了，采用上图wordpress固定链接那种形式。

![image-20250822152559054](https://image.hyly.net/i/2025/08/22/c6acc442cc3e2abb365c8e16f6552f44-0.webp)

可以在URI编辑器这里修改某个文章/页面等的固定链接，达到定制化的效果：

![image-20250822160025220](https://image.hyly.net/i/2025/08/22/fc6ca61ce71245a083c88cbcd73f5b49-0.webp)

更特别的是，原来的`/about`链接也是可以用的，它只是重定向到修改后的新网址上。这种向后兼容的设计非常好！这样的话它就不会与m2w冲突，因为m2w是根据题目定义文章的唯一性的。

另外，在`Settings`中，`Permalink update`选项设置为`Auto-update custom permalinks`为宜（不是默认选项），这样m2w上传新文章的时候，才会自动选择为默认链接而不总是`others/xxx`，后者可能不是作者想要的；当然，这样设置的更多效应还有待观察。

![msedge_rkgcJcZteo](https://image.hyly.net/i/2025/08/25/12fdb8215719b4f4c1b9c1dfcf8a11d4-0.webp)

## Rank Math SEO

Rank Math SEO 是一款 WordPress 的搜索引擎优化插件，可以帮助站长更轻松地优化网站内容和结构，让文章更符合搜索引擎规则，从而提升网站排名和流量。由于它的免费版比**Yoast SEO**免费版有更多的功能，所以我就选择它了。

### 核心功能

1. 文章级 SEO 优化：在写文章时给出实时 SEO 建议（标题、关键词、元描述、链接、图片 Alt 等）。
2. 自动化 SEO 设置：批量生成文章的 meta 标签、结构化数据（Schema）、Open Graph、Twitter Cards 等。
3. 站点地图：自动生成 XML 网站地图，让搜索引擎更快收录。
4. 结构化数据（Schema Markup）：支持文章、产品、FAQ、食谱等多种 Schema 类型，增强搜索结果展示（富媒体结果）。
5. 关键词追踪与排名分析：可集成 Google Search Console/Analytics，直接在后台查看关键词排名和点击数据。
6. 重定向管理：内置 301/302/307 重定向工具，避免死链影响 SEO。
7. 本地 SEO 与多语言支持：适合本地商户优化，以及兼容 WPML/Polylang。

### 安装配置

首先在插件市场搜索Rank Math SEO进行安装，然后来到Rank Math SEO仪表盘，我们先进行初始化：

![image-20250919153133589](https://image.hyly.net/i/2025/09/19/867fa88edd83c3c59e0d404ebbf5c785-0.webp)

![image-20250919153238021](https://image.hyly.net/i/2025/09/19/6d0062435a1bdc122b41742ae899c4d0-0.webp)

下一步把基本信息填上就行了，网站类型选个人博客：

![image-20250919153400023](https://image.hyly.net/i/2025/09/19/d581f0a1b89fb1bd59d48e7edf77f83a-0.webp)

这里可以连接谷歌搜索、分析、广告控制台，进行数据聚合，在自己wordpress就可以看这三种数据，但因为我连上之后下次访问它还让我连接，目前没找到原因，所以就先放弃了，在谷歌自己搜索、分析、广告控制台查看数据了：

![image-20250919153640910](https://image.hyly.net/i/2025/09/19/defefe15aff0f53555b8a5cf3058d1d9-0.webp)

开启网站地图，这个还是非常重要的：

![image-20250919153724316](https://image.hyly.net/i/2025/09/19/681c0ca587a3d15a64a84ad64a2cc55b-0.webp)

外链的打开方式，默认即可：

![image-20250919153804902](https://image.hyly.net/i/2025/09/19/e1c6f416df223bdfc494f02ac35db855-0.webp)

然后就初始化完成了，完整配置如下：

![image-20250917193304860](https://image.hyly.net/i/2025/09/17/6a6c6b4d0df511a0298823ed450ddeaa-0.webp)

#### Content AI

获取有关关键词、问题和链接的高级人工智能建议，将其纳入 SEO 元数据和内容区域。支持 80 多个国家。就是通过AI根据文章内容自动推荐关键词的，有一定免费额度，额度消耗完就需要充值了，我开启了但是不好用，所以也就没继续管了，想试下的同学可以点击settings进行如下配置：

![image-20250917193611684](https://image.hyly.net/i/2025/09/17/e8530491753180127ebeb0150c5d77c3-0.webp)

#### 404 Monitor

记录访客和搜索引擎遇到 404 错误的网址。您还可以开启重定向功能，将导致错误的网址重定向到其他网址。就是记录失效链接，进行日志记录统计，可以点击settings进行如下配置：

![image-20250917193916416](https://image.hyly.net/i/2025/09/17/3c51b2f43040b970919b3bd97443643d-0.webp)

#### ACF

ACF 支持功能有助于 Rank Math SEO 能够读取并分析通过高级自定义字段所编写的内容。如果您的主题使用了 ACF，那么您应该启用此选项。

它的作用WordPress 正文（the_content）里的文字 Rank Math 能自动读取并分析（关键词密度、可读性、链接数量等）。但如果你的网站或主题使用 ACF 插件（Advanced Custom Fields）把主要内容放在自定义字段里（比如产品描述、特色介绍、FAQ 等），默认 Rank Math 是读不到这些内容的。开启 ACF Support 之后，Rank Math 就会把 ACF 字段里的文字也纳入 SEO 分析。因为我没有安装相关插件，所以就没开启。

#### AMP工具

安装 AMP 插件以使 Rank Math 能与加速移动页面协同工作。Rank Math 会自动在所有 AMP 页面中添加所需的元标签。

当你启用 AMP 支持 选项时，Rank Math 会自动为所有 AMP 页面添加所需的 meta 标签，以确保它们符合 AMP 标准并且能被搜索引擎更好地抓取和索引。

如果你的站点启用了 AMP 格式的页面（通常是通过 AMP 插件实现），那么开启这个功能会让 Rank Math 更好地支持并优化 AMP 页面，以提高其 SEO 表现。

##### 功能描述：

1. 自动添加 AMP 必需的 meta 标签： Rank Math 会自动为 AMP 页面添加所需的 `<link rel="amphtml">`、`<meta name="amp-status">` 等 AMP 元标签，确保搜索引擎能识别并正确处理 AMP 页面。
2. SEO 分析与优化： 启用后，Rank Math 会考虑 AMP 页面的 SEO 分析和优化，确保其在搜索引擎上的表现最佳。

##### 要不要开启？

1. 如果你使用了 AMP 插件（例如官方的 AMP 插件），并且网站有 AMP 版本页面，那么启用 AMP 支持是非常有帮助的，它可以确保你的网站 AMP 页面也能正确应用 Rank Math 的 SEO 优化规则。
2. 如果你没有使用 AMP 或者不打算为移动端启用 AMP 格式，则无需开启此选项。

这里我们开启了**Rank Math SEO的AMP**，如果想知道AMP插件如何安装使用的小伙伴可以看[这里](#AMP)。

#### Analytics

将 Rank Math 与 Google 搜索控制台进行连接，以便在您的 WordPress 控制面板中直接查看来自谷歌的最重要信息。

这个功能是与谷歌搜索控制台、分析控制台、广告控制台进行连接，然后在RankMath中统一管理，按理来说应该是个很强大的功能，但是不知道由于什么原因，不知道是我本地电脑是大陆网络的原因，我服务器本来就是外网的，还是RankMath的原因，连接老是中断，登录一次得连接一次，所以我也就不再管它了，就直接在谷歌搜索、分析、广告控制台网站上直接看了，虽然麻烦点。感兴趣的小伙伴可以详细配置了解下：

![image-20250918103648625](https://image.hyly.net/i/2025/09/18/34cfb10e2c52e8c07afba104b46594b3-0.webp)

#### bbPress

为您的 bbPress 论坛帖子、分类、个人资料等添加适当的元标签。获取更多控制搜索引擎所看到的内容以及其呈现方式的选项。

因为我是论坛网站，也许以后想构建一个深入研究下，所以这里暂时不给大家讲解如何配置了。

#### BuddyPress

启用 Rank Math SEO 的 BuddyPress 模块，通过在所有论坛页面添加适当的元标签，让您的 BuddyPress 论坛对搜索引擎友好。

它是针对博客网站是社区型的优化，因为我不是，所以也就先不开启了。

#### Image SEO

高级图片搜索引擎优化选项，助力您的网站更上一层楼。自动为您的图片即时添加 ALT 和 Title 标签。

这个功能可以为全站的图片添加ALT和title标签，提高搜索引擎收录率，别人搜索图片，找到相关的然后点击到你的网站来，主要为图片搜索，比如百度图片、谷歌图片、必应图片搜索等。我用markdown写的文章都没有添加ALT和Title，它能统一添加也算省事吧，虽然效果没有专门为每个图片写ALT和Title的好，但聊胜于无吧。参考配置如下：

![image-20250918182314630](https://image.hyly.net/i/2025/09/18/9408c45d9ba867c54d4e95a9f2e02487-0.webp)

#### Instant Indexing

当页面被添加、更新或删除时，可直接通过 IndexNow API 通知必应和 Yandex 等搜索引擎，或者手动提交网址。

这个功能特别重要，当初我正是因为付费版Yoast SEO才有这个功能所以才转战Rank Math SEO免费使用的。我们发布文章之后，谷歌/必应/谷歌等搜索引擎会通过蜘蛛爬虫慢慢收录文章（因为全网有很多网站，所以各个搜索引擎收录时间不同，就像百度会非常慢！！！），只有收录了文章，别人搜索关键词，结果列表里才会**有可能**出现我们的文章链接（结果页还要根据权重排名）。SEO只是解决结果页排名问题，没有收录，更不要谈SEO了，所以搜索引擎收录是非常重要的第一步！

这时候我们就可以通过Instant Indexing功能主动向搜索引擎提交我们新发布的文章链接，加快收录！设置起来非常简单，只需要开启就行了。开启了之后当页面被添加、更新或删除时就会自动向搜索引擎提交链接加快收录，我们也可以手动向搜索引擎提交Rank Math SEO插件安装之前已经发布文章的链接加快收录，就不用历史文章再重新编辑发布一遍了。

![image-20250918183732680](https://image.hyly.net/i/2025/09/18/db5db037479029ef7c52e382e898b4c0-0.webp)

如果知道历史文章链接直接提交就可以了，如果历史文章太多可以用**Export All URLs**插件批量导出文章链接，然后在这里提交。**只需要提交一次就可以了，重复提交并不会更快。**

这里可以设置都有哪些链接发生更改的时候主动提交搜索引擎：

![image-20250918184032645](https://image.hyly.net/i/2025/09/18/f56a6de172c3ba940c519559ca12eb40-0.webp)

这里可以查看主动提交的历史记录，确认文章链接是否真的被提交了：

![image-20250918184123971](https://image.hyly.net/i/2025/09/18/8b93264cc0ce1010cef3eb5d9b46198a-0.webp)

##### 必应和 Yandex收录

提交到Instant Indexing只会把链接同步到支持IndexNow API协议的搜索引擎，比如必应和Yandex（俄国的搜索引擎）等。不仅如此，也可以把网站地图在[必应搜索控制台](https://www.bing.com/webmasters/about)主动提交加快收录，双重保险。登录之后添加自己的网站后是这样的：

![image-20250918184728575](https://image.hyly.net/i/2025/09/18/edf7b99aedc7d6617aa66b41502d603c-0.webp)

可以在网站地图这里添加自己的网站地图，关于网站地图怎么设置可以看[这里](#Sitemap)。

也可以在IndexNow里查看自己主动提交的链接，也可以在搜索控制台查看自己网站在必应这里的收录情况以及访问情况怎么样，大致了解自己网站基于必应的访问数据。

![image-20250918184928954](https://image.hyly.net/i/2025/09/18/a6e3b25ccb66540ba0692a92e3187d7f-0.webp)

##### 谷歌收录

谷歌不支持IndexNow API，所以就需要通过提交网站地图加快收录，再加上谷歌收录是感觉目前搜索引擎里收录最快的，所以一般对网站都很友好，其次是必应，最差的是百度！

登录[谷歌搜索控制台](https://search.google.com/search-console)，添加网站后提交网站地图（这个网站就需要翻墙了）：

![image-20250918185825563](https://image.hyly.net/i/2025/09/18/e6a6b23632e4f85e13654f090982da40-0.webp)

这里可以看到谷歌搜索引擎其实收录情况还挺好的，基本上大部分能及时收录到：

![image-20250918190050397](https://image.hyly.net/i/2025/09/18/460b3960e73c1d86c65279454f395c24-0.webp)

##### 百度收录

百度就比较坑爹了，找遍尝试了大部分的关于百度收录的wordpress插件，发现都不行，而且在[百度搜索控制台](https://ziyuan.baidu.com/site/index)不能添加网站地图，功能点不了，只能批量链接添加，维护起来很麻烦，我索性就没管百度收录了。而且我就提交个网站链接加快收录你让我完善那么多信息干嘛，还是必填项，QQ号微信号都要，**TMD！**

![image-20250918190733065](https://image.hyly.net/i/2025/09/18/beac3966bad4c31bc0be543a5036cd6c-0.webp)

填完之后添加网站：

![image-20250918191853339](https://image.hyly.net/i/2025/09/18/4ebab10b76bbe3c8f7430b661618d062-0.webp)

选择网站类型，如果你不知道怎么选择，跟我一样就可以了：

![image-20250918191918354](https://image.hyly.net/i/2025/09/18/80a404f635bb24a163473b2a6477ae71-0.webp)

接下来就是网站验证，选择**HTML标签验证：**

![image-20250918224001546](https://image.hyly.net/i/2025/09/18/c01784367cdc3d4d81ffde3d39e89aae-0.webp)

然后在Rank Math SEO常规设置->网站管理员工具这里填上百度站长ID就可以了。

![image-20250918224422176](https://image.hyly.net/i/2025/09/19/bd45c7c7ba987140ec78c5776dad030e-0.webp)

保存之后可以在首页按F12查看元素这里搜索关键词`baidu-site-verification`查看是否已经添加成功。如果没有就强制刷新等一会再看看。

![image-20250919094759382](https://image.hyly.net/i/2025/09/19/242507db90547ded82c368ff6b7f2653-0.webp)

再到百度控制台这里点击验证就可以了：

![image-20250919094920114](https://image.hyly.net/i/2025/09/19/bcb36a70d95eb93d3f8f1d79353b8ef9-0.webp)

###### 快速抓取

百度的快速抓取是要申请的，看了一通介绍下来，总之一句话就是要钱！

![image-20250919095141893](https://image.hyly.net/i/2025/09/19/80e04f462b25be289db7f707b6c614a2-0.webp)

![image-20250919095223112](https://image.hyly.net/i/2025/09/19/e10383d6bbce5a87e59f889f1d990fa2-0.webp)

###### 普通收录

**API方式提交**

普通收录API方式提交，我找了一通关于百度收录的wordpress插件想做到自动化都不好用，我也懒得自己再写一个插件或者小工具了。

![image-20250919110121940](https://image.hyly.net/i/2025/09/19/503c3cd3a84022d060768c51ec31a410-0.webp)

**站点地图提交**

比较坑爹的是，站点地图提交网站输入框和提交按钮是`disabled`属性修饰禁止提交的，估计百度已经把这入口给关了，就是想让人充值VIP才能加快收录，要么就等着百度超级慢的收录吧。我尝试把这两处的`disabled`属性去掉，发现填入网站地图链接提交也是不行的，估计后台是真禁掉了。

![image-20250919110232619](https://image.hyly.net/i/2025/09/19/a2f17ac5648c5dc138db83ddf55d9177-0.webp)

**手动提交**

这里可以手动提交提交链接让百度收录，但因为不是自动化的，每当我新增、修改、删除文章时还得在他这再倒腾一遍，所以我也就没再管他了。想提交链接的小伙伴可以使用**Export All URLs**插件导出现有文章链接提交试试。

#### Link Counter

统计您帖子内部、外部链接以及指向和来自帖子的链接的总数。您还可以在帖子列表页面看到相同的计数。

开启这个无伤大雅，所以也就开启统计一下，啥时候想看了就点开看看。

#### LLMS Txt

提供一个自定义的 llms.txt 文件，以网站上的帖子、术语和最重要的内容为指导，引导 AI 模型。

##### `llms.txt` 是什么

1. 类似 `robots.txt`，但它不是给搜索引擎爬虫看的，而是给 **AI 模型（大语言模型，LLM）**（比如 ChatGPT、Claude、Perplexity 等）看的。
2. 通过 `llms.txt` 文件，你可以告诉这些 AI：
	1. 你网站上哪些页面、分类、标签是重点内容；
	2. 哪些页面不应该被用于训练/展示；
	3. 提供简要的内容导航，帮助 AI 更好地理解你的网站结构。

#####  Rank Math 的 `llms.txt` 模块能做什么

1. 自动在你网站根目录生成并提供 `llms.txt` 文件。
2. 里面会列出：
	1. 网站的重要文章、页面、分类；
	2. 你标记为“最重要”的内容；
	3. 路径和描述信息。
3. 这样，当 AI 模型来读取时，它会优先理解你推荐的内容，提高你网站在 AI 搜索结果/回答中的权重。

#####  要不要开启？

1. **适合开启**：
	1. 你的站点内容需要被 **AI 搜索引擎（Perplexity、You.com、ChatGPT 搜索插件等）**更好地理解和引用。
	2. 你希望未来 AI 聚合搜索里，你的网站内容能更清晰地展示。
2. **可以不开**：
	1. 你的网站只是个人小博客，对 AI 收录不敏感。
	2. 你不希望 AI 模型引用或学习你的网站内容。

#####  建议

1. 如果你的网站是 **公开博客、知识类站点、内容需要被更多读者发现** →  建议开启。
2. 如果你的网站是 **私密内容、不希望 AI 采集** → 可以不开，甚至在 robots.txt 里禁止。

我开启了反正让AI收录了，目前也没有啥坏处，知识就是分享的，就算AI回答用我的答案了也没事。参考配置：

![image-20250919112428590](https://image.hyly.net/i/2025/09/19/c7ca6e9cc8f35ee1064ac1946be80c8b-0.webp)

#### Local SEO

通过针对本地搜索引擎优化（Local SEO）来优化您的网站，从而在本地受众的搜索结果中占据主导地位，这还有助于您获取知识图谱。

#####  Local SEO 是什么

1. **Local SEO（本地搜索优化）**：就是优化你的网站，让它在 **特定地理位置** 的搜索结果里更容易被用户看到。
2. 常见场景：
	1. 搜索“附近的咖啡店” → 出现在 Google 地图、本地商家列表、知识卡片。
	2. 搜索“北京XX培训机构” → 在右侧 Knowledge Graph 或本地结果里展示。

#####  Rank Math Local SEO 模块能做什么

1. 给你的网站加上 **结构化数据（Schema）**：
	1. 你的企业名称、地址、电话 (NAP)
	2. 营业时间、经纬度、地图信息
	3. 多地点支持（如果你有多个分店）
2. 帮助 Google / Bing 等搜索引擎更清楚地知道：
	1. 你的网站和哪个实体相关（企业 / 组织 / 地点）
	2. 在 Knowledge Graph（搜索结果右侧的知识卡片）里展示
	3. 在本地搜索和 Google Maps 里更好地排名

##### 要不要开启？

1. **适合开启** 
	1. 如果你的网站是 **实体店、公司官网、线下服务型业务**（餐饮、教育、律师、健身房、美容院……）。
	2. 你希望在 Google Maps、本地搜索结果里出现。
2. **没必要开启**
	1. 如果你的网站只是 **博客、资讯、纯线上内容**，没有实体地址或门店。
	2. 开启后填虚假地址，反而可能影响 SEO。

##### 总结

- **Local SEO 模块的作用**：告诉搜索引擎“我是一个真实存在的商家/机构”，从而帮助你进入 **本地搜索结果 + 知识图谱**。
- **要不要开**：
	1. 有线下业务 → 开
	2. 纯线上博客/内容站 → 不开

#### News Sitemap

为您的新闻相关内容创建一个新闻网站地图。只有在您计划在网站上发布新闻相关内容时，才需要创建新闻网站地图。因为我的不是新闻网站，所以就没开。

#### Podcast

通过在您的播客中设置 Podcast RSS 订阅链接以及由 Rank Math 生成的 Schema 标记，使其能够在 Google Podcasts、Apple Podcasts 及类似服务中被发现。我的网站也不是博客（音频类网站）所以也没开这个。

#### Redirections

通过使用 301 和 302 状态码，可以轻松地重定向不存在的内容。这有助于提升您的网站排名。此外，还支持许多其他响应代码。功能主要是做 网址跳转管理。

1. 修复死链 / 404 错误

	1. 当网站某个页面被删除或改了链接，如果用户或搜索引擎点进来就是 404。

	1. 用 301/302 跳转，可以自动把访问者引导到新的页面或相关页面，避免用户流失。

2. SEO 友好

	1. **301 跳转**：永久重定向，搜索引擎会把原页面的权重传递给新页面，有利于排名。
	2. **302 跳转**：临时跳转，不会传递权重，但适合做临时活动页或测试。

3. 支持其他状态码

	1. 比如 307、410（内容已删除）等，可以更精细化地管理网站访问逻辑。

**强烈建议开启**：

1. 网站改版、改 URL 结构时非常有用。
2. 可以避免死链影响 SEO 和用户体验。
3. 方便集中管理跳转规则，不用去服务器配置 Nginx/Apache 规则。

**什么时候用**：

1. 文章/分类改了链接。
2. 删除了旧文章。
3. 把多个相似页面合并到一个新页面。
4. 域名切换或 URL 结构调整。

简单说，**即使现在不用跳转功能，也建议开启备用**，未来网站内容调整时会非常方便。

参考配置：

![image-20250919114355995](https://image.hyly.net/i/2025/09/19/50007407dce12012ae2d898c1900b4f2-0.webp)

#### Schema (Structured Data)

启用对结构化数据的支持，这需要在您的网站中添加“Schema”代码，从而能获得丰富的搜索结果、更高的点击率以及更多的流量。这个是一定要开启的，参考配置如下：

![image-20250919114721205](https://image.hyly.net/i/2025/09/19/d7906393bc354e16aab6ad087796d3bc-0.webp)

![image-20250919114748066](https://image.hyly.net/i/2025/09/19/5f666b5293ac9cb6d6ea98740d60b540-0.webp)

![image-20250919114817367](https://image.hyly.net/i/2025/09/19/75b6b5088eacd43a3d274e0c9cd16dc4-0.webp)

![image-20250919114846055](https://image.hyly.net/i/2025/09/19/31f0cc1bce42535604e8ffead7cea9c1-0.webp)

![image-20250919114941320](https://image.hyly.net/i/2025/09/19/1bbb40a61e3f39589b1cf0e3e17065db-0.webp)

![image-20250919115015774](https://image.hyly.net/i/2025/09/19/0779d8144846eb6993495eda48ecc2dc-0.webp)

![image-20250919115049493](https://image.hyly.net/i/2025/09/19/e2c7735e0e327c97137ee5417187f78f-0.webp)

![image-20250919115117626](https://image.hyly.net/i/2025/09/19/61217bdfdc1ae98718b2e978f25d15fb-0.webp)

![image-20250919115138265](https://image.hyly.net/i/2025/09/19/71debb8acbca555228006623d88b9e72-0.webp)

![image-20250919115158936](https://image.hyly.net/i/2025/09/19/00c5fa5d8e44e43e3bbfa8b046ca3b63-0.webp)

![image-20250919115215952](https://image.hyly.net/i/2025/09/19/f636a2defada4c291ed00623829d59f7-0.webp)

#### Role Manager

“角色管理器”功能让您能够利用 WordPress 的角色设置来控制您的网站用户是否能够对 Rank Math 的设置进行编辑或查看操作。我也没有所以没开启。

#### SEO Analyzer

让 Rank Math 对您的网站及其内容进行 28 种以上的不同测试，从而为您提供量身定制的搜索引擎优化分析报告。

可以让RankMath分析一波，然后打开设置查看报告，针对提出的问题点尝试修复下。

![image-20250919115541532](https://image.hyly.net/i/2025/09/19/dc22c89619b551b403c613d020d21490-0.webp)

#### Sitemap

启用 Rank Math 的网站地图功能，该功能有助于搜索引擎更智能地抓取您网站的内容。它还支持 hreflang 标签。

1. 帮助搜索引擎更好地收录
	1. Sitemap 是一个 .xml 文件，里面列出了你网站上的所有重要页面（文章、分类、标签、产品等）。
	2. 提交给 Google、Bing 等搜索引擎后，它们会更快、更智能地发现你的网站内容。
2. 支持 hreflang 标签
	1. 如果你的网站有多语言内容，hreflang 可以告诉搜索引擎哪个页面对应哪种语言/地区，避免重复内容问题。
3. 智能更新
	1. Rank Math 的 Sitemap 会自动更新（比如你新发布文章时），搜索引擎会更快抓取。
4. 改善 SEO
	1. 让搜索引擎抓取更高效，尤其是对大站点或内容更新频繁的网站，能减少“漏收录”的情况。

这个就非常重要了，加快搜索引擎收录网站就需要站点地图。大家开启之后可以参考配置：

![image-20250919151652865](https://image.hyly.net/i/2025/09/19/526b379abd8c8fdf825203f9c6b3beb4-0.webp)

![image-20250919151710993](https://image.hyly.net/i/2025/09/19/94797cf24741ec0e79b126e5a60f3f4d-0.webp)

![image-20250919151724362](https://image.hyly.net/i/2025/09/19/4c1460091b8b5c77e3f216dbcbc8a7c2-0.webp)

![image-20250919151740063](https://image.hyly.net/i/2025/09/19/19a1c91c8bff18bfb37d381ba47e6c30-0.webp)

![image-20250919151748437](https://image.hyly.net/i/2025/09/19/895aa3198405ce005c30ce658110ab77-0.webp)

![image-20250919151759782](https://image.hyly.net/i/2025/09/19/48090c735efd9e0558b3f671e99f7e16-0.webp)

![image-20250919151809540](https://image.hyly.net/i/2025/09/19/d9d0e18479c8c4a8057712170af35f14-0.webp)

![image-20250919151819077](https://image.hyly.net/i/2025/09/19/0dc4321ae6d141cceee1c09d629c88af-0.webp)

![image-20250919151827749](https://image.hyly.net/i/2025/09/19/da6b35705e247a906492e40a3bbabfb0-0.webp)

站点地图打开是这样的，里面记录了所有重要的链接，供搜索引擎结构化爬取：

![image-20250919151845210](https://image.hyly.net/i/2025/09/19/226e135b0a1b920864cea040774f4f9f-0.webp)

#### Video Sitemap

对于您的视频内容而言，创建视频索引图是提升排名并使其更易被视频搜索功能收录的推荐步骤。

因为我的网站不是视频网站，所以就没开启。

#### Google Web Stories

使用“网络故事”WordPress 插件创建的任何故事都能自动具备搜索引擎优化功能，同时还能自动支持结构化数据和元标签。

这个 Google Web Stories 模块主要针对 Web Stories 插件 用户，详细说明如下：

1. Web Stories SEO 优化
	1. Web Stories 是 Google 推出的类似 Instagram Stories/小红书那样的“卡片式、可滑动”的内容格式。
	2. 如果你在 WordPress 里安装并使用了 Web Stories 插件，Rank Math 可以自动为这些内容加上 Schema 标记 和 Meta 标签，让搜索引擎正确识别它们。
2. 增加搜索展示机会
	1. Google 会在移动端搜索结果和 Discover 里专门展示 Web Stories，开启后能提高这些内容被发现和点击的几率。
3. 自动化支持
	1. 你不需要手动给每个 Story 加 SEO 信息，Rank Math 会自动处理标题、描述、结构化数据。

**是否需要开启**

1. 开启的前提：
	1. 你的网站有安装并使用 Web Stories 插件，并且确实打算用 Web Stories 来做内容传播（比如图文故事、分镜式教程、营销活动）。
2. 如果不用 Web Stories 插件：
	1. 这个模块没有任何作用，可以 不用开启，避免后台加载不必要的功能。

这个小伙伴根据自身情况选择是否开启，我没有开启。

#### WooCommerce

通过添加必要的元数据和产品结构化信息来优化 WooCommerce 页面，这将使您的网站在搜索引擎结果页面中脱颖而出。

这个 WooCommerce 模块 是专门给 电商网站 用的，主要功能和作用如下：

1. 优化商品页面 SEO
	1. 自动给 WooCommerce 的商品页面、商品分类页、商店页添加 Meta 信息（标题、描述、关键词等）。
	2. 让搜索引擎更清晰地理解每个商品的内容。
2. 添加产品 Schema（结构化数据）
	1. 自动生成 Product Schema，比如：
		1. 商品名称
		2. 价格
		3. 评分/评论
		4. 是否有货
	2. 这样 Google 搜索结果里会显示 富摘要（Rich Snippets），比如 ⭐ 评分、💲价格，比普通蓝色链接更吸引点击。
3. 提升点击率（CTR）和排名
	1. 有 Schema 的商品页面更容易获得更高的点击率和曝光。

**是否需要开启**

1. 如果你的网站是电商网站（用了 WooCommerce 卖产品）
	1. 建议 开启，非常有用，可以显著提升商品页面在搜索引擎的表现。
2. 如果你的网站只是博客/内容站，没有 WooCommerce
	1. 不用开启，否则没有任何效果。

这个小伙伴根据自身情况选择是否开启，我没有开启。

#### React Settings UI

启用基于 React 的新插件设置界面。若关闭则会恢复到传统的基于 PHP 的设置页面。

这个 React Settings UI 模块其实和 SEO 本身没直接关系，而是 Rank Math 插件的 后台设置界面渲染方式，区别如下：

1. React 界面（新 UI）
	1. 使用 React.js 技术渲染 Rank Math 的设置界面。
	2. 优点：交互更快、更流畅（比如切换标签页、搜索设置项、即时保存等）。
	3. 缺点：依赖 JavaScript，如果你后台环境 JS 运行异常，可能会加载不正常。
2. Classic PHP 界面（旧 UI）
	1. 用传统的 PHP + HTML 渲染后台页面。
	2. 优点：兼容性强，几乎不会有 JS 报错的问题。
	3. 缺点：界面交互体验差，操作相对慢，功能查找不够直观。

**是否需要开启**

1. 一般情况建议 开启（React UI）：
	1. 界面更现代化，体验更好。
	2. Rank Math 新功能基本都优先支持 React UI。
2. 如果遇到问题可以 关闭，切回 Classic UI：
	1. 比如插件冲突、JS 加载异常、后台显示空白等。

## W3 Total Cache

W3 Total Cache 是一个WordPress 缓存优化插件，用于提升网站加载速度和性能。它通过缓存技术减少服务器负担，提高页面的响应速度，尤其对于流量较大的站点非常有帮助。安装了这个插件基本上就不用再安装其他的缓存提速插件了，这款就非常的强大！

### 主要功能

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

### 使用配置

首先是插件市场搜索安装启用：

![image-20250822162844690](https://image.hyly.net/i/2025/08/22/c2f3f0f237a1f1e8645a9d6d10320613-0.webp)

如果提示注册的话先去注册一个账户。首先来到仪表盘页面，我是能打开的都打开了：

![image-20250822164921338](https://image.hyly.net/i/2025/08/22/645f7683a2eac30d9f81417d2abf5a12-0.webp)

#### 常规配置

因为配置项有很多，大家按照我截图的参照着来就行了：

![image-20250822173724461](https://image.hyly.net/i/2025/08/22/55db46642394260cca7e4e8da6d1977d-0.webp)

> TIPS：一定不要勾选用户体验->延迟加载图像这个选项，会造成站点概览页面头像的显示和页面底部赞赏码的显示。

#### 页面缓存高级设置

![image-20250822174010648](https://image.hyly.net/i/2025/08/22/a49f46d2fe454ca1cc8b12d332873cee-0.webp)

#### 压缩高级设置

![image-20250822174135506](https://image.hyly.net/i/2025/08/22/55eeddd15601ed80d6beea4cfdb629a7-0.webp)

#### 数据库缓存高级设置

数据库缓存是把数据库从磁盘中查出来的结果缓存到内存中，从而提高查询速度，能尽快的给用户返回结果，所以它提示数据库缓存尽量不要选择磁盘存储，要选择Redis或Memcached。但是W3 Total Cache插件跟Redis数据库配置不太友好，没有Memcached一样只需要填写容器名称加端口号就能链接了。详细Memcached的安装可以看[这篇文章](https://hyly.net/article/code/wordpress/378#header-id-2)。

![image-20250822174548658](https://image.hyly.net/i/2025/08/22/13889f4dc7c41bf94c735cb08d586b1b-0.webp)

数据库缓存高级配置详细如下：

![image-20250822174320419](https://image.hyly.net/i/2025/08/22/26dd84b96a7d928f493ce665dc3aec78-0.webp)

#### 对象缓存高级设置

对象缓存主要是一些键值对什么的，跟数据库缓存配置差不多，也是选了Memcached作为内存缓存。详细的Memcached配置可以看[这篇文章](https://hyly.net/article/code/wordpress/378#header-id-2)。

![image-20250822175225545](https://image.hyly.net/i/2025/08/22/fc8d65849bfa55347aaf1b835100b2ba-0.webp)

#### 浏览器缓存高级设置

这个基本上都是默认配置，大家只需要跟自己的配置简单对照下异同即可。

![image-20250822180554053](https://image.hyly.net/i/2025/08/22/52852494842532b78624acd457bb0827-0.webp)

#### Network Performance & Security powered by Cloudflare高级设置

W3 Total Cache这个配置是跟Cloudflare连接，起到统一管理作用，需要取得Cloudflare密钥然后填入这里：

![image-20250822181611443](https://image.hyly.net/i/2025/08/22/5230f58e5714f6c4e8332c0cbed79559-0.webp)

密钥获取设置方式如下：

##### 获取 Cloudflare API Key 的方法

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

##### 详细高级配置

![image-20250822182542442](https://image.hyly.net/i/2025/08/22/1da74cace5043b551a8ad3867fdf82aa-0.webp)

## Wordfence Security

这个已经在[服务器与博客网站安全](https://hyly.net/article/code/wordpress/444/#header-id-7)这篇文章里详细介绍过了，这里就不再赘述了。

## WPS Hide Login

这个已经在[服务器与博客网站安全](https://hyly.net/article/code/wordpress/444/#header-id-14)这篇文章里详细介绍过了，这里就不再赘述了。

## WordPress Popular Posts

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

### 使用配置

首先插件市场安装启用：

![image-20250822185012128](https://image.hyly.net/i/2025/08/22/ce70703c70d983011be2f613583397d8-0.webp)

其次在左侧菜单栏外观->小工具那里去配置，你可以选择是放在左侧栏小工具还是右侧栏小工具里面，然后点击加号添加一个区块：

![image-20250822185717617](https://image.hyly.net/i/2025/08/22/39d15f86baba16f166e8f3d05efe93e2-0.webp)

我是在右侧栏小工具添加的热门文章，添加完成可以按照这样设置：

![image-20250822185958046](https://image.hyly.net/i/2025/08/22/fa9d7498f7be9c4ac544c4b2640fe3e9-0.webp)

最后发布几篇文章，每篇文章有不同的浏览量，就会在博客页面上出现这个最热文章小工具了。效果如下所示：

![image-20250825161134025](https://image.hyly.net/i/2025/08/25/adb5b71b835978c5046fcff97becf851-0.webp)

## WP External Links

这个插件在 WordPress 里主要是用来 **统一管理站点中外部链接的行为**。

1. **外部链接统一管理**
	1. 可以自动检测你网站文章、页面、评论中的外部链接（指向其他网站的链接）。
	2. 你可以统一设置这些链接的打开方式、样式和属性，而不用逐个修改。
2. **新窗口/标签页打开外部链接**
	1. 最常见的需求：让所有外部链接都在新标签页中打开，避免用户直接跳走。
3. **添加 rel 属性**
	1. 自动给外部链接加上 `rel="nofollow noopener noreferrer"`，方便 SEO、安全（防止新窗口页面通过 `window.opener` 攻击）。
4. **样式标记**
	1. 可以给外部链接自动加上一个小图标或自定义 CSS 类，让用户区分清楚内部链接和外部链接。
5. **内部链接保护**
	1. 可以设置哪些域名算“内部链接”，不会被当成外部链接处理（比如你主站 + 子域名）。
6. **安全性**
	1. 通过自动加 `noopener noreferrer` 防止 **tabnabbing 攻击**（新窗口劫持）。

### 使用方法

1. **安装插件**
	 在 WP 后台 → 插件 → 安装 → 搜索 `WP External Links` → 安装并启用。
2. **进入设置**
	 启用后，在后台菜单里会出现 **External Links** 设置项。
3. **主要设置项**：
	- **Open external links**
		- New window / same window / top frame … （推荐选 *New window*）
	- **Add rel attribute**
		- nofollow, noopener, noreferrer 等，可以多选。
	- **Icon settings**
		- 是否在外部链接旁边显示一个小图标（可自定义样式/图片）。
	- **Exceptions**
		- 你可以指定哪些域名不算外部（比如你公司的子域名）。
4. **保存设置**，插件会自动应用到所有页面的外部链接。

大家可以像我一样设置：

![image-20250825162144797](https://image.hyly.net/i/2025/08/25/ad7620df1f70dcbf6d4d794f03a2f4cf-0.webp)

这几个属性还是很重要的，大家可以根据自己情况设置，不过一般照着上图的教程来就可以。属性详解：

1. `nofollow`
	1. **作用**：告诉搜索引擎 **不要跟踪此链接**，也不要将权重传递给目标页面。
	2. **使用场景**：
		1. 用户生成内容（论坛、博客评论），防止垃圾外链。
		2. 不想给某些外部站点传递权重。
		3. 有付费推广嫌疑的链接。

2. `noopener`
	1. **作用**：在 `target="_blank"` 的情况下，防止新打开的页面获取到 `window.opener` 对象，避免 **钓鱼攻击、劫持攻击**。
	2. **安全性参数**，和 SEO 无关。
	3. **建议**：所有 `target="_blank"` 链接都加上 `noopener`。
3. `noreferrer`
	1. **作用**：点击链接时 **不向目标页面发送 Referer 头信息**（即来源网址）。
	2. **区别于 `noopener`**：
	3. `noopener` 是防止脚本攻击；
	4. `noreferrer` 是保护 **隐私**，避免暴露来源网址。
	5. **常见场景**：不想让对方知道用户是从哪个页面跳转过去的。

4. `external`
	1. **作用**：表明这是一个 **外部链接**，通常给浏览器或 SEO 工具提供提示。
	2. **不是强制行为**，更多是语义化，方便主题、插件或搜索引擎理解。
	3. **常见用法**：配合 `target="_blank"` 提示“此链接会打开新窗口/外部站点”。

5. `sponsored`
	1. **作用**：告诉搜索引擎这是一个 **付费推广、赞助广告** 的链接。
	2. **Google 官方要求**：广告、软文、联盟推广链接必须用 `rel="sponsored"`，否则可能被处罚。

6. `ugc`
	1. **作用**：**User Generated Content**，表示此链接来源于用户生成内容（UGC），如：评论、论坛帖子、用户提交的内容。
	2. **区别于 `nofollow`**：`ugc` 明确告诉搜索引擎 “这是用户生成的链接”，更精细化。
	3. **SEO 建议**：评论区、论坛等使用 `rel="ugc nofollow"`。

## WP Mail SMTP

WP Mail SMTP核心作用就是把 WordPress 默认的 PHP mail() 发信，改为真实的 SMTP/邮件服务商 API发信，让系统邮件（找回密码、订单通知、表单通知等）稳定送达收件箱，减少进垃圾箱/丢信。这其实还算挺重要的一个插件了。

### 使用配置

使用配置起来也挺简单的，首先在插件市场安装启用：

![image-20250825165711619](https://image.hyly.net/i/2025/08/25/a52dcbb523e92f1961dc7b79fb5332e8-0.webp)

WP Mail SMTP支持许多邮箱。我准备使用国内常用的QQ邮箱。所以选择`其它SMTP`。点击`Save and Continue`。

![img](https://image.hyly.net/i/2025/08/25/046baf19d152de345fce7232ea865850-0.webp)

对于SMTP服务，你需要提前在QQ邮箱里的`设置——帐户——POP3/IMAP/SMTP/Exchange/CardDAV/CalDAV服务`处开启服务，像这样：

![img](https://image.hyly.net/i/2025/08/25/1f7b1ef1c33445081416171e85b3143f-0.webp)

在WP Mail SMTP的步骤中，QQ邮箱的设置类似于下图。发件人名字和邮箱按需修改。注意，这个密码是`生成授权码`，而不是你的QQ登陆密码。用户名是不需要加`@qq.com`的。这个生成授权码可以忘记，因为你可以生成多个授权码。设置完成后继续按`Save and Continue`。

![image-20250825170358159](https://image.hyly.net/i/2025/08/25/56df1ad6909f3d0f5200e8be6a55f6ef-0.webp)

设置完毕之后在工具这里可以发送测试邮件，看是否已经正确配置：

![image-20250825170528957](https://image.hyly.net/i/2025/08/25/37223e8c521c45e32321e57f82056465-0.webp)

## WP Revisions Control

WP Revisions Control 是一个让你控制 WordPress 文章、页面等内容的 修订版本（Revisions）数量的插件，避免数据库无限膨胀，提升网站性能和可维护性。因为wordpress默认是会保存无线修订版本的，所以这个插件限制了保存修订版本的个数，其实还蛮重要的。

### 核心功能

1. **限制修订版本数量**
	1. 可以针对 **文章类型**（文章、页面、自定义文章类型）单独设置保留的修订版本数量。
	2. 例如：只保留最近 5 个修订，旧的自动清理。
2. **全局或单独控制**
	1. 支持全局设置（所有文章类型），也支持针对不同文章类型分别设定。
3. **轻量化 & 无侵入**
	1. 不修改已有修订，只在新修订保存时生效；
	2. 界面简单，几乎“装了就能用”。

### 安装使用

在 WP 后台 → 插件 → 安装插件 → 搜索 WP Revisions Control → 安装并启用。

在设置->撰写这里设置每种类型能保存的修订版本数量，大家可以参照我的来：

> TIPS：大家如果是使用m2w工具上传文章/说说，文章修订版本一定要是1，这样可以避免保存SEO设置时发生意外的版本回退现象。

![image-20250825171119508](https://image.hyly.net/i/2025/08/25/a41c7a48f95769563393168150db9d2a-0.webp)

## WP-Sweep

WP-Sweep 是一个专门清理 WordPress 数据库的优化插件，它能帮你删除无用的数据（如修订版本、草稿、垃圾评论、孤立的元数据等），减少数据库体积，从而让网站运行更快、更轻量。

### 核心功能

1. **文章清理**
	1. 删除多余的文章修订版本、自动草稿、已删除文章。
2. **评论清理**
	1. 清理垃圾评论、未审核评论、已删除评论。
3. **用户数据清理**
	1. 删除孤立的用户元数据。
4. **元数据清理**
	1. 清理文章元数据、评论元数据、用户元数据中的孤立数据。
5. **数据库优化**
	1. 清理临时选项（transients）、优化数据库表。
6. **安全可靠**
	1. 使用 **WordPress 内置函数** 进行删除操作（不像某些插件直接跑 SQL），安全性更高。

### 使用配置

在 WP 后台 → 插件 → 安装插件 → 搜索 WP Revisions Control → 安装并启用。

在菜单栏工具->清理使用，我只是偶尔看一下，不是很经常使用。一般清理一两次，以后正常使用问题都不会太大。使用的时候遇到重要数据清理一定要做好备份！！！

![image-20250825173148150](https://image.hyly.net/i/2025/08/25/65eafbf4a46081efec184da71b6b157b-0.webp)

## Yoast SEO

> 由于只有付费版才能进行Index now 加快搜索引擎收录，所以博主不再使用转战Rank Math SEO这个插件了，详细的可以看这里。

Yoast SEO能帮你在写文章和管理网站时，提供 搜索引擎优化（SEO）指导和工具，包括标题/描述设置、关键词分析、站点地图、面包屑导航等，提升你的网站在搜索引擎中的可见性和排名。

###  核心功能

1. **内容优化（On-page SEO）**
	1. 每篇文章/页面都能设置 SEO 标题、Meta 描述、目标关键词。
	2. 实时 SEO 分析：可读性分析（句子长短、被动语态、过渡词）、关键词密度、标题结构。
	3. 颜色提示（红/橙/绿灯）告诉你优化程度。
2. **技术 SEO**
	1. 自动生成 XML 网站地图（sitemap.xml）。
	2. 控制页面是否允许索引（noindex/nofollow）。
	3. 面包屑导航功能（可选）。
3. **社交媒体优化**
	1. 设置 Open Graph（Facebook）、Twitter Cards，让分享时有正确标题、描述、缩略图。
4. **全站 SEO 设置**
	1. 自定义全局 SEO 标题模板（文章、分类、标签、存档页）。
	2. 管理网站的 Schema.org 结构化数据（文章、产品、组织信息）。
5. **扩展（Pro 版）**
	1. 内链建议、重定向管理、多个关键词优化、无广告支持。

### 使用配置

**TIPS：**本节Yoast SEO配置大部分摘自《[Docker系列 WordPress系列 个人博客的SEO](https://blognas.hwb0307.com/linux/docker/858)》

首先在 WP 后台 → 插件 → 安装插件 → 搜索 Yoast SEO → 安装并启用。

#### 初始化

软件的初始界面就是这样的。从左侧栏进入。我们可以点`开始SEO数据优化`。

![img](https://image.hyly.net/i/2025/08/25/03a6d1fc0b4deedcca7617a34db4c02b-0.webp)

很快，SEO的优化就完成了。是不是很简单？

![img](https://image.hyly.net/i/2025/08/25/4eab992e31c6d350005d6adc9e052229-0.webp)

#### 站点管理

大家可以从`常规——站点管理员工具`这里进入设置。

![img](https://image.hyly.net/i/2025/08/25/fd9139e3bdeec25bd72e8e904a572303-0.webp)

这里有4个搜索平台的设置。如果你博客的受众是国内用户，其实百度还是可以做一下的；如果你的网站受众是国外用户，那么Google等平台也可以做，均不太难。下面我演示一下这几个平台如何添加。

##### 百度

按提示，进入`百度搜索资源平台`：

![img](https://image.hyly.net/i/2025/08/25/f5008bc17d609308bf1fe732069b3efa-0.webp)

输入你自己的网址。此时百度会有一个摆正图片的验证。

![img](https://image.hyly.net/i/2025/08/25/ea51244ba63a7f5f0720bba9e2b91996-0.webp)

这时百度会让你选择站点属性。如果你不知道填什么，就选`其它`吧！

![img](https://image.hyly.net/i/2025/08/25/e72c97f6bd9fd01f850bfbe2e60b7e27-0.webp)

下一步是验证网站。你将下图红框的代码copy到你的网站后台：

![img](https://image.hyly.net/i/2025/08/25/7e6467447ba65672dbd05accb430a7d2-0.webp)

点击`保存更改`生效。然后回到百度的验证界面，点击`完成验证`：

![img](https://image.hyly.net/i/2025/08/25/95b247dfa194106e4dd2c52e8bff9df3-0.webp)

成功后会有一个提示：

![img](https://image.hyly.net/i/2025/08/25/6fc3f3bf28631556f4539508c29a3d5f-0.webp)

之后你可以访问这个网站来管理你的网站：https://ziyuan.baidu.com/dashboard。你可以使用百度的一些工具来帮助自己的网站被快速收录，比如`API提交`、`sitemap`、`手动提交`。都是免费的。

![img](https://image.hyly.net/i/2025/08/25/7d56e83a2b8a1d78c19bde16cd10bed8-0.webp)

##### Google

其实和百度的操作是类似的。或者说，在网站收录过程中，与搜索引擎的交互都是类似的。可能大家都是抄的Google的吧！

在Google搜索控制台中获取您的Google验证码：

![img](https://image.hyly.net/i/2025/08/25/8270e6e71bde66f16bc56b8454201281-0.webp)

下面，将这一段复制回你博客后台Google对应的位置，保存更改后返回Google的网页点验证。这个不用多说了吧？成功后类似于：

![img](https://image.hyly.net/i/2025/08/25/3f3715faf1a9581ff7d7e4e81471a989-0.webp)

最后还有Bing和Yandex，大家可以试一下！基本流程都是一样的

#### 搜索外观

很多内容我也没怎么细改。估计不同类型的网站是不同的。我作为个人博客，只改了这个：

![img](https://image.hyly.net/i/2025/08/25/39a064c3a25cd4c11e366564215e2c7f-0.webp)

#### 工具

在`工具`中的`文件编辑器`希望小伙伴们可以多加关注。因为在这里我们可以编辑`robots.txt`和`.htaccess`文件。`robots.txt`对网络爬虫的行为进行了定义。

![img](https://image.hyly.net/i/2025/08/25/bf5d6e6def3c9cacd4e48f34998cb2cd-0.webp)

这里我展示一下自己的robots.txt内容：

```
User-Agent: *
Allow: /wp-content/uploads/
Disallow: /wp-content/uploads/live2dyy/
Disallow: /wp-content/plugins/
Disallow: /wp-admin/
Disallow: /readme.html
Disallow: /refer/
Disallow: /imgapi/
 
Sitemap: https://blognas.hwb0307.com/sitemap_index.xml
```

具体的含义大家可以看看《[WordPress 的 robots.txt 设置方法](https://zhuanlan.zhihu.com/p/499699900)》和《[关于 robots.txt 的介绍、作用和写法](https://hikami.moe/webmaster/pem-webmaster/2877.html)》两篇文章，还蛮好懂的。因为我不想爬虫去爬取看板娘文件夹`live2dyy`和自建随机图API文件夹`imgapi`（这两个文件夹内并没有对读者有用的信息），所以我让爬虫不要爬取它们，于是定义了`Disallow`规则。

此外，`.htaccess`文件一般是不需要做什么修改的，我也没有什么推荐。有兴趣的话，你可以看一下《[WordPress中.htaccess的使用技巧](https://www.cnblogs.com/yueke/p/3929062.html)》这个文章。如果你真的要改变它，最好对`.htaccess`做一下备份，如果搞砸了将旧文件替换掉问题文件即可满血复活。

#### 优化某篇文章

一般**建议大家每写一篇文章就做一下该文章的SEO优化**。`Yoast SEO`在每篇文章里需要你写的东西不多，所以也浪费不了多少时间！另外，对于个人免费用户来说，我觉得SEO做好关键词、标题和元描述就差不多了。因为，关键词是告诉搜索引擎哪些用户搜索可能需要你这篇文章；用户搜索后，一般也只是瞄一眼标题和元描述，就决定要不要点进去了看了。所以要**抓住主要矛盾，好好写好标题和元描述**，不用太过在意特别细节的东西！

我们去`文章`里随便看一篇写好的文章，可以看到`Yoast SEO`已经在工作了：

![img](https://image.hyly.net/i/2025/08/25/4922c000c17a9af850d9672be945cf40-0.webp)

不过，我们也可以发现SEO是一个红点，这意味着`SEO不可用`。通常你只需要设置一个`焦点关键词`即可。具体优化是：

![img](https://image.hyly.net/i/2025/08/25/5de3b1666abac98bc6ffd85a9df8fd35-0.webp)

大致的策略是：

1. 焦点关键词：免费版只能设置一个，同义词要Premium版。你可以`获取相关关键词`，评价自己的关键词是否有较高的热度；或者你通过其它的方法（比如百度或Google的某些站长工具）确定关键词是否有较高热度。
2. SEO标题：一般像我那样写就好。绿条尽量拉满即可。
3. 元描述：写一些文字，**出现1-2次焦点关键词**。篇幅要适中，要有煽动性，**巧用感叹号和问号**。要假设你是用户，设想什么描述会让人有点进去的欲望。当然，前提是要与文章内容贴合，不能做标题党！绿条尽量拉满即可。

一般你设置了焦点关键词，SEO的结果就会变成“**好**”而不是“**不可用**”。`SEO分析`选项中还会给出你需要改进的地方，比如：

![img](https://image.hyly.net/i/2025/08/25/e2650a2470659a0ac810c4cf94cab220-0.webp)

但这一块我也了解的不多。有机会再慢慢调试吧，有好的经验我会更新！

如果你想进一步设置的话，可以去B站找找教学视频，比如这个：[B站视频：wordpress Yoast Seo后台设置教学](https://www.bilibili.com/video/BV1CS4y1A7tx)。

不过我个人认为，如果**你坚持做好内容，并且多在内容平台曝光**，看你文章的人多了，网站比重高，搜索引擎自然就会收录你的文章。刚刚开始的个人博客，我觉得设置好那些基本的SEO就行了。

另外，我偶然发现安装多语言支持插件（比如[插件 – GTranslate](https://hyly.net/article/code/wordpress/380#header-id-8)）会明显增加网站在bing等搜索引擎的曝光率。小伙伴们也可以试试看！

## Broken Link Checker

它是 WordPress 的一个链接监测插件，作用是自动扫描并检测站点中的失效链接和图片。

核心功能：

1. 定期扫描文章、页面、评论等内容中的链接；
2. 找出 404、超时、重定向等无效或异常链接；
3. 在后台列表中集中管理并直接修改/移除坏链；
4. 可通过邮件或后台通知提醒站长。

当自己的文章引用了别人的文章或者链接了其它网站之后，写文章时链接当然都是可用的，但是随着时间发展，发布的文章越来越多，引用的链接越来越多，也会有一些链接打不开了，这就是坏链。当坏链变多时，不仅影响小伙伴们的阅读体验，也影响网站的SEO，降低自己的权重，这样一个插件就是检测自己网站的坏链并提醒自己及时改正的工具。

> 我还发现了一个好用的地方就是当自己网站有很多友情链接，有的小伙伴网站不再维护了，这个插件也是一个比较好用的工具，总不至于一个个点开网站查看吧🤣

首先在插件市场搜索`Broken Link Checker`安装并启用，然后打开插件的设置页面：

![image-20250901174413709](https://image.hyly.net/i/2025/09/01/6a3f17cd8843900148876c673cd1927f-0.webp)

检查范围我是能检查的都检查了：

![image-20250901174457679](https://image.hyly.net/i/2025/09/01/276b052c64b3d2c8b7f971f3ceca58a8-0.webp)

检查类型也是能检查的都检查了：

![image-20250901174653556](https://image.hyly.net/i/2025/09/01/3bb5257deeafbcb3d04092e5b562fcd8-0.webp)

![image-20250901174709444](https://image.hyly.net/i/2025/09/01/7b9bd14609cc9eece9f30d8f3ccff3cb-0.webp)

![image-20250901175106411](https://image.hyly.net/i/2025/09/01/ad14d50cc457e8cfa172b532425846a2-0.webp)

设置好之后可以在**失效链接**这里看到网站所有的链接，并且他会自动的开始检查链接的有效性，对于失效的可以在失效列表里查看：

![image-20250901175421569](https://image.hyly.net/i/2025/09/01/569f0f2dd94d8b8636935c9bbde8b746-0.webp)

如果知道最新的正确链接，可以在这里直接修改链接，然后文章的链接就会变成正常的了。但是按照我推荐工作流的小伙伴不建议直接修改，需要在typora里修改文章链接然后用m2w重新推送，这样才可以。或者这个链接的网址就是没有了也可以取消链接。如果手动测试了这个链接是有效的也可以选择**未失效**，或者这个链接属于特殊情况，就可以选择**屏蔽**，以后不再提醒。修改为正确链接之后，可以点这里的**重新检查**一次。

链接失效后在文章里是**删除线**显示的：

![image-20250901181040485](https://image.hyly.net/i/2025/09/01/39ab2703c1655c9a5dfcc6dbe635b62b-0.webp)

至此就是 Broken Link Checker全部的介绍了，还是一款非常好用的插件的。

## 小结

至此推荐Wordpress安装的插件就这么些了，在使用安装配置过程中有疑问的小伙伴可以在文章下方留言与我互动，有最新的资料我也会及时更新本文章，感兴趣的小伙伴请关注点赞哈~
