---
category: [Java技术栈]
tag: [git,项目组,迁移]
postType: post
status: publish
---

## 前言

原公司总共有一千多个GIT项目，光所属部门就有62个，为了规范GIT统一管理，把部门内的项目统一划分到一个项目组下边，而不是很零碎的父级组，故制定此方案，感兴趣或正好需要的同学可以看下~

## 迁移方式

![image-20260629174246762](https://image.hyly.net/i/2026/06/29/aa01efb63872c965524c475780b141f9-0.webp)

公司使用的`gitLab`，如果使用其它git仓库的小伙伴可自行AI解决哈，原理都是大差不差的。迁移方式也很简单，先新建aipark项目组，本部门的GIT项目都放到这个下面，之后在想要迁移的项目/项目组选中**Settings->General->Advanced->Transfer group->Select parent group**选中新建的aipark项目组即可完成迁移。

## 需要注意的地方

### 权限问题

此次迁移相当于是在原来所有的项目/项目组上面新建了aipark项目组，此种方式只要原来项目/项目组有git权限的迁移之后都会被继承过来，理论上不需要再重新授权，如有权限问题的可以自行AI再重新添加下权限哈~

### 研发本地git地址问题

项目迁移之后git地址会发生改变，在路径上多/aipark，默认gitlab会进行URL重定向，研发人员不需要更改本地IDEA的git地址仍可正常提交代码，但此并不是一个正规方式，后续可能会遇到再新建一个旧GIT地址同名项目，就会导致本地提交失败。

所以建议有条件的同学在提交完本地代码之后，主动在**IDEA->Git->管理远程**处双击项目地址手动添加缺失路径/aipark

![img](https://image.hyly.net/i/2026/06/29/f170c4b0c21e9949e1310ff4531b7fa5-0.webp)![img](https://image.hyly.net/i/2026/06/29/f7352b72d8a3e65792089bb553a62be6-0.webp)

### 其他关联场景排查与适配（CI/CD及第三方集成）

除了代码提交，迁移还会引起以下系统级配置的路径变化，请相关组件负责人同步排查：

- **CI/CD 流水线 (GitLab CI)：**
	- `.gitlab-ci.yml` 脚本中，如果存在**硬编码**的旧仓库地址（例如脚本内部依赖了 `git clone` 其他模块），需要同步修改为新路径。
	- 检查 CI/CD Runner 的作用域。如果 Runner 是绑定在原有的顶级 Group 级别，迁移成为子组后，可能需要重新注册或调整 Runner 范围以确保流水线正常触发。
- **Webhooks 与自动化通知：**
	- 如果你配置了 Webhooks（例如推送代码自动触发 Jenkins 构建，或者发送钉钉/企业微信机器人通知），**部分第三方系统不会识别 GitLab 的 301 重定向**。必须进入 `Settings` -> `Webhooks`，将回调 URL 和触发规则更新为最新状态。
- **包管理与镜像仓库 (Package / Container Registry)：**
	- 如果你使用了 GitLab 提供的 Maven 私服、NPM 仓库或 Docker 镜像仓库，仓库的推送与拉取 URL 会随着组层级的改变而变化。请务必修改微服务项目中的 `pom.xml`、`.npmrc` 或 Dockerfile 构建脚本中的 Registry 路径。

至此，所有杂乱的git项目都转移到本部门/aipark组下了，也可以弄个GIT项目清单文件，以后也能基于此来对部门所有GIT项目进行管理，形成知识资产，等有新同学入职了也可快速上手~