---
category: [k8s技术栈]
tag: [k8sgpt,AI,自动化,运维]
postType: post
status: publish
---

先看本地和operator的效果！

原理也可简单，就是通过k8sGPT把集群状态信息发送给大模型，由大模型进行诊断并给出具体操作由k8sGPT去执行。

## 前言

深夜被告警邮件叫醒，对着满屏飘红的 `CrashLoopBackOff` 和 `ImagePullBackOff` 发呆？又或者在成百上千行的 Kubernetes 事件日志里大海捞针，试图寻找那个导致微服务雪崩的罪魁祸首？作为常年和 K8s 斗智斗勇的“YAML 工程师”，我们都懂这种心力交瘁的痛。

但在 AI 大模型能力狂飙的今天，是时候给我们的集群请一位 24 小时在线的“AI 老中医”来减负了！今天我们要聊的主角就是 **k8sgpt**——一个能直接帮我们给 K8s 集群“把脉问诊”的开源神器。它不仅能一眼看穿复杂的集群报错，还能用人话（中文！）告诉你问题在哪、该怎么修。

本文将带你玩转 k8sgpt 的两种核心姿势：

1. **本地 CLI 模式**：极简入门，只需在本地 Windows 的 PowerShell 里敲几行命令，就能对集群做一次全面的“AI 快速体检”。
2. **Operator 模式**：高阶玩法，把 k8sgpt 作为长驻的守护进程直接“种”进 K8s 集群里，配合纯本地部署的大模型（数据绝对安全，断网也能跑），实现 24 小时无间断巡检，并把结果输出到集群 CRD 中。

准备好了吗？让我们直接开干，看看怎么让 AI 替我们扛下这繁杂的排障黑锅！

## 本地模式

### 安装 k8sgpt

这里以window为例，

