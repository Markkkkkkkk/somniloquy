---
category: [k8s技术栈]
tag: [云原生,istio,IAM,SSO]
postType: post
status: publish
---

## 现状

传统微服务下的IAM（SSO）方案，要么是使用开源的IAM系统，然后各子系统进行轻量/重量级改造来进行适配，要么是自主研发使用spring security、shiro等权限框架实现统一认证/授权。其中以**Sa\-Token**框架较为优秀，大部分关于认证、鉴权等操作均有封装较好的函数，可以实现一行代码调用实现，且有成熟的jar包，各子系统只需要maven引入即可接入中心化IAM实现统一认证鉴权。但云原生场景下的IAM方案有更好的解题方法：

**使用中心化的IAM服务在集群进行部署，然后通过istiogateway或istio\-proxy等流量网关，对各子系统服务进行流量劫持过滤，转发到IAM服务进行认证和鉴权。使得各子系统只需要专注业务，不用再关心权限等逻辑，降低研发心智负担，以下是详细说明：**

## 中心认证/鉴权时序图

![image\.png](https://image.hyly.net/i/2026/08/20/827b8361d7949fa9ec1f1aa7ca677231-0.webp)

**各子系统改造：**

1. 上k8s或k3s集群，具备中心化初始条件。（istio网关需要依赖集群使用，作为边车存在，降低权限代码对各子业务系统的侵入性）

2. 去掉认证/鉴权相关代码。**注：需要保留数据权限代码，数据权限是通过SQL拼接条件做到的，在中心化/非中心化/RABC/ABAC等场景下都是放到子系统来实现的。**

3. 把关于自己系统的用户列表、角色列表、权限标识（如：eoc:sys:user:add）和需要鉴权、特殊放行的URL汇总成表格发送给IAM团队进行权限添加。

**IAM系统改造**

1. 构建中心化的IAM服务，构建用户、角色、权限字符、URL的认证、鉴权体系。

2. 页面初始化添加各子系统发送过来的权限字符、URL进行用户、角色关联。后期在IAM架构不变的情况下，各子系统如需增删改权限只需在IAM后管页面操作即可，不需要二次开发。

## 多级SSO架构图

![image\.png](https://image.hyly.net/i/2026/08/20/c737f5131b0dfe3a19e53419739dff7f-0.webp)

针对全国端、城市端多级项目部署需求，特设计此多级SSO架构图，满足中心端有一整套服务，中心端IAM可以直接在自己portal配置城市端入口，中心端IAM账号可以直接跳转到城市端IAM portal页，实现城市端项目管理。

**关键措施：**

1. 中心端IAM配置城市端IAM地址，每当中心端IAM创建账号且配置了城市端IAM的权限时，中心端IAM把用户、权限信息主动同步到城市端IAM。

2. 城市端IAM可以外网部署，接收中心端下发的用户、权限数据。也可以内网部署独立运行。

3. 中心端IAM、城市端IAM是同一套服务，只是可以通过中心端IAM配置城市端IAM地址来形成套娃扩展。

## 附录：各概念详解

### IAM服务

IAM服务为对外提供统一认证/鉴权的服务。目前由keycloak和extauthz扩展服务统一组成。

#### keycloak的局限

在SSO项目建设初期，原方案设计者本意是想通过keycloak来统一实现中心化认证/鉴权，但在建成过程中、建成之后发现keycloak并不能满足RBAC场景下的所有权限需求。keycloak只有用户的认证、应用client级别的鉴权。并没有常规场景下对角色、菜单、按钮URL细粒度的鉴权控制，所以自研了extauthz服务与keycloak相结合共同实现IAM的统一认证/鉴权。

目前的路径为：登录之后先去keycloak认证用户合法性，跳转到IAM portal页，选中子系统（应用client）跳转，会到keycloak里判断下该用户是否有client权限，有则跳转到子系统，之后子系统内所有菜单、按钮URL权限则由extauthz控制。

**鉴于此情况，就在思考，keycloak是否还适合目前云原生场景下细粒度的RBAC\+ABAC权限控制，是否还要部署keycloak服务、keycloak专属MySQL数据库，然后再配备extauthz服务、extauthz数据库来组合成完整的IAM服务。**

**自己使用外部中间件的心得是，如果外部独立中间件可以通过简单的配置来解决整体服务某项问题的话，那么我是乐意使用的，中间件可以提供插件化能力，装上即可，不会与集群现有能力强耦合。如果中间功能有残缺，还需自己给安个支架辅助满足自己要求的话，就对使用这个中间件存疑，不优雅，除非它有特别不可或缺的能力，自己实现不了。所以鉴于此，特给出了以下extauthz独立成为IAM服务提供统一认证/鉴权的方案：**

**extauthz服务可以通过利用Sa\-token的能力，快速构建认证/鉴权功能，然后独立对外统一提供使用。关于Sa\-token极简API的例子可以参照下文具体说明。**

#### Istio\-proxy改为IstioGateway

目前Istio网关鉴权是通过注入到每个需要鉴权的服务形成Istio\-proxy边车来实现的，Istio\-proxy边车每个占约150M内存，在传统spring镜像服务场景下，每个spring服务占用5G左右内存，启动时间在5分钟左右，相比之下Istio\-proxy的内存占用还算尚可。但是在全面拥抱Native镜像，使用quarkus进行改造后 ，每个服务将会占约50M内存，启动时间在10ms以内，那么Istio\-proxy的边车就略显沉重了，故由每个需要鉴权的服务都有一个Istio\-proxy边车来充当网关，提升到由集群统一网关IstioGateway来进行路由的鉴权过滤就很有必要了。此项改造并不会影响原来子系统的逻辑，子系统不需要任何改造，无感知的。使用Istiogateway还有一个好处是集群整体性能开销最小。脏流量和越权请求在集群边缘就被直接丢弃，根本进不到内网，减少内网压力。

在最初使用Istio\-proxy，并没有直接使用IstioGateway是有历史原因的。K8s集群部署时，最初运维人员是选择Ingress\-nginx\-controller作为集群的统一网关去使用的，在后来做SSO时，当时的执行人为了省事，没有去改Ingress\-nginx的入口，就直接在每个鉴权服务侧注入边车了。在当时的场景下这并没有直接的错误，但是从长远来看是不合适的。特别是随着全服务quarkus改造后，问题就越发明显了。

改为IsitioGateway也非常简单，主要有以下几个步骤：

##### 集群统一网关入口由Ingress\-nginx\-controller改为IstioGateway

这个需要把ACC、ACP所有涉及服务的Ingress文件改为Istiogateway的入口文件，此项工作技术难度尚可，略微繁琐，略微难度的重复性劳动。

##### AuthorizationPolicy修改

原来是每个需要鉴权的服务都需要开启Istio注入，并为每个服务编写对应的AuthorizationPolicy文件，改为Istiogateway之后，只需要编写一个AuthorizationPolicy文件即可，示例如下：

```YAML
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: gateway-extauthz-policy
  namespace: istio-system # ⚠️ 注意：通常 Ingress Gateway 部署在 istio-system 命名空间，策略需要和它同命名空间
spec:
  selector:
    matchLabels:
      istio: ingressgateway # ⚠️ 核心改变：拦截目标变成了 Istio 统一网关，不再是特定的业务 Pod
  action: CUSTOM
  provider:
    name: micro-extauthz
  rules:
    - to:
        - operation:
            paths: 
              - "/berth/add"
              - "/berth/berthOnline"
              - "/berth/import"
              - "/parkEoc/updateAuditStatus"
              - "/bacb/park/lightbox/channels/upsert"
      # ⚠️ 强烈建议追加 hosts 过滤，否则网关上所有域名的同名路径都会被拦截
      when:
        - key: request.headers[host]
          values: ["api.your-domain.com", "acb.your-domain.com"]
```

**原因**：`AuthorizationPolicy` 的核心作用是“将规则绑定到特定的目标工作负载上”。

- **之前的设计**：你的策略绑定在 `serving.knative.dev/service: api-acb` 这个特定的业务 Pod 上（网格内拦截）。

- **现在的设计**：你需要把策略绑定到统一网关上（边缘拦截）。因为网关承载了整个集群所有的流量，如果你不加上精细的过滤条件，**所有的请求（包括前端静态资源、无需鉴权的系统）都会被强行发往 extauthz 导致误拦截。**

#### IAM外部系统对接

##### 作为服务提供方（SP） —— 接入外部 SSO（如企业微信、钉钉、Okta）

**业务诉求**：想让员工或客户用外部 SSO 的账号，直接登录进入停车（ACP）或充电（ACC）平台管理后台。

**架构原则**：**“外部换内部” \(Token Exchange\)**。坚决不要让 Istio 网关和业务子系统去认识外部 SSO 的 Token，你的系统内部永远只流通你自己的 JWT。

###### IAM 引擎需要做的改造（核心在 Auth 服务，网关无需改造）

- **前端改造**：登录页增加一个“使用 xxx 登录”的按钮。点击后，重定向到外部 SSO 的授权页面。

- **新增回调接口 \(Callback API\)**：在统一 SSO 后端服务中，新增一个接口（如 `GET /api/v1/auth/callback/ext-sso`）。接收外部 SSO 登录成功后跳回来带的 `Authorization Code`。

- **票据置换与用户映射（关键代码逻辑）**：

    1. 拿 `Code` 去请求外部 SSO，换取外部的 `Access Token` 和 `UserInfo`（拿到外部用户的手机号、邮箱或 UnionID）。

    2. **JIT \(Just\-In\-Time\) 机制**：拿手机号去你的 `sys_user` 表里查。

        - 如果查到了，说明是老用户（比如 `user_id = 1001`）。

        - 如果没查到，自动在 `sys_user` 表里新建一条记录，并赋予一个基础角色（如“访客角色”），得到新的 `user_id = 1002`。

    3. **签发内部 Token**：用查到或新建的内部 `user_id`，利用你自己的私钥，签发你系统内部的标准 JWT。返回给前端。

- **Istio / extauthz 网关**：**代码 0 修改**。网关收到的依然是你内部签发的 JWT，照常解析、查 Redis 权限、放行。

###### 对方（外部 SSO）需要做的配合

对方是标准 OIDC / OAuth2\.0 提供方，他们基本不需要写代码，只需在他们的管理员后台做配置：

- **注册你的应用**：在外部 SSO 后台建一个应用，生成 `Client ID` 和 `Client Secret` 交给你。

- **配置回调白名单**：把你刚才写的那个回调接口 URL（`/api/v1/auth/callback/ext-sso`）填入对方的配置域中，防止授权劫持。

##### 作为身份提供方（IdP） —— 别人的系统接入你的 IAM

**业务诉求**：统一 SSO 引擎已经非常完善，现在有第三方的合作商家、或者公司新收购的独立系统，希望实现“使用 ACP/ACC 平台账号一键登录”。

**架构原则**：** IAM 必须演进为标准的 OAuth 2\.0 / OIDC Server**。

###### 你的 IAM 引擎需要做的改造（全量支持 OAuth 2\.0 标准）

你需要在你的 SSO 引擎后端增加标准协议接口和对应的数据库表：

- **新增客户端管理表 \(****`oauth2_registered_client`****\)**：用来登记谁接入了你。字段包括 `client_id`, `client_secret`, `redirect_uris`, `scopes`。

- **实现四大标准接口**：

    1. `GET /oauth2/authorize`：这是前端页面。如果用户未登录，展示你的标准登录页；如果已登录，展示**授权确认页**（“XXX 申请获取你的个人信息，是否同意？”）。

    2. `POST /oauth2/token`：接收第三方用 `Code` 来换取 Token 的请求。你需要给第三方下发 `Access Token` 和 `id_token`。

    3. `GET /oauth2/userinfo`：第三方拿到 Token 后，调用这个接口获取你的用户基础信息（如用户 ID、昵称）。

    4. `GET /.well-known/openid-configuration`：\(可选但强烈推荐\) 暴露你的 OIDC 发现端点和 JWKS 公钥，方便大型第三方系统自动对接。

客户端管理表 \(oauth2\_registered\_client\) 里面存什么？核心结构如下：

**为什么要区分 ****`is_first_party`****？** 内部系统（停车、充电）是绝对可信的；外部合作方的系统是不可信的。这个字段决定了用户登录时**要不要弹出“授权同意页”**。

认证与鉴权中，这张表的完整流转逻辑（Step\-by\-Step）

步骤 1：客户端发起登录请求，校验回调地址（防伪造）

- **动作**：合作方 A 的网页发现用户没登录，重定向到你的 IAM 登录中心，URL 长这样： `GET [https://你的``IAM.com/oauth2/authorize?client_id=external_partner_a&redirect_uri=https://partner.com/auth&response_type=code](https://xn--IAM-x69di30p.com/oauth2/authorize?client_id=external_partner_a&redirect_uri=https://partner.com/auth&response_type=code)`

- **IAM 引擎逻辑（查表）**：

    1. IAM 拿到 `client_id=external_partner_a`，去 `客户端管理表` 里查。如果查不到，说明是非法接入，直接报错。

    2. IAM 核对传过来的 `redirect_uri` 是否与表里登记的地址完全一致。如果不一样（比如黑客把回调地址改成了黑客的网站），直接报错拦截。

步骤 2：用户输入账密与授权确认（区别对待内部/外部）

- **动作**：用户在你的 IAM 页面上输入账号密码，验证成功（确认是“张三”）。

- **IAM 引擎逻辑（查表区分）**：

    1. IAM 查表发现 `external_partner_a` 的 `is_first_party = 0`（外部系统）。

    2. IAM 必须中断重定向，**展示一个授权页面**：“【合作方A】正在申请获取您的基本信息和停车记录，是否同意？”（就像你用微信登录京东时弹出的那个授权页）。

    3. 如果是你的停车系统（`acp_parking_web`，`is_first_party = 1`），**不弹授权页**，直接无感生成 Code 跳回停车系统。

步骤 3：换取 Token 并校验身份（防抵赖）

- **动作**：合作方 A 拿到了你发给他的授权码（Code），他在后台服务器向你发起请求换取真正的 Token： `POST [https://你的``IAM.com/oauth2/token](https://xn--IAM-x69di30p.com/oauth2/token)` \(带着 `client_id=external_partner_a`, `client_secret=zzzzzz`, `code=xxx`\)

- **IAM 引擎逻辑（查表鉴权）**： IAM 拿着传过来的 `client_secret` 与 `客户端管理表` 里的密码比对。对上了，才认为真的是“合作方A”的服务器发来的请求，随后签发 JWT \(Access Token\)。

**到了 extauthz 网关层，该怎么做权限控制？**

当外部系统拿到了你的 JWT，他们有两种用法。第一种是只拿 Token 里的 `user_id` 去登录他们自己的系统，这与你无关。第二种是，**他们带着这个 Token，来调你的业务 API（比如查询张三的停车记录）**。

这个时候，你的 Istio `extauthz` 网关就需要进行“双重鉴权”了。这也是为什么 IAM 必须管理客户端的原因。

**场景冲突：** 张三是你的超级管理员，拥有所有菜单权限。但是，张三用“合作方A”的系统登录了。“合作方A”带着张三的 Token 试图调用你的 `DELETE /api/v1/parking-lots/1`（删除停车场接口）。 如果网关只查“张三”的权限，那么验证会通过，停车场就被外部系统删除了！这是绝对的安全灾难。

**网关的正确鉴权逻辑（结合 Client Scopes）：**

1. 外部系统拿着 JWT 请求网关。

2. `extauthz` 解析 JWT。标准的 OAuth2 JWT 里不仅有用户是谁（`sub: 1001`），还有**这是哪个客户端申请的 Token（****`aud: external_partner_a`****，或者 ****`scope: read_parking`****）**。

3. `extauthz` 的校验规则变成：

    - 第一层：当前【客户端（合作方A）】是否有权调用这个 API？（根据表里的 `scopes` 字段，发现它只有 `read` 权限，没有 `delete` 权限）。

    - 第二层：当前【用户（张三）】是否有权调用这个 API？

4. 因为第一层客户端权限验证失败，网关直接返回 403 Forbidden，保护了你的核心数据。

###### 对方（外部系统）需要做的改造

对方变成了标准的 OAuth 2\.0 Client，他们需要：

- 找你申请分配 `client_id` 和 `client_secret`。

- 在他们自己的系统中编写重定向到你的 `/oauth2/authorize` 的逻辑。

- 拿到你的 JWT 后，解析出唯一标识，在他们自己的数据库里做账号映射。

##### 机器对机器（M2M）的纯接口调用接入

**业务诉求**：除了页面登录，外部合作方需要直接通过 HTTP API 调用 K8s 集群内停车或充电子系统的数据（比如同步某个停车场的可用车位）。

这是 `extauthz` 网关唯一需要配合改造的地方，因为这种请求**没有人类用户，只有应用**，传统的基于“菜单/按钮”的 RBAC 行不通了。

#### 改造方案：Client Credentials \(凭证模式\) \+ 接口白名单

1. **统一 SSO 引擎改造**：

    - 外部商家申请 `AppKey` \(client\_id\) 和 `AppSecret` \(client\_secret\)。

    - 管理员在IAM后台为这个 `AppKey` 分配**接口级权限**（比如只允许调用 `GET /api/v1/parking-lots/{id}/status`）。

    - 对方调用你的 `/oauth2/token` 接口（grant\_type=client\_credentials），SSO 签发一个特殊的 JWT（里面没有 `user_id`，只有 `client_id`，角色变成了 `client_role`）。

2. **Istio extauthz 网关改造**：

    - 当请求到达 `extauthz` 时，解析 JWT。

    - 如果发现是机器 Token（没有 `user_id`），就不去查前端菜单生成的权限树，而是去 Redis 查这个 `client_id` 绑定的 **API 访问白名单**。

    - 验证 URL 通过后，在发给下层微服务的 Header 里，透传 `X-App-Id: xxx` 而不是 `X-User-Id`。

    - 底层的微服务同样通过 AOP 拦截器识别这个 Header，执行对应的数据权限隔离逻辑。

### 用户、角色、权限标识、URL关系详解

在RABC架构下的认证鉴权体系，用户、角色、权限标识、URL链接他们之间的关系都是**多对多**的关系。权限标识符是给前端鉴权用的，例如：acc:system:user:add，结构为  系统标识：菜单标识（可多级菜单用冒号多级连接）：按钮标识，URL为后端具体请求路径给后端鉴权使用。再次说明，权限标识与URL链接是**多对多**关系，因为前端一个按钮或菜单，可能需要调用多个接口，一个接口也可能会在多个权限标识下添加。

用户、角色、权限标识、URL在页面如何实现关联及效果，可以参照[若依后管](https://vue.ruoyi.vip/system/menu)页面：

![image\.png](https://image.hyly.net/i/2026/08/20/b2dc5c4141c8ea4bb0536707deb354b1-0.webp)

### Sa\-Token示例

#### 极简 API

Sa\-Token 的核心设计理念就是“极简 API”。它将复杂的 Token 生成、上下文解析、会话管理以及权限校验逻辑，全部封装在了 `StpUtil` 等全局工具类中。开发者在业务代码中不需要注入复杂的依赖，也不需要编写冗长的判断逻辑，只需要在需要控制权限的地方调用一行静态方法。如果不满足条件，框架会自动抛出异常并被全局异常处理器接管，从而实现极其干净的代码结构。

```Java
import cn.dev33.satoken.stp.StpUtil;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/user")
public class UserController {

    // 1. 登录认证：一行代码完成 Token 生成、写入 Cookie、Session 创建等一系列操作
    @RequestMapping("/doLogin")
    public String doLogin(long userId) {
        StpUtil.login(userId);
        return "登录成功，Token 已下发";
    }

    // 2. 状态拦截：一行代码校验当前请求是否已登录，未登录会自动抛出 NotLoginException
    @RequestMapping("/info")
    public String userInfo() {
        StpUtil.checkLogin(); 
        return "这是只有登录后才能看到的用户信息";
    }

    // 3. 角色鉴权：一行代码校验当前登录账号是否拥有指定角色，不具备会抛出 NotRoleException
    @RequestMapping("/admin-panel")
    public String adminPanel() {
        StpUtil.checkRole("admin"); 
        return "欢迎进入后台管理系统";
    }

    // 4. 权限鉴权：一行代码校验是否有特定操作权限，不具备会抛出 NotPermissionException
    @RequestMapping("/delete")
    public String delete() {
        StpUtil.checkPermission("user:delete"); 
        return "删除成功";
    }
}
```

#### 极简中心化IAM引入

在分布式的微服务架构下，各子系统无需各自实现一套复杂的登录和鉴权逻辑。Sa\-Token 提供了高度成熟的 Starter 依赖，各业务子系统只需通过 Maven 引入核心包以及与 Redis 的整合包，并将 Redis 地址指向中心化 IAM（身份与访问管理）服务所使用的共享缓存池。引入后，子系统即可自动识别由 IAM 中心签发的 Token，实现无缝的统一登录（SSO）和统一鉴权，开箱即用。

**Maven 依赖：**在各子系统的 `pom.xml` 中引入以下依赖（以 Spring Boot 3\.x 为例）：

```XML
<!-- 1. 引入 Sa-Token 核心 Starter -->
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-spring-boot3-starter</artifactId>
    <version>1.38.0</version>
</dependency>

<!-- 2. 引入 Sa-Token 整合 Redis 的依赖（中心化 IAM 共享状态的关键） -->
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-redis-jackson</artifactId>
    <version>1.38.0</version>
</dependency>

<!-- 3. 提供 Redis 连接池支持 -->
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-pool2</artifactId>
</dependency>
```

**配套的接入配置（application\.yml）：** 子系统引入 jar 包后，只需在配置文件中将状态存储指向 IAM 所在的中心化 Redis 即可完成接入：

```YAML
spring:
  data:
    redis:
      # 这里指向中心化 IAM 系统使用的同一台 Redis，以此实现 Token 状态共享
      host: 192.168.100.52 
      port: 6379
      password: your_password

sa-token:
  # Token 名称 (必须与中心化 IAM 下发的 Token 名称保持一致)
  token-name: Authorization
  # token 有效期，单位s 默认30天
  timeout: 2592000
  # 是否尝试从 header 中读取 Token
  is-read-header: true
```

### IstioGateway或Istio\-proxy网关使用示例

这里以istio\-proxy为例：

1. 首先在需要进行鉴权的服务helm里开启istio注入。

![image\.png](https://image.hyly.net/i/2026/08/20/88420e4601201347e0ba104de9bda643-0.webp)

2. 其次编写**AuthorizationPolicy**文件，添加需要拦截的URL和转发到IAM服务的名字。

```YAML
apiVersion: *security.istio.io/v1*
kind: *AuthorizationPolicy*
metadata:
  annotations:
    {{- if .Values.global.autoscaling.isSyncWave }}
    argocd.argoproj.io/sync-wave: {{ .Values.global.autoscaling.apiAcb.syncWave | quote }}
    {{- end }}
  name: api-acb-custom
  namespace: {{ .Values.global.app.ACBNamespace }}
spec:
  selector:
    matchLabels:
      serving.knative.dev/service: api-acb
  action: CUSTOM
  # IAM服务的提供者，这里是micro-extauthz
  provider:
    name: micro-extauthz
  rules:
    - to:
        - operation:
            # 需要哪些路由进行拦截转发到IAM服务，理论上这里要写/**，所有的都需要鉴权。
            paths: [ "/berth/add","/berth/berthOnline","/berth/import","/parkEoc/updateAuditStatus","/bacb/park/lightbox/channels/upsert" ]
   
```

3. 最后集群装istio的命名空间找到istio配置文件，添加istio extensionProviders。如果没有特殊修改是按照istio官方脚本装的，那就是在istio\-system命名空间下。

```YAML
---
apiVersion: v1
data:
  mesh: |-
    extensionProviders:
    # 必须与AuthorizationPolicy文件里的IAM服务名字一致。
    - name: "micro-extauthz"
      envoyExtAuthzHttp:
        # IAM服务在集群里的具体地址
        service: "micro-extauthz.acb-standard-dev.svc.cluster.local"
        port: "80"
        # 访问各子系统的URL经istio网关拦截后转发给IAM服务携带的header
        includeRequestHeadersInCheck: ["Authorization","Session-Id","content-type","accept","enableStatus"]
        # 核心在这里！istio Envoy 会把请求发到IAM服务（extauthz）这个确切的 URL 上进行鉴权，然后返回是否通过。
        pathPrefix: "/auth/verify" 
    defaultConfig:
      proxyMetadata:
      PROMETHEUS_SCRAPE_PATH: "/metrics"
      PROMETHEUS_ADDRESS: "prometheus-k8s.monitoring.svc.cluster.local:9090"
      discoveryAddress: istiod.istio-system.svc:15012
    defaultProviders:
      metrics:
      - prometheus
    enablePrometheusMerge: true
    rootNamespace: istio-system
    trustDomain: cluster.local
  meshNetworks: 'networks: {}'
kind: ConfigMap
metadata:
  annotations: {}
  labels:
    app.kubernetes.io/instance: istio
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: istiod
    app.kubernetes.io/part-of: istio
    app.kubernetes.io/version: 1.26.2
    helm.sh/chart: istiod-1.26.2
    install.operator.istio.io/owning-resource: unknown
    install.operator.istio.io/owning-resource-namespace: istio-system
    istio.io/rev: default
    operator.istio.io/component: Pilot
    operator.istio.io/managed: Reconcile
    operator.istio.io/version: 1.26.2
    release: istio
  name: istio
  namespace: istio-system
  resourceVersion: '11555185260'


```

![image\.png](https://image.hyly.net/i/2026/08/20/88e58e102a3748783895ecfdf28024dd-0.webp)

### 各子系统数据权限实现方式

在 Java 生态中，最主流、最优雅的做法是使用 **MyBatis 的拦截器（Interceptor） \+ 自定义注解（Annotation） \+ SQL 改写** 来实现。

以下是完整的文字说明和核心代码示例：

#### 总体设计思路

1. **定义规则**：定义一个枚举，描述数据权限的种类（全部可见、本部门可见、仅本人可见等）。

2. **网关透传**：`extauthz` 鉴权通过后，根据用户的角色，推导出一个“数据权限标识（DataScope）”，并将其通过 HTTP Header 传给子系统（如：`X-Data-Scope: DEPT`，`X-Dept-Id: 100`，`X-User-Id: 1001`）。

3. **子系统上下文**：子系统利用 Spring 的 `HandlerInterceptor`（或者 Filter）拦截请求，将这些 Header 存入 `ThreadLocal` 中，以便当前线程随时读取。

4. **注解标记**：开发人员在需要控制数据权限的 Mapper 接口（或 Service 方法）上，打上 `@DataScope` 注解。

5. **MyBatis 拦截器**：拦截 MyBatis 的 `StatementHandler` \(或 `Executor`\) 执行 `prepare` 阶段。如果发现执行的方法上有 `@DataScope` 注解，就从 `ThreadLocal` 拿出当前用户的部门/ID，然后利用 SQL 解析工具（如 JSqlParser），自动在原始 SQL 后面追加 `WHERE` 条件，从而实现数据隔离。

#### 代码示例：MyBatis 数据权限拦截器

以下是一个简化版、但五脏俱全的核心代码示例。

##### 定义数据权限注解 `@DataScope`

在需要做数据隔离的查询方法上打这个注解，告诉拦截器该表对应的别名。

```Java
import java.lang.annotation.*;

@Target({ElementType.METHOD})@Retention(RetentionPolicy.RUNTIME)@Documentedpublic @interface DataScope {
    /**
     * 部门表的别名 (例如在 SELECT * FROM sys_order o 中，这里填 "o")
     */String deptAlias() default "";

    /**
     * 用户表的别名 (如果表里存的是 creator_id)
     */String userAlias() default "";
}
```

##### 定义存放当前用户信息的上下文工具类

通过拦截 HTTP 请求，把 Header 里的网关透传信息存到当前线程里。

```Java
public class SecurityContextHolder {
    private static final ThreadLocal<UserInfo> CONTEXT = new ThreadLocal<>();

    public static void setUserInfo(UserInfo userInfo) {
        CONTEXT.set(userInfo);
    }

    public static UserInfo getUserInfo() {
        return CONTEXT.get();
    }

    public static void clear() {
        CONTEXT.remove();
    }

    // 内部类模拟当前用户信息public static class UserInfo {
        private String userId;
        private String deptId;
        private String dataScopeType; // 例如: "ALL", "DEPT", "SELF"// getters and setters...
    }
}
```

##### 核心：MyBatis 拦截器实现 SQL 改写

我们需要拦截 `StatementHandler` 的 `prepare` 方法。在它把 SQL 交给数据库执行前，把权限条件拼装进去。这里为了演示清晰，使用简单的字符串拼接，生产环境中强烈建议使用 `JSqlParser` 库进行安全的抽象语法树（AST）修改。

```Java
import org.apache.ibatis.executor.statement.StatementHandler;
import org.apache.ibatis.mapping.BoundSql;
import org.apache.ibatis.mapping.MappedStatement;
import org.apache.ibatis.plugin.*;
import org.apache.ibatis.reflection.MetaObject;
import org.apache.ibatis.reflection.SystemMetaObject;
import org.springframework.stereotype.Component;

import java.sql.Connection;
import java.util.Properties;

@Intercepts({
    @Signature(type = StatementHandler.class, method = "prepare", args = {Connection.class, Integer.class})
})@Componentpublic class DataScopeInterceptor implements Interceptor {

    @Overridepublic Object intercept(Invocation invocation) throws Throwable {
        StatementHandler statementHandler = (StatementHandler) invocation.getTarget();
        
        // 使用 MyBatis 提供的反射工具获取底层对象
        MetaObject metaObject = SystemMetaObject.forObject(statementHandler);
        
        // 先判断是不是 SELECT 语句，数据权限一般只拦截查询
        MappedStatement mappedStatement = (MappedStatement) metaObject.getValue("delegate.mappedStatement");
        if (!mappedStatement.getSqlCommandType().name().equals("SELECT")) {
            return invocation.proceed(); // 不是查询，直接放行
        }

        // 获取方法上的 @DataScope 注解 (需要结合代理找到原始方法，此处简化处理)
        DataScope dataScope = getAnnotation(mappedStatement);
        if (dataScope == null) {
            return invocation.proceed(); // 没打注解，说明不需要控制数据权限
        }

        // 获取当前请求的用户信息 (从 ThreadLocal 里拿)
        SecurityContextHolder.UserInfo userInfo = SecurityContextHolder.getUserInfo();
        if (userInfo == null) {
            return invocation.proceed();
        }

        // 如果是超级管理员，直接放行 (ALL 级别)if ("ALL".equals(userInfo.getDataScopeType())) {
            return invocation.proceed();
        }

        // 核心：取出原始 SQL，并拼接权限条件
        BoundSql boundSql = statementHandler.getBoundSql();
        String originalSql = boundSql.getSql();
        String appendSql = buildDataScopeSql(dataScope, userInfo);

        if (appendSql != null && !appendSql.isEmpty()) {
            // 简单组装：将原 SQL 包装为一个子查询，再在外层拼条件// (生产环境建议用 JSqlParser 修改原 SQL 的 WHERE 树)
            String modifiedSql = "SELECT * FROM (" + originalSql + ") AS data_scope_wrapper WHERE " + appendSql;
            
            // 将改写后的 SQL 重新塞回去
            metaObject.setValue("delegate.boundSql.sql", modifiedSql);
        }

        // 继续执行 MyBatis 流程return invocation.proceed();
    }

    /**
     * 根据数据权限类型，组装 SQL 条件
     */private String buildDataScopeSql(DataScope dataScope, SecurityContextHolder.UserInfo userInfo) {
        StringBuilder sqlBuilder = new StringBuilder();
        String deptAlias = dataScope.deptAlias().isEmpty() ? "" : dataScope.deptAlias() + ".";
        String userAlias = dataScope.userAlias().isEmpty() ? "" : dataScope.userAlias() + ".";

        switch (userInfo.getDataScopeType()) {
            case "DEPT":
                // 本部门可见
                sqlBuilder.append(deptAlias).append("dept_id = '").append(userInfo.getDeptId()).append("'");
                break;
            case "DEPT_AND_CHILD":
                // 本部门及下属部门可见 (通常通过 like 匹配层级树，或者 IN 子查询)// 这里假设通过部门树编码进行 like
                sqlBuilder.append(deptAlias).append("dept_id IN (SELECT dept_id FROM sys_dept WHERE parent_id = '").append(userInfo.getDeptId()).append("')");
                break;
            case "SELF":
                // 仅本人可见
                sqlBuilder.append(userAlias).append("creator_id = '").append(userInfo.getUserId()).append("'");
                break;
            default:
                // 默认阻断或抛异常
                sqlBuilder.append("1 = 0");
        }
        return sqlBuilder.toString();
    }

    @Overridepublic Object plugin(Object target) {
        return Plugin.wrap(target, this);
    }

    @Overridepublic void setProperties(Properties properties) {
    }

    // 这是一个模拟方法，实际开发中需要通过反射获取 Mapper 方法上的注解private DataScope getAnnotation(MappedStatement mappedStatement) {
        // 实现逻辑略：通过 mappedStatement.getId() 获取类名和方法名，然后利用反射获取 @DataScopereturn null; 
    }
}
```

##### 在业务代码中使用

经过上述配置后，业务子系统的开发人员只需要做非常简单的事。

**Mapper 接口：**

```Java
@Mapperpublic interface OrderMapper {

    // 告诉拦截器，这句 SQL 中订单表的别名是 "o"@DataScope(deptAlias = "o", userAlias = "o")@Select("SELECT * FROM sys_order o WHERE o.status = 1")List<Order> selectOrderList();
}
```

**发生了什么？**

- 当一个部门 ID 为 `10` 的销售主管（被配置为“本部门可见”）调用该方法时。

- 他期望执行的是：`SELECT * FROM sys_order o WHERE o.status = 1`。

- 但底层的 MyBatis 拦截器瞬间把 SQL 替换成了：`SELECT * FROM (SELECT * FROM sys_order o WHERE o.status = 1) AS data_scope_wrapper WHERE o.dept_id = '10'`。

- 从而优雅地实现了数据权限隔离。

### RBAC和ABAC详解

在权限体系设计中，RBAC 和 ABAC 是两种最核心的模型。它们的根本区别在于**判断权限的依据不同**。

#### RBAC \(基于角色的访问控制\)

- **核心逻辑**：Who you are。权限赋予“角色”，用户通过绑定“角色”来获取权限。

- **模型链条**：用户 \(User\) \-\> 角色 \(Role\) \-\> 权限标识 \(Permission\)。

- **适用场景**：静态的、层级分明的业务系统（如后台管理、CRM、ERP）。例如：“财务经理可以查看所有账单”。

#### ABAC \(基于属性的访问控制\)

- **核心逻辑**：What you have \+ Context。根据用户的属性、资源的属性以及环境上下文，通过“规则引擎”动态计算是否放行。

- **判断维度**：

    - **主体属性 \(User\)**：职位、部门、安全许可级别。

    - **客体属性 \(Resource\)**：文档机密等级、创建者、所属项目。

    - **环境属性 \(Environment\)**：当前时间、IP 段、设备类型（公司电脑还是个人手机）。

- **适用场景**：动态的、细粒度极高的安全场景（如 AWS IAM、金融核心数据访问）。例如：“仅允许研发部员工在工作日 9:00\-18:00，通过公司内网 IP，修改机密级别为‘内部’且属于他们自己参与的项目的文档”。

**对比总结：**

#### ABAC 能做，但 RBAC 绝对做不到的场景（RBAC 的死穴）

RBAC 的致命弱点在于它是一个**静态模型**。它只关心“你是谁（角色）”，完全不关心“当前环境是什么”、“资源属于谁”。如果强行用 RBAC 解决动态问题，会导致**角色爆炸（Role Explosion）**。

##### 场景 1：基于上下文（环境）的动态风控

- **需求**：“财务人员只有在工作日 9:00\-18:00，且连接公司内网 IP 时，才能发起 100 万以上的转账操作。在家办公或周末只能查看，不能转账。”

- **RBAC 的表现**：做不到。RBAC 的角色分配是静态的。只要你拥有“财务”角色，你半夜两点在网吧也能转账。

- **ABAC 的表现**：轻松拿捏。ABAC 的策略引擎可以动态读取 `User.Role = 财务` AND `Env.Time = 09:00-18:00` AND `Env.IP = 内网段`，只有全部通过才放行。

##### 场景 2：基于主客体关联的细粒度数据隔离

- **需求**：“在医院系统中，主治医生可以查看病历，但**只能查看自己当前负责的病人的病历**。”

- **RBAC 的表现**：崩溃。为了实现这个，你需要为每一个病人建一个角色（例如：`张三的医生角色`、`李四的医生角色`），如果有 10 万个病人，就要建 10 万个角色，系统直接瘫痪。

- **ABAC 的表现**：完美契合。只需要一条策略：`Allow` IF `User.Type = 医生` AND `User.ID == Resource(病人病历).AttendingDoctorID`。

##### 场景 3：基于资源属性（涉密等级）的访问控制

- **需求**：“研发部员工默认只能访问‘内部公开’级别的文档；如果要访问‘机密’级别文档，员工的安全许可级别（Clearance Level）必须大于等于文档的机密级别。”

- **RBAC 的表现**：极其繁琐。需要建立“研发\-普通角色”、“研发\-机密角色1”、“研发\-机密角色2”，并且每次文档密级调整，都要去动用户的角色。

- **ABAC 的表现**：动态计算。对比属性 `User.ClearanceLevel >= Resource.SecretLevel` 即可。

#### RBAC 能做，但 ABAC 做不到（或做得极差）的场景

虽然理论上 ABAC 可以把“角色”当作一个属性（从而包容 RBAC），但在实际工程管理中，**ABAC 在“确定性审计”和“宏观管理”上是一场噩梦**。

##### 场景 1：全局权限审计（上帝视角）

- **需求**：公司合规部门来审计，要求导出：“**‘财务总监’这个岗位，在全公司系统里到底能点开哪些菜单？调用哪些接口？**”

- **RBAC 的表现**：一秒查出。因为关系是静态入库的（角色 \-\> 菜单/接口），直接写个 SQL 联表查询就能拉出一份清晰的清单。

- **ABAC 的表现**：**数学上几乎无法回答**。因为 ABAC 没有静态绑定的概念，它的权限是运行时动态计算的。要回答“财务总监能看什么”，你必须把全公司几亿条数据遍历一遍，模拟财务总监去访问，看看规则引擎返回 True 还是 False。合规审计在纯 ABAC 系统面前往往会抓狂。

##### 场景 2：员工入职/调岗的高效分配

- **需求**：“新来了一个叫李四的实习生，分配到华南大区销售部。”

- **RBAC 的表现**：极其简单。管理员在后台把李四拖进“华南区销售实习生”的角色组，李四瞬间获得了所有该有的基础菜单和按钮权限。前端也能立刻根据角色渲染出他该看的页面。

- **ABAC 的表现**：管理门槛极高。由于没有“角色组”打包权限的概念，管理员必须确保李四的用户画像里被打上了完美的属性标签（地区=华南，部门=销售，职级=实习生）。如果系统依赖某个非常偏门的属性（比如“所在办公楼层”），一旦标签填漏了，李四就无法正常工作。

##### 场景 3：前端菜单树的快速渲染

- **需求**：用户登录后，前端需要立刻知道左侧 100 个菜单中，哪 20 个该显示出来。

- **RBAC 的表现**：登录时带回一个 Code 列表 `["menu:order", "menu:user"]`，前端瞬间渲染完毕。

- **ABAC 的表现**：前端无法在登录时拿到确切的菜单列表。因为在 ABAC 逻辑里，你能不能看“订单菜单”，可能取决于当前是几点，或者这个菜单里目前有没有你的数据。这会导致前端渲染逻辑极其难以设计。

#### 总结：各自的边界与业界最佳实践

**真正的最佳实践：RBAC 与 ABAC 的混合架构（RBAC \+ ABAC）**

在类似于 Kubernetes \+ Istio 这样的大型微服务集群中，现代零信任架构通常这样设计：

1. **外层用 RBAC 挡住 90% 的无效请求**： 前端菜单显示、按钮展示、Istio 网关 \(`extauthz`\) 拦截，**全部使用 RBAC**。只要用户没有“订单删除”的角色，网关直接拦截。这保证了系统的高性能和易管性。

2. **内层用 ABAC 做最后 10% 的精准收口**： 当请求过了网关，到达 `OrderService` \(订单微服务\) 内部时。微服务在执行 SQL 删除前，调用本地的 ABAC 规则引擎（如 Open Policy Agent \- OPA），判断：“当前时间是否允许？这条订单是不是这个操作人创建的？”满足条件才最终落库。



> **总结：调研各产品线，RBAC已经满足需求，目前没有ABAC的使用场景，故先开发ABAC，以后有实际ABAC场景需求再对各子系统开发极细粒度权限（有状态的ABAC只能在子系统上做）。**
> 
> 




