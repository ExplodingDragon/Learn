# RookNFS 部署文档

## 概要

NFS(Network File System)即网络文件系统, 是FreeBSD支持的文件系统中的一种。NFS是基于RPC(Remote Procedure Call)远程过程调用实现，其允许一个系统在网络上与它人共享目录和文件。通过使用NFS，用户和程序就可以像访问本地文件一样访问远端系统上的文件。NFS是一个非常稳定的，可移植的网络文件系统。具备可扩展和高性能等特性，达到了企业级应用质量标准。由于网络速度的增加和延迟的降低，NFS系统一直是通过网络提供文件系统服务的有竞争力的选择。

### NFS 使用方式

1. 已有NFS集群,例如公司QCE 申请的NFS集群, 在kubernetes中创建`PVC`和`StorageClass` ,一般通过 [Kubernetes NFS Subdir External Provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner) 创建动态的`provisioner`,然后就可以在集群中使用NFS服务了;
1. 物理机上手动安装NFS集群, 通过linux命令进行安装, 然后可以按照 1 进行使用;
1. 通过kubernetes进行安装, 安装方式有多种 `NFS Provisioner` 以及 `rook` 等, 通过`kubernetes` 管理`nfs` 集群, 然后对外提供服务;

此处主要介绍在 `kubernetes` 中安装 **NFS** 服务并对集群内外提供服务.

## 环境准备

### 准备  RookNFS 依赖

```bash
 git clone --single-branch --branch v1.7.3 https://github.com/rook/nfs.git
```

如果是离线环境请自行导入 `rook/nfs:v1.7.3`镜像并修改 `/cluster/examples/kubernetes/nfs/operator.yaml` 文件，将 `image: rook/nfs:v1.7.3`修改为自定义地址。

### 安装 NFS Client

每一台`kubernetes`节点都需要安装 NFS 客户端，CentOS 可使用 `yum install nfs-utils -y` 安装。

## RookNFS 安装

### 主要步骤

1. 创建Local Persistent Volume;
1. 创建StorageClass;
1. 创建PVC, 关联 Step2 中的StorageClass;
1. 部署NFS Operator;
1. 创建NFS Server;
1. 创建NFS Storage Class;
1. 创建 Pod 并使用NFS;
1. 让集群外部服务也可以访问NFS Server;

### 部署NFS Operator

注意，安装 rook 之前需要先安装 NFS Client 。

```bash
git clone --single-branch --branch v1.7.3 https://github.com/rook/nfs.git
cd rook/cluster/examples/kubernetes/nfs
kubectl create -f crds.yaml
kubectl create -f operator.yaml
kubectl create -f rbac.yaml
```

检查operator 是否运行正常:

```bash
kubectl -n rook-nfs-system get pod
```

### 创建 Local Persistent Volume

首先在集群的宿主机创建挂载点,例如本次使用的是 `/share`

接下来,定义 `PersistentVolume`, 如下所示:

```yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-local-pv
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 100Gi
  local:
    path: /share
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - k8s-01
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage
  volumeMode: Filesystem
```

- `local` 字段指定了它是一个 Local Persistent Volume，
-  `path` 字段指定的正是这个 PV 对应的本地磁盘的路径，即 `/share`
- `matchExpressions > values `字段表示指定此 PV 位于 `k8s-01`节点上

接下来, 我们使用 `kubectl create` 来创建这个PV:

```bash
kubectl apply -f nfs-local-pv.yml
kubectl get pv 
```

### 创建 StorageClass

通过StorageClass 描述 PV, 如下所示:

```yml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

这里有两个重要的字段:

- `provisioner`: 我们使用`no-provisioner`, 这是因为 Local Persistent Volume 目前尚不支持Dynamic Provisioning,所以它没办法在用户创建 PVC 的时候,就自动创建出对应的PV。 

- `volumeBindingMode: WaitForFirstConsumer`, 指定了延迟绑定.因为Local Persistent 需要等到调度时才可以进行绑定操作。

通过 `kubectl create` 来创建 StorageClass, 如下所示:

```bash
kubectl create -f sc.yml
kubectl get sc
```

### 创建 PersistentVolumeClaim

```yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-local-claim
  namespace: rook-nfs
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
  storageClassName: local-storage
  volumeMode: Filesystem
  volumeName: nfs-local-pv
```

接下来创建这个`PersistentVolumeClaim`：

```bash
kubectl create -f local-claim.yml
kubectl get pvc -n rook-nfs
```

### 创建NFS Server

我们可以通过创建 `nfsservers.nfs.rook.io` 资源的实例来创建NFS服务器的实例，接下来 将以下内容保存到`nfs.yaml`:

```yml
apiVersion: nfs.rook.io/v1alpha1
kind: NFSServer
metadata:
  name: rook-nfs
  namespace: rook-nfs
spec:
  replicas: 1
  exports:
    - name: local-share-1
      server:
        accessMode: ReadWrite
        squash: "all"
      # A Persistent Volume Claim must be created before creating NFS CRD instance.
      persistentVolumeClaim:
        claimName: nfs-local-claim
        #claimName: nfs-default-claim
  # A key/value list of annotations
  annotations:
    rook: nfs
```

然后通过`kubectl create` 创建 NFS 服务器:

```bash
kubectl create -f nfs.yml
```

验证 nfs server 是否运行正常:

```bash
 kubectl get pod -n rook-nfs
```

###  创建NFS Storage Class

部署 Operator 和 NFS Server 实例之后,. 必须创建 `StrorageClass` 来动态配置 `Volume`:

```yml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  labels:
    app: rook-nfs
  name: rook-nfs-share-1
parameters:
  exportName: local-share-1
  nfsServerName: rook-nfs
  nfsServerNamespace: rook-nfs
provisioner: nfs.rook.io/rook-nfs-provisioner
reclaimPolicy: Delete
volumeBindingMode: Immediate
```

通过 `kubectl create` 创建:

```bash
kubectl create -f nsc.yml
```

这里 `StorageClass` 需要传递以下三个参数:

1. `exportName`: 告诉`provisioner` 使用哪个 `export`;
1. `nfsServerName`: **NFS Server** 实例名字;
1. `nfsServerNamespace`：**NFS Server**实例运行的命名空间;

`StorageClass`创建之后, 我们接下来就可以创建PVC来引用它:

```bash
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: rook-nfs-pv-claim
spec:
  storageClassName: "rook-nfs-share-1"
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
```

通过`kubectl create` 进行创建:

```bash
kubectl create -f pvc.yml
```

### 测试 Pod 挂载情况

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nfs-demo
    role: web-frontend
  name: nfs-web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nfs-demo
      role: web-frontend
  template:
    metadata:
      labels:
        app: nfs-demo
        role: web-frontend
    spec:
      containers:
        - name: web
          image: nginx:latest
          ports:
            - name: web
              containerPort: 80
          volumeMounts:
            # name must match the volume name below
            - name: rook-nfs-vol
              mountPath: "/usr/share/nginx/html"
      volumes:
        - name: rook-nfs-vol
          persistentVolumeClaim:
            claimName: rook-nfs-pv-claim

```



### 让集群外部服务也可以访问NFS Server

如果外部服务也可以访问**NFS Server** ,则可以通过修改 `rook-nfs` 的 `Service` 类型为`NodePort` 来暴露 NFS 服务:



## 参考

1. [NFS 通过 rook 进行部署](https://www.geekgame.site/post/k8s/storage/rook-nfs/)