1. 首先去[GitHub](https://github.com/k8sgpt-ai/k8sgpt/releases)下载软件压缩包，例如 k8sgpt_Windows_x86_64.tar.gz。
2. 解压后，将里面的 `k8sgpt.exe` 文件放到一个指定的文件夹，并将该文件夹路径添加到系统的环境变量 PATH 中。
3. 重启 PowerShell，输入 `k8sgpt version` 确认安装成功。

### 配置 AI 后端 (Authentication)

k8sgpt 本身只是一个诊断引擎，它的“大脑”需要依赖 AI 模型。你有两种主要的选择：

**选项 A：使用云端模型（如 OpenAI，最简单且准确度高）。**

如果你有 OpenAI 的 API Key，可以直接将其绑定到 k8sgpt：

```
k8sgpt auth add --backend openai
```

执行后系统会提示你输入 API Key，默认会使用 `gpt-3.5-turbo` 模型。

**选项 B：使用完全本地化的 AI（如 Ollama，适合数据敏感/断网环境）**如果你不希望集群的数据被发送到云端，可以完全在本地跑大模型：

1. 先在本地安装 [Ollama](https://ollama.com/)。
2. 在 PowerShell 中拉取一个轻量级的开源模型（比如 `llama3.2` 或 `mistral`）：

PowerShell

```
ollama pull llama3.2
```

3. 将 k8sgpt 连接到你本地的 Ollama 服务：

PowerShell

```
k8sgpt auth add --backend ollama --model llama3.2 --baseurl http://localhost:11434/v1
```

### 开始本地分析与巡检

配置完成后，你就可以对当前的集群进行“体检”了：

1. **基础扫描**（找出集群中异常的资源，如 CrashLoopBackOff 的 Pod）：

PowerShell

```
k8sgpt analyze
```

2. **获取 AI 智能解释与修复命令**（核心功能）：

PowerShell

```
k8sgpt analyze --explain
```

3. **使用中文输出**（非常实用的技巧）：

PowerShell

```
k8sgpt analyze --explain --language Chinese
```

4. **精准过滤**（只看某个 namespace 或某种资源的报错）：

PowerShell

```
k8sgpt analyze --explain --filter=Pod --namespace=kube-system
```

### 走向真正的“自动化运维” (进阶)

本地 CLI 工具非常适合平时手动排错。如果你想要实现真正的**自动化**（例如：集群后台24小时自动巡检，发现问题自动把中文修复方案推送到钉钉/飞书/Slack），你需要部署 **k8sgpt-operator**：

1. 通过 Helm 将 k8sgpt 作为一个长驻进程安装在 K8s 集群内部。
2. 它会持续生成 `Result` CRD（自定义资源），你可以监听这些资源来实现自动化报警闭环。

### 运行结果

![img](https://image.hyly.net/i/2026/04/17/39d99b9ce4d2906f7ee312570e506331-0.webp)

![img](https://image.hyly.net/i/2026/04/17/4cd0cda72f63c6bbb104e49ab0213114-0.webp)

## Operator模式

### 镜像预拉取

因为官方helm脚本里的镜像都是dockehub里的镜像名称，所以helm部署的时候默认就会去外网下载。这里有两种选择，第一给服务器翻墙。第二先找一台能翻墙的机器把镜像预下载下来推送到内网镜像库或者直接上传到k8s集群里去。

这里选择推送到腾讯云镜像制品库，下载推送过程略可自行AI解决。

**需要的镜像列表：**

1. **ghcr.io/k8sgpt-ai/k8sgpt-operator:v0.2.27：**这是 Operator 模式的核心控制器。它是一个长驻在集群内部的守护进程。当你向集群提交一个 K8sGPT 类型的 YAML（也就是我们之前配置连向 vLLM 的那个文件）时，就是这个组件接收到了指令。它负责监听 K8s 资源的变化，管理生命周期，并在后台定期触发巡检任务（CronJob 或内部定时器）。发现异常后，它负责将分析结果转化为集群原生的 Result CRD 资源并保存下来。
2. **quay.io/brancz/kube-rbac-proxy:v0.19.1：**这是一个非常标准的 Kubernetes 辅助组件（几乎所有用 Kubebuilder 开发的官方 Operator 都会带上它）。它通常作为 Sidecar（边车）容器，与上面的 Operator 运行在同一个 Pod 里。Operator 在运行过程中会暴露一些运行状态和指标（Metrics，供 Prometheus 采集）。为了防止集群里的其他恶意 Pod 随意窃听这些监控数据，kube-rbac-proxy 会挡在 Operator 前面。任何想要获取 Metrics 的请求，都必须经过它的 RBAC 权限校验。
3. **ghcr.io/k8sgpt-ai/k8sgpt:latest：**这是 k8sgpt 真正的业务核心二进制镜像。它包含了所有具体的 K8s 资源分析器（Analyzers，比如分析 Pod Crash、Service 缺失等逻辑），并且它内置了与各种大模型（如 OpenAI、vLLM、Ollama 等）对接的客户端 SDK。
4. **mekayelanik/vllm-cpu:latest：**为模型引擎镜像，模型启动需要引擎支持，就好像jar包启动需要JVM。因为目前k8s环境只有CPU服务器，所以这里下载的是CPU版本，缺点就是模型推理慢。

### 通过 Helm 安装 Operator

确保你本地已经安装了 Helm，然后依次执行以下命令，将 Operator 部署到一个独立的命名空间中：

```
# 1. 添加 k8sgpt 的官方 Helm 仓库
helm repo add k8sgpt https://charts.k8sgpt.ai/
helm repo update

# 2. 安装 Operator 并自动创建命名空间
helm install k8sgpt k8sgpt/k8sgpt-operator -n k8sgpt-operator-system --create-namespace
```

可以通过 `kubectl get pods -n k8sgpt-operator-system` 确认 Operator 的 Pod 是否已经处于 `Running` 状态。

**这里为了留存可重复性部署，可以知道它在集群里部署了哪些资源，后续做配置定制也非常方便，所以把官方仓库的helm脚本下载下来上传到git仓库，这样以后切换环境可以直接用git Argo部署。**

以下是具体的 PowerShell 操作步骤：

#### **确保仓库已更新**

保险起见可以再更新一下本地缓存

```
helm repo update
```

#### **下载并解压 Helm Chart**

使用 `--untar` 参数，Helm 会自动帮你把下载的 `.tgz` 压缩包解压成一个常规文件夹：

```
helm pull k8sgpt/k8sgpt-operator --untar
```

执行完毕后，你可以通过 `ls` 命令看到当前目录下多出了一个名为 `k8sgpt-operator` 的文件夹。

#### **查看和修改配置**

进入这个文件夹，你会看到官方的完整部署文件：

- `**values.yaml**`：这是最核心的配置文件，你可以用文本编辑器打开它，查看或修改所有的默认参数。
- `**templates/**`：这里面包含了 Operator 涉及的所有 Kubernetes 原生资源清单（如 Deployment, RBAC, ServiceAccount 等）。

#### **使用本地文件进行安装（可选）**

如果你修改了本地的 `values.yaml`，或者就想通过本地文件来安装，只需要把你原本安装命令里的远端仓库名 `k8sgpt/k8sgpt-operator` 替换成本地文件夹路径 `./k8sgpt-operator` 即可：

```
helm install k8sgpt ./k8sgpt-operator-n k8sgpt-operator-system --create-namespace
```

把文件拉到本地是一个非常好的选择，这样不仅能搞清楚它到底在集群里创建了哪些资源，后续做配置定制也会更加方便直观！

### 在集群内使用vLLM部署模型服务

模型和vLLM的关系相当于jar包和JVM的关系。

#### 创建模型存储PVC

我们的模型是下载存储到集群pvc上的，这样每次pod重启就不会重新下载了。

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: vllm-model-cache
  namespace: k8sgpt-operator-system
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
  # 明确告诉 K8s，我们就用 cbs 这个存储类
  storageClassName: "cbs"
```

#### 使用vLLM部署模型

以下yaml在集群里应用就可以，因为集群是纯CPU的，所以vLLM引擎和模型加载都会非常慢，大约十分钟左右模型才会启动成功，看到`(APIServer pid=66) INFO:     10.198.3.155:40456 - "GET /health HTTP/1.1" 200 OK`日志打印就是启动成功。

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm
  namespace: k8sgpt-operator-system
spec:
  replicas: 1
  strategy:
    type: Recreate   # <--- 加上这一行，保证pvc使用顺序。类似先拔 U 盘，再插 U 盘
  selector:
    matchLabels:
      app: vllm
  template:
    metadata:
      labels:
        app: vllm
    spec:
      imagePullSecrets:
        - name: "tcr.acp-public"
      containers:
        - name: vllm
          image: k8s-t0.tencentcloudcr.com/k8s/mekayelanik/vllm-cpu:latest
          env:
            - name: VLLM_TARGET_DEVICE
              value: "cpu"
            # 【核心1】配置 HuggingFace 国内镜像加速下载
            - name: HF_ENDPOINT
              value: "https://hf-mirror.com"
            # ===== 新增下面这两行，严格限制缓存，防止内存撑爆 =====
            - name: VLLM_CPU_KVCACHE_SPACE
              value: "2"
            # 【新增】强制禁用自动 NUMA 绑核，防止与 K8s CPU 限制发生死锁
            - name: VLLM_CPU_OMP_THREADS_BIND
              value: "all"
            # ===== 新增下面这两项，极其关键 =====
            # 1. 禁用激进且经常在 CPU 上报错的 vLLM V1 新引擎，退回稳定版
            - name: VLLM_USE_V1
              value: "0"
            # 2. 全局禁用 PyTorch 的动态 C++ 编译，纯按 Python 原生逻辑跑
            - name: TORCH_COMPILE_DISABLE
              value: "1"
          args:
            - "--host"
            - "0.0.0.0"
            - "--port"
            - "8000"
            - "--model"
            - "Qwen/Qwen2.5-3B-Instruct"
            - "--max-model-len"
            - "4096"
            - "--trust-remote-code"
            - "--max-num-seqs"
            - "1"
            # 【修改】放弃 bfloat16，改用 float16，避免旧 CPU 软件模拟导致卡死
            - "--dtype"
            - "float16"
            # 【新增】强制使用动态图模式，跳过 CPU 上极易失败的 JIT 图编译阶段
            - "--enforce-eager"
          resources:
            requests:
              cpu: "1"
              memory: "4Gi"
            limits:
              cpu: "8"
              memory: "24Gi"
          # 【新增】启动探针：专门为下载和加载模型预留充足的时间 (最长允许 30 * 20s = 10分钟)
          startupProbe:
            httpGet:
              path: /health
              port: 8000
            failureThreshold: 120
            periodSeconds: 20

          # 【优化】就绪探针：启动探针通过后接管，用于常规的流量分发检查
          readinessProbe:
            httpGet:
              path: /health
              port: 8000
            periodSeconds: 10
            failureThreshold: 3
          ports:
            - containerPort: 8000
          # 【核心2】将缓存目录映射到 Pod 内
          volumeMounts:
            - name: model-cache
              mountPath: /root/.cache/huggingface
      volumes:
        # 【核心3】声明使用刚刚创建的 PVC
        - name: model-cache
          persistentVolumeClaim:
            claimName: vllm-model-cache
```

#### 创建模型service，提供访问入口

```
apiVersion: v1
kind: Service
metadata:
  name: vllm-service
  namespace: k8sgpt-operator-system
spec:
  type: ClusterIP
  selector:
    # 这里必须和 Deployment 中的 labels 一模一样
    app: vllm
  ports:
    - protocol: TCP
      port: 8000        # k8sgpt 访问 Service 的端口
      targetPort: 8000  # 转发给 vLLM 容器的真实端口
```

#### 创建k8sGPT配置

```
apiVersion: core.k8sgpt.ai/v1alpha1
kind: K8sGPT
metadata:
  name: k8sgpt-qwen
  namespace: k8sgpt-operator-system
spec:
  # 假设你之前腾讯云仓库里也有 k8sgpt 这个镜像
  repository: "k8s-t0.tencentcloudcr.com/k8s/k8sgpt-ai/k8sgpt"
  version: "latest" # 请替换为你镜像库里实际存在的 k8sgpt 版本号
  ai:
    enabled: true
    # 模型名称，必须和你 curl 请求里写的一模一样
    model: "Qwen/Qwen2.5-3B-Instruct"
    # 后端类型，使用 openai 兼容模式
    backend: "openai"
    # 填入第一步创建的 Service 的 K8s 内部 DNS 地址
    baseUrl: "http://vllm-service.k8sgpt-operator-system.svc.cluster.local:8000/v1"
    secret:
      name: k8sgpt-vllm-secret
      key: openai-api-key
    language: "chinese"
  noCache: false
  # 指定你要分析的资源类型
  filters:
    - Pod
    - Deployment
    - Service
    - Ingress
    - PersistentVolumeClaim
```

### 使用效果

模型创建成功并应用k8sGPT配置之后，Operator就会自动启动进行巡检，把诊断结果放到k8s集群CRD中的Result中去，可以直接去里面查看。`kubectl get results -A`

![img](https://image.hyly.net/i/2026/04/17/e5a35f4e472035ecd10175bc33b291d3-0.webp)

可以看到里面AI诊断发现的错误原因以及相应的解决办法，这里应用的是小模型，诊断结果可能没有那么详细，但是AI发现的错误还是很准确的，可以直接根据错误原因去集群里查看事故源头，作为一个辅助运维手段。

![img](https://image.hyly.net/i/2026/04/17/8cb199001768971990f20c9ef3c449dd-0.webp)

## 进阶使用

### 接入 Grafana 进行可视化展示 (监控大盘)

K8sGPT Operator 在设计之初就完全贴合了 Prometheus 生态，它会自动暴露集群诊断指标。

**实现路径：** 

1. K8sGPT Operator 的 Controller 会暴露出 `/metrics` 接口（通常在 8080 端口）。
2. 你需要创建一个 `ServiceMonitor`，让集群里的 Prometheus 去抓取 K8sGPT 的指标。
3. 抓取到的核心指标通常是 `k8sgpt_result_issues` 或 `k8sgpt_number_of_results`，它会带有 `namespace`、`kind`、`name` 等标签。
4. 在 Grafana 中，你可以直接导入 K8sGPT 的社区 Dashboard（例如 Dashboard ID: `18600` 或从 K8sGPT 官方 GitHub 获取最新模板），从而直观地看到集群健康度趋势、哪个命名空间问题最多等。

### 发送钉钉群告警 (事件通知)

K8sGPT Operator 原生支持配置 **Sinks**（数据接收端），你可以通过它或者结合现有的监控体系来发送告警。

- **方案 A：通过 Prometheus + Alertmanager (最推荐)**基于第一步的 Grafana 接入，当 Prometheus 发现 K8sGPT 输出了新的 `Result` 指标时，触发 Alertmanager 告警规则。Alertmanager 可以直接配置 `webhook_configs`，推送到开源的“钉钉告警插件”（如 `prometheus-webhook-dingtalk`），从而将 AI 的诊断内容推送到钉钉群。
- **方案 B：使用 K8sGPT 原生 Webhook Sink**K8sGPT Operator 提供了一个 `Result` 转发机制，支持发送到 Slack、Mattermost 以及通用的 Webhook。你可以写一个极简的中间件（比如几十行代码的 Python/Go 服务），接收 K8sGPT 的 Webhook JSON，然后将其转化为钉钉机器人支持的 Markdown 格式发到群里。

### AI 直接修改配置文件生效 (自愈 / Auto-Remediation)

这是 K8sGPT 非常前沿的功能。刚才查看 `Result` 资源的 YAML 时，可能注意到了里面有一个空字段 `autoRemediationStatus: {}`，这就为自动修复预留了接口。

- **实现原理：** K8sGPT Operator 确实支持读取 AI 给出的修复建议，并尝试直接应用到集群中。
- **⚠️** **强烈建议与风险提示：千万不要在使用本地 3B 小模型时开启自动修复！** 大模型（尤其是 3B 参数级别的模型）在生成具体执行命令时，存在不可忽视的“幻觉（Hallucination）”概率。它可能会因为理解偏差，生成错误的删除或修改命令，直接导致生产业务瘫痪。即使是 OpenAI 的 GPT-4，在生产环境中开启全自动修复也是一件极具风险的事情。
- **最佳实践：** 采用**“Human-in-the-loop (人工确认)”**模式。让 AI 将发现的问题和修改建议发送到钉钉群，并在钉钉卡片上附带一个“审批通过执行”的按钮（结合自动化运维平台），由有经验的运维工程师扫一眼确认无误后，再点击执行。

**重要提醒！！！**

**k8sGPT是可以做到AI自动诊断并直接应用的，但是鉴于使用的是小模型，所以这个步骤还是要慎重！慎重！再慎重，这里只做理论演示，实际使用过程中建议还是k8sGPT加大模型进行诊断，测试环境稳定运行之后再小规模上生产！！！**

K8sGPT 的自动修复（Auto-Remediation）的底层逻辑是：Operator 获取 AI 的诊断结果 -> 让 AI 生成一段修复补丁 (Patch) -> Operator 创建一个名为 `Mutation` 的自定义资源来追踪进度 -> 将补丁应用到故障资源上。

#### 在 K8sGPT 配置中开启自动修复

找到之前的k8sGPT配置文件，显式地开启 Auto-Remediation 功能，并为了安全起见，限制它只能修改特定的资源（比如只能改 Pod 和 Service）。

在 PowerShell 中执行 `kubectl edit k8sgpt k8sgpt-qwen -n k8sgpt-operator-system`，然后在 `spec.ai` 层级下增加 `autoRemediation` 配置：

```
apiVersion: core.k8sgpt.ai/v1alpha1
kind: K8sGPT
metadata:
  name: k8sgpt-qwen
  namespace: k8sgpt-operator-system
spec:
  ai:
    backend: openai
    model: Qwen/Qwen2.5-3B-Instruct
    language: "chinese"
    # ===== 新增自动修复配置 =====
    autoRemediation:
      enabled: true
      resources:
        - Pod
        - Service
```

保存并退出，Operator 会自动重载配置。

#### 清理旧数据，制造一个“新案发现场”

为了让流程清晰，我们先清空现有的分析结果，然后手动部署一个有问题的 Nginx，看看 AI 能不能把它救活。

1. 清理历史记录：

```
kubectl delete results --all -n k8sgpt-operator-system
kubectl delete mutations --all -n k8sgpt-operator-system
```

2. 制造一个简单的故障：

比如，故意写错一个镜像名称（把 `nginx` 写成 `nginx-not-exist`），或者故意把容器端口写错。

```
# 创建一个必定会 ImagePullBackOff 的 Pod
kubectl run test-auto-fix --image=nginx-error-tag-123 --port=80
```

#### 观察 AI 的“自愈”过程

接下来就是见证奇迹（或者大型翻车）的时刻了。K8sGPT Operator 会按照设定的轮询时间（默认 30 秒）去扫描集群。

你可以开启两个 PowerShell 窗口实时观察：

**窗口 A：观察 Result 的生成**

```
kubectl get results -w -A
```

当出现关于 `test-auto-fix` 的 Result 时，说明模型已经发现了问题并给出了建议。

**窗口 B：观察 Mutation 的执行 (核心环节)**

K8sGPT 在开启自动修复后，会生成一个叫做 `Mutation` 的 CRD 来执行修复动作。

```
kubectl get mutations -w -A
```

你可以通过查看 Mutation 的详细信息，来看看 AI 到底打算执行什么操作：

```
# 假设生成的 mutation 名字叫 test-auto-fix-mutation
kubectl get mutation test-auto-fix-mutation -n k8sgpt-operator-system -o yaml
```

####  实验预期与现实预警（坎坷之路）

作为流程验证，你需要提前对 **3B 级别小模型** 的表现做好心理准备：

1. **JSON/YAML 格式幻觉：** 自动修复功能极其依赖 AI 输出**格式极其严格的 JSON Patch 或 YAML Patch**。3B 小模型虽然能用中文告诉你“去修改镜像名字”，但当 Operator 要求它输出标准 Patch 机器码时，它大概率会输出带有 Markdown 标记、废话或者格式错乱的内容，导致 Operator 无法解析，最终 Mutation 状态会显示 `Failed`。
2. **能力边界：** K8sGPT 目前的自动修复主要针对 `Service` 和 `Pod`。如果是 Deployment 级别的故障（比如你之前遇到的 `exitCode=137` OOMKilled），直接改被 Deployment 管理的 Pod 是没用的（K8s 会用旧模板再拉起一个新的）。

如果成功了，你将亲眼看到那个一直在 `ImagePullBackOff` 的 Pod 突然自己变成了 `Running`；如果失败了，去查看 `Mutation` 资源的 yaml，看看里面的 `error` 字段，你就能直观地感受到“小模型在严格格式化输出时的局限性”，这也是为什么工业级自愈通常需要 70B 以上模型或强力 Fine-tuning 的原因。

## 小结

折腾到这里，恭喜你，你的 K8s 集群已经成功跨入了“自带 AI 随诊医生”的 Next Level！

我们回顾一下今天的战果：从最轻量级的本地命令行诊断起步，一路打通了 Operator 模式的自动化巡检，甚至还硬核地在纯 CPU 节点上，利用 vLLM 成功拉起了本地的 Qwen 模型服务。如果你再花点心思接入 Grafana 监控大盘和钉钉/飞书告警，一套高度现代化的“智能运维闭环”就已经在你的手里诞生了。

不过，作为踩过坑的过来人，最后还是要苦口婆心地敲一下黑板：**AI 辅助排障天下无敌，但 AI 自动修复请保持敬畏！** 尤其是在文中演示的 **自动修复（Auto-Remediation）** 环节，当我们在使用 3B 这种参数量级的轻量模型时，千万要管住自己想要在生产环境点亮它的手！小模型在生成极其严苛的 JSON/YAML Patch 机器码时，往往带着天马行空的“幻觉”，直接放进生产环境无异于在集群里蒙眼狂奔。

现阶段真正稳妥的落地姿势，依然是 **“AI 诊断推荐 + 人工审批执行”**（Human-in-the-loop）。让 AI 帮我们干掉 90% 查日志、找 Root Cause、翻 Stack Overflow 的脏活累活，把最后 10% 拍板敲定回车键的权力留给咱们自己。

运维的终极目标固然是喝茶摸鱼，但在彻底喝上茶之前，咱们还是得稳扎稳打。先在测试环境愉快地调教你的专属 AI 助理吧，祝你的集群永远 `Running`，再无 `OOMKilled`！