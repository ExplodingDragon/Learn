 

# kubernetes 学习

## kubernetes 概述

### Kubernetes 是什么？

`Kubernetes` 是一个可移植的、可扩展的开源平台，用于管理容器化的工作负载和服务，可促进声明式配置和自动化。 `Kubernetes` 拥有一个庞大且快速增长的生态系统。`Kubernetes` 的服务、支持和工具广泛可用。

### 为什么需要 Kubernetes

容器是打包和运行应用程序的好方式。在生产环境中，你需要管理运行应用程序的容器，并确保不会停机。 例如，如果一个容器发生故障，则需要启动另一个容器。如果系统处理此行为，会不会更容易？

这就是 `Kubernetes` 来解决这些问题的方法！ `Kubernetes` 为你提供了一个可弹性运行分布式系统的框架。 `Kubernetes` 会满足你的扩展要求、故障转移、部署模式等。 

`Kubernetes` 提供：

- 服务发现和负载均衡
- 存储编排
- 自动部署和回滚
- 自动完成装箱计算
- 自我修复
- 密钥与配置管理

> 更多详情请参考 [Kubernetes 是什么](https://kubernetes.io/zh/docs/concepts/overview/what-is-kubernetes/)

### Kubernetes 组件

当你部署完 `Kubernetes`, 即拥有了一个完整的集群。

一个 `Kubernetes` 集群由一组被称作节点的机器组成。这些节点上运行 `Kubernetes` 所管理的容器化应用。集群具有至少一个工作节点。

工作节点托管作为应用负载的组件的 Pod 。控制平面管理集群中的工作节点和 Pod 。 为集群提供故障转移和高可用性，这些控制平面一般跨多主机运行，集群跨多个节点运行。

![Kubernetes 的组件](./.assets/components-of-kubernetes.svg)

`Kubernetes` 集群的组件如下:

#### 控制平面组件（Control Plane Components） 

控制平面的组件对集群做出**全局决策**(比如调度)，以及检测和响应集群事件（例如，当不满足部署的 `replicas` 字段时，启动新的 `pod`）。

控制平面组件可以在集群中的任何节点上运行。 然而，为了简单起见，设置脚本通常会在同一个计算机上启动所有控制平面组件， 并且不会在此计算机上运行用户容器。

##### kube-apiserver 

API 服务器是 `Kubernetes` 控制面的组件， 该组件**公开了 Kubernetes API**。 API 服务器是 `Kubernetes` 控制面的前端。

**Kubernetes API** 服务器的主要实现是 `kube-apiserver`。 `kube-apiserver` 设计上考虑了水平伸缩，也就是说，它可通过部署多个实例进行伸缩。 你可以运行 `kube-apiserver` 的多个实例，并在这些实例之间平衡流量。

##### etcd

`etcd` 是兼具一致性和高可用性的键值数据库，可以作为保存 `Kubernetes` 所有集群数据的后台数据库。

**您的 Kubernetes 集群的 etcd 数据库通常需要有个备份计划。**

##### kube-scheduler 

控制平面组件，负责监视新创建的、未指定运行节点（node）的 Pods，选择节点让 Pod 在上面运行。

调度决策考虑的因素包括单个 Pod 和 Pod 集合的资源需求、硬件/软件/策略约束、亲和性和反亲和性规范、数据位置、工作负载间的干扰和最后时限。

##### kube-controller-manager 

运行控制器进程的控制平面组件。

从逻辑上讲，每个控制器都是一个单独的进程， 但是为了降低复杂性，它们都被编译到同一个可执行文件，并在一个进程中运行。

这些控制器包括:

- 节点控制器（Node Controller）: 负责在节点出现故障时进行通知和响应
- 任务控制器（Job controller）: 监测代表一次性任务的 Job 对象，然后创建 Pods 来运行这些任务直至完成
- 端点控制器（Endpoints Controller）: 填充端点(Endpoints)对象(即加入 Service 与 Pod)
- 服务帐户和令牌控制器（Service Account & Token Controllers）: 为新的命名空间创建默认帐户和 API 访问令牌

##### cloud-controller-manager

云控制器管理器是指嵌入特定云的控制逻辑的 控制平面组件。 云控制器管理器使得你可以将你的集群连接到云提供商的 API 之上， 并将与该云平台交互的组件同与你的集群交互的组件分离开来。

[cloud-controller-manager](#cloud-controller-manager) 仅运行特定于云平台的控制回路。 如果你在自己的环境中运行 `Kubernetes`，或者在本地计算机中运行学习环境， 所部署的环境中**不需要云控制器管理器**。

与 `kube-controller-manager` 类似，`cloud-controller-manager` 将若干逻辑上独立的 控制回路组合到同一个可执行文件中，供你以同一进程的方式运行。 你可以对其执行水平扩容（运行不止一个副本）以提升性能或者增强容错能力。

下面的控制器都包含对云平台驱动的依赖：

- 节点控制器（Node Controller）: 用于在节点终止响应后检查云提供商以确定节点是否已被删除
- 路由控制器（Route Controller）: 用于在底层云基础架构中设置路由
- 服务控制器（Service Controller）: 用于创建、更新和删除云提供商负载均衡器

#### Node 组件 

节点组件在每个节点上运行，维护运行的 `Pod` 并提供 `Kubernetes` 运行环境。

##### kubelet

一个在集群中每个**节点（node）**上运行的代理。 它**保证容器（containers）都 运行在 Pod** 中。

`kubelet` 接收一组通过各类机制提供给它的 **PodSpecs**，确保这些 **PodSpecs** 中描述的容器处于运行状态且健康。 `kubelet` **不会管理不是由 Kubernetes 创建**的容器。

##### kube-proxy 

`kube-proxy` 是集群中每个节点上运行的网络代理， 实现 **Kubernetes 服务（Service）** 概念的一部分。

`kube-proxy` 维护节点上的网络规则。这些网络规则允许从集群内部或外部的网络会话与 `Pod` 进行网络通信。

如果操作系统提供了数据包过滤层并可用的话，`kube-proxy` 会通过它来实现网络规则。否则， `kube-proxy` 仅转发流量本身。

##### 容器运行时（Container Runtime） 

容器运行环境是负责运行容器的软件。

`Kubernetes` 支持多个容器运行环境: **Docker**、 **containerd**、**CRI-O** 以及**任何实现 Kubernetes CRI** (容器运行环境接口)。

#### 插件（Addons） 

插件使用 `Kubernetes` 资源（`DaemonSet`、 `Deployment`等）实现集群功能。 因为这些插件提供集群级别的功能，插件中命名空间域的资源属于 `kube-system` 命名空间。

##### DNS 
尽管其他插件都并非严格意义上的必需组件，但几乎所有 `Kubernetes` 集群都应该 有集群 DNS， 因为很多示例都需要 DNS 服务。

集群 DNS 是一个 DNS 服务器，和环境中的其他 DNS 服务器一起工作，它为 `Kubernetes` 服务提供 DNS 记录。

`Kubernetes` 启动的容器自动将此 DNS 服务器包含在其 DNS 搜索列表中。

##### Web 界面（仪表盘） 

`Dashboard` 是 `Kubernetes` 集群的通用的、基于 Web 的用户界面。 它使用户可以管理集群中运行的应用程序以及集群本身并进行故障排除。

##### 容器资源监控

容器资源监控 将关于容器的一些常见的时间序列度量值保存到一个集中的数据库中，并提供用于浏览这些数据的界面。

##### 集群层面日志
集群层面日志 机制负责将容器的日志数据 保存到一个集中的日志存储中，该存储能够提供搜索和浏览接口。

### Kubernetes API

Kubernetes 控制面的核心是 **API 服务器**。 API 服务器负责提供 `HTTP API`，以供用户、集群中的不同部分和集群外部组件相互通信。

Kubernetes API 使你可以查询和操纵 Kubernetes API 中对象（例如：`Pod`、`Namespace`、`ConfigMap` 和 `Event`）的状态。

大部分操作都可以通过 `kubectl` 命令行接口或 类似 `kubeadm` 这类命令行工具来执行， 这些工具在背后也是调用 API。不过，你也可以**使用 REST 调用**来访问这些 API。

完整的 API 细节是用 [OpenAPI](https://www.openapis.org/) 来表述的。

Kubernetes API 服务器通过 `/openapi/v2` 末端提供 OpenAPI 规范。 你可以按照下表所给的请求头部，指定响应的格式：

| 头部              | 可选值                                                       | 说明                     |
| ----------------- | ------------------------------------------------------------ | ------------------------ |
| `Accept-Encoding` | `gzip`                                                       | *不指定此头部也是可以的* |
| `Accept`          | `application/com.github.proto-openapi.spec.v2@v1.0+protobuf` | *主要用于集群内部*       |
| `-`               | `application/json`                                           | *默认值*                 |
| `-`               | `*`                                                          | *提供*`application/json` |

**API 变更** 

任何成功的系统都要随着新的使用案例的出现和现有案例的变化来成长和变化。 为此，Kubernetes 的功能特性设计考虑了让 Kubernetes API 能够持续变更和成长的因素。 Kubernetes 项目的目标是 *不要* 引发现有客户端的兼容性问题，并在一定的时期内 维持这种兼容性，以便其他项目有机会作出适应性变更。

一般而言，新的 API 资源和新的资源字段可以被频繁地添加进来。 删除资源或者字段则要遵从[API 废弃策略](#API 废弃策略)。

**API 组和版本** 

为了简化删除字段或者重构资源表示等工作，Kubernetes 支持多个 API 版本， 每一个版本都在不同 API 路径下，例如 `/api/v1` 或 `/apis/rbac.authorization.k8s.io/v1alpha1`。

版本化是在 API 级别而不是在资源或字段级别进行的，目的是为了确保 API 为系统资源和行为提供清晰、一致的视图，并能够控制对已废止的和/或实验性 API 的访问。

为了便于演化和扩展其 API，Kubernetes 实现了 可被启用或禁用的 API 组。

API 资源之间靠 API 组、资源类型、名字空间（对于名字空间作用域的资源而言）和 名字来相互区分。API 服务器可能通过多个 API 版本来向外提供相同的下层数据， 并透明地完成不同 API 版本之间的转换。所有这些不同的版本实际上都是同一资源 的（不同）表现形式。例如，假定同一资源有 `v1` 和 `v1beta1` 版本， 使用 `v1beta1` 创建的对象则可以使用 `v1beta1` 或者 `v1` 版本来读取、更改 或者删除。

**API 扩展** 

有两种途径来扩展 Kubernetes API：

1. 你可以使用[自定义资源](#自定义资源) 来以声明式方式定义 API 服务器如何提供你所选择的资源 API。
2. 你也可以选择实现自己的 [聚合层](#聚合层) 来扩展 Kubernetes API。

### 使用 Kubernetes 对象

#### 理解 Kubernetes 对象

在 Kubernetes 系统中，*Kubernetes 对象* 是持久化的实体。 Kubernetes 使用这些实体去表示整个集群的状态。特别地，它们描述了如下信息：

- 哪些容器化应用在运行（以及在哪些节点上）
- 可以被应用使用的资源
- 关于应用运行时表现的策略，比如重启策略、升级策略，以及容错策略

Kubernetes 对象是 “目标性记录” —— 一旦创建对象，Kubernetes 系统将持续工作以确保对象存在。 通过创建对象，本质上是在告知 Kubernetes 系统，所需要的集群工作负载看起来是什么样子的， 这就是 Kubernetes 集群的 **期望状态（Desired State）**。

操作 Kubernetes 对象 —— 无论是创建、修改，或者删除 —— 需要使用 [Kubernetes API](#Kubernetes API)。 比如，当使用 `kubectl` 命令行接口时，CLI 会执行必要的 Kubernetes API 调用， 也可以在程序中使用 [客户端库](https://kubernetes.io/zh/docs/reference/using-api/client-libraries/)直接调用 Kubernetes API。

**对象规约（Spec）与状态（Status）** 

几乎每个 Kubernetes 对象包含两个嵌套的对象字段，它们负责管理对象的配置： 对象 *`spec`（规约）* 和 对象 *`status`（状态）* 。 对于具有 `spec` 的对象，你必须在创建对象时设置其内容，描述你希望对象所具有的特征： ***期望状态（Desired State）*** 。

`status` 描述了对象的 ***当前状态（Current State）***，它是由 Kubernetes 系统和组件 设置并更新的。在任何时刻，Kubernetes 控制平面都一直积极地管理着对象的实际状态，以使之与期望状态相匹配。

例如，Kubernetes 中的 Deployment 对象能够表示运行在集群中的应用。 当创建 Deployment 时，可能需要设置 Deployment 的 `spec`，以指定该应用需要有 3 个副本运行。 Kubernetes 系统读取 Deployment 规约，并启动我们所期望的应用的 3 个实例 —— 更新状态以与规约相匹配。 如果这些实例中有的失败了（一种状态变更），Kubernetes 系统通过执行修正操作 来响应规约和状态间的不一致 —— 在这里意味着它会启动一个新的实例来替换。

**描述 Kubernetes 对象**

创建 Kubernetes 对象时，必须提供对象的规约，用来描述该对象的期望状态， 以及关于对象的一些基本信息（例如名称）。 当使用 Kubernetes API 创建对象时（或者直接创建，或者基于`kubectl`）， API 请求必须在请求体中包含 JSON 格式的信息。 **大多数情况下，需要在 .yaml 文件中为 `kubectl` 提供这些信息**。 `kubectl` 在发起 API 请求时，将这些信息转换成 JSON 格式。

这里有一个 `.yaml` 示例文件，展示了 Kubernetes Deployment 的必需字段和对象规约：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2 # 告诉 deployment  通过模板运行2个的POD
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

使用类似于上面的 `.yaml` 文件来创建 Deployment的一种方式是使用 `kubectl` 命令行接口（CLI）中的 [`kubectl apply`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply) 命令， 将 `.yaml` 文件作为参数。下面是一个示例：

```shell
kubectl apply -f https://k8s.io/examples/application/deployment.yaml --record
```

**必需字段** 

在想要创建的 Kubernetes 对象对应的 `.yaml` 文件中，需要配置如下的字段：

- `apiVersion` - 创建该对象所使用的 Kubernetes API 的版本
- `kind` - 想要创建的对象的类别
- `metadata` - 帮助唯一性标识对象的一些数据，包括一个 `name` 字符串、UID 和可选的 `namespace`
- `spec` - 你所期望的该对象的状态

对象 `spec` 的精确格式对每个 Kubernetes 对象来说是不同的，包含了特定于该对象的嵌套字段。 [Kubernetes API 参考](https://kubernetes.io/docs/reference/kubernetes-api/) 能够帮助我们找到任何我们想创建的对象的规约格式。

#### Kubernetes 对象管理

`kubectl` 命令行工具支持多种不同的方式来创建和管理 Kubernetes 对象。 本文档概述了不同的方法。 阅读 [Kubectl book](https://kubectl.docs.kubernetes.io/) 来了解 kubectl 管理对象的详细信息。

> **警告：**
>
> 应该只使用一种技术来管理 Kubernetes 对象。混合和匹配技术作用在同一对象上将导致未定义行为。

|             管理技术              |  作用于  | 建议的环境 | 支持的写者 | 学习难度 |
| :-------------------------------: | :------: | :--------: | :--------: | :------: |
|     [指令式命令](#指令式命令)     | 活跃对象 |  开发项目  |     1+     |   最低   |
| [指令式对象配置](#指令式对象配置) | 单个文件 |  生产项目  |     1      |   中等   |
| [声明式对象配置](#声明式对象配置) | 文件目录 |  生产项目  |     1+     |   最高   |

##### 声明式对象配置

​	使用指令式命令时，用户可以在集群中的活动对象上进行操作。用户将操作传给 `kubectl` 命令作为参数或标志。

这是开始或者在集群中运行一次性任务的推荐方法。因为这个技术直接在活跃对象上操作，所以它不提供以前配置的历史记录。

例如，这是通过创建 Deployment 对象来运行 nginx 容器的实例：

```sh
kubectl create deployment nginx --image nginx
```

**权衡**

与对象配置相比的优点：

- 命令简单，易学且易于记忆。
- 命令仅需一步即可对集群进行更改。

与对象配置相比的缺点：

- 命令不与变更审查流程集成。
- 命令不提供与更改关联的审核跟踪。
- 除了实时内容外，命令不提供记录源。
- 命令不提供用于创建新对象的模板。

##### 指令式对象配置

在指令式对象配置中，kubectl 命令指定操作（创建，替换等），可选标志和 至少一个文件名。指定的文件必须包含 YAML 或 JSON 格式的对象的完整定义。

有关对象定义的详细信息，请查看 [API 参考](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/)。

> **警告：**
>
> `replace` 指令式命令将现有规范替换为新提供的规范，并放弃对配置文件中 缺少的对象的所有更改。此方法不应与对象规约被独立于配置文件进行更新的 资源类型一起使用。比如类型为 `LoadBalancer` 的服务，它的 `externalIPs` 字段就是独立于集群配置进行更新。

创建配置文件中定义的对象：

```sh
kubectl create -f nginx.yaml
```

删除两个配置文件中定义的对象：

```sh
kubectl delete -f nginx.yaml -f redis.yaml
```

通过覆盖活动配置来更新配置文件中定义的对象：

```sh
kubectl replace -f nginx.yaml
```

**权衡**

与指令式命令相比的优点：

- 对象配置可以存储在源控制系统中，比如 Git。
- 对象配置可以与流程集成，例如在推送和审计之前检查更新。
- 对象配置提供了用于创建新对象的模板。

与指令式命令相比的缺点：

- 对象配置需要对对象架构有基本的了解。
- 对象配置需要额外的步骤来编写 YAML 文件。

与声明式对象配置相比的优点：

- 指令式对象配置行为更加简单易懂。
- 从 Kubernetes 1.5 版本开始，指令对象配置更加成熟。

与声明式对象配置相比的缺点：

- 指令式对象配置更适合文件，而非目录。
- 对活动对象的更新必须反映在配置文件中，否则会在下一次替换时丢失。

##### 声明式对象配置

使用声明式对象配置时，用户对本地存储的对象配置文件进行操作，但是用户 未定义要对该文件执行的操作。 `kubectl` 会自动检测每个文件的创建、更新和删除操作。 这使得配置可以在目录上工作，根据目录中配置文件对不同的对象执行不同的操作。

**说明：**

声明式对象配置保留其他编写者所做的修改，即使这些更改并未合并到对象配置文件中。 可以通过使用 `patch` API 操作仅写入观察到的差异，而不是使用 `replace` API 操作来替换整个对象配置来实现。

**例子**

处理 `configs` 目录中的所有对象配置文件，创建并更新活跃对象。 可以首先使用 `diff` 子命令查看将要进行的更改，然后在进行应用：

```sh
kubectl diff -f configs/
kubectl apply -f configs/
```

递归处理目录：

```sh
kubectl diff -R -f configs/
kubectl apply -R -f configs/
```

**权衡**

与指令式对象配置相比的优点：

- 对活动对象所做的更改即使未合并到配置文件中，也会被保留下来。
- 声明性对象配置更好地支持对目录进行操作并自动检测每个文件的操作类型（创建，修补，删除）。

与指令式对象配置相比的缺点：

- 声明式对象配置难于调试并且出现异常时结果难以理解。
- 使用 diff 产生的部分更新会创建复杂的合并和补丁操作。

#### 对象名称和 IDs

集群中的每一个对象都有一个[*名称*](#名称) 来标识在同类资源中的唯一性。

每个 Kubernetes 对象也有一个[*UID*](#UIDs) 来标识在整个集群中的唯一性。

比如，在同一个[名字空间](#名字空间) 中有一个名为 `myapp-1234` 的 Pod, 但是可以命名一个 Pod 和一个 Deployment 同为 `myapp-1234`.

对于用户提供的非唯一性的属性，Kubernetes 提供了 [标签（Labels）](#标签)和 [注解（Annotation）](#注解)机制。

##### 名称 

客户端提供的字符串，引用资源 url 中的对象，如`/api/v1/pods/some name`。

某一时刻，只能有一个给定类型的对象具有给定的名称。但是，如果删除该对象，则可以创建同名的新对象。

> **说明：**
>
> 当对象所代表的是一个物理实体（例如代表一台物理主机的 Node）时， 如果在 Node 对象未被删除并重建的条件下，重新创建了同名的物理主机， 则 Kubernetes 会将新的主机看作是老的主机，这可能会带来某种不一致性。

以下是比较常见的四种资源命名约束。

###### DNS 子域名 

很多资源类型需要可以用作 DNS 子域名的名称。 DNS 子域名的定义可参见 [RFC 1123](https://tools.ietf.org/html/rfc1123)。 这一要求意味着名称必须满足如下规则：

- 不能超过253个字符
- 只能包含小写字母、数字，以及'-' 和 '.'
- 须以字母数字开头
- 须以字母数字结尾

###### RFC 1123 标签名 

某些资源类型需要其名称遵循 [RFC 1123](https://tools.ietf.org/html/rfc1123) 所定义的 DNS 标签标准。也就是命名必须满足如下规则：

- 最多 63 个字符
- 只能包含小写字母、数字，以及 '-'
- 须以字母数字开头
- 须以字母数字结尾

###### RFC 1035 标签名 

某些资源类型需要其名称遵循 [RFC 1035](https://tools.ietf.org/html/rfc1035) 所定义的 DNS 标签标准。也就是命名必须满足如下规则：

- 最多 63 个字符
- 只能包含小写字母、数字，以及 '-'
- 须以字母开头
- 须以字母数字结尾

###### 路径分段名称 

某些资源类型要求名称能被安全地用作路径中的片段。 换句话说，其名称不能是 `.`、`..`，也不可以包含 `/` 或 `%` 这些字符。

下面是一个名为`nginx-demo`的 Pod 的配置清单：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-demo
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80
```

> **说明：** 某些资源类型可能具有额外的命名约束。

##### UIDs

Kubernetes 系统生成的字符串，唯一标识对象。

在 Kubernetes 集群的整个生命周期中创建的每个对象都有一个不同的 uid，它旨在区分类似实体的历史事件。

Kubernetes UIDs 是全局唯一标识符（也叫 UUIDs）。 UUIDs 是标准化的，见 ISO/IEC 9834-8 和 ITU-T X.667.

#### 名字空间

Kubernetes 支持多个虚拟集群，它们底层依赖于同一个物理集群。 这些虚拟集群被称为名字空间。 在一些文档里名字空间也称为命名空间。

##### 何时使用多个名字空间

名字空间适用于存在很多跨多个团队或项目的用户的场景。对于只有几到几十个用户的集群，根本不需要创建或考虑名字空间。当需要名称空间提供的功能时，请开始使用它们。

名字空间为名称提供了一个范围。资源的名称需要在名字空间内是唯一的，但不能跨名字空间。 名字空间不能相互嵌套，每个 Kubernetes 资源只能在一个名字空间中。

名字空间是在多个用户之间划分集群资源的一种方法（通过[资源配额](#资源配额)）。

不必使用多个名字空间来分隔仅仅轻微不同的资源，例如同一软件的不同版本： 应该使用[标签](#标签) 来区分同一名字空间中的不同资源。

##### 使用名字空间

名字空间的创建和删除在[名字空间的管理指南文档](#名字空间的管理指南文档)描述。

> **说明：** 避免使用前缀 `kube-` 创建名字空间，因为它是为 Kubernetes 系统名字空间保留的。

###### 查看名字空间

你可以使用以下命令列出集群中现存的名字空间：

```shell
kubectl get namespace
```

ubernetes 会创建四个初始名字空间：

- `default` 没有指明使用其它名字空间的对象所使用的默认名字空间
- `kube-system` Kubernetes 系统创建对象所使用的名字空间
- `kube-public` 这个名字空间是自动创建的，所有用户（包括未经过身份验证的用户）都可以读取它。 这个名字空间主要用于集群使用，以防某些资源在整个集群中应该是可见和可读的。 这个名字空间的公共方面只是一种约定，而不是要求。
- `kube-node-lease` 此名字空间用于与各个节点相关的 [租约（Lease）](https://kubernetes.io/docs/reference/kubernetes-api/cluster-resources/lease-v1/)对象。 节点租期允许 kubelet 发送[心跳](#心跳)，由此控制面能够检测到节点故障。

###### 为请求设置名字空间

要为当前请求设置名字空间，请使用 `--namespace` 参数。

例如：

```shell
kubectl run nginx --image=nginx --namespace=<名字空间名称>
kubectl get pods --namespace=<名字空间名称>
```

###### 设置名字空间偏好

你可以永久保存名字空间，以用于对应上下文中所有后续 kubectl 命令。

```shell
kubectl config set-context --current --namespace=<名字空间名称>
# 验证之
kubectl config view | grep namespace:
```

###### 名字空间和 DNS

当你创建一个[服务](#服务) 时， Kubernetes 会创建一个相应的 [DNS 条目](#DNS 条目)。

该条目的形式是 `<服务名称>.<名字空间名称>.svc.cluster.local`，这意味着如果容器只使用 `<服务名称>`，它将被解析到本地名字空间的服务。这对于跨多个名字空间（如开发、分级和生产） 使用相同的配置非常有用。如果你希望跨名字空间访问，则需要使用完全限定域名（FQDN）。

###### 并非所有对象都在名字空间中

大多数 kubernetes 资源（例如 Pod、Service、副本控制器等）都位于某些名字空间中。 但是名字空间资源本身并不在名字空间中。而且底层资源，例如 [节点](#节点) 和持久化卷不属于任何名字空间。

查看哪些 Kubernetes 资源在名字空间中，哪些不在名字空间中：

```shell

# 位于名字空间中的资源
kubectl api-resources --namespaced=true

# 不在名字空间中的资源
kubectl api-resources --namespaced=false
```

###### 自动打标签 

**新特性:** `Kubernetes 1.21 [beta]`

Kubernetes 控制面会为所有名字空间设置一个不可变更的 [标签](#标签) `kubernetes.io/metadata.name`，只要 `NamespaceDefaultLabelName` 这一 [特性门控](#特性门控) 被启用。标签的值是名字空间的名称。

##### 标签和选择算符

*标签（Labels）* 是附加到 Kubernetes 对象（比如 Pods）上的键值对。 标签旨在用于指定对用户有意义且相关的对象的标识属性，但不直接对核心系统有语义含义。 标签可以用于组织和选择对象的子集。标签可以在创建时附加到对象，随后可以随时添加和修改。 每个对象都可以定义一组键/值标签。每个键对于给定对象必须是唯一的。

```json
"metadata": {
  "labels": {
    "key1" : "value1",
    "key2" : "value2"
  }
}
```

标签能够支持高效的查询和监听操作，对于用户界面和命令行是很理想的。 应使用[注解](#注解) 记录非识别信息。
