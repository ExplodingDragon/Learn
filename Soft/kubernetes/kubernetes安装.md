# Kubernetes 安装文档

> 此部署文档基于 `kubeadm` 和 `CentOS 7.x`，集群采用 `3 master` + `1 nodes` 模式

## 安装准备

### 配置代理 （可选）

如果你服务器没有网络，则需要配置代理后才能安装。安装好 HTTP 代理服务器后配置如下环境变量：

```bash
# http://<IP>:<PORT>
export http_proxy=http://172.16.63.188:8889
export https_proxy=http://172.16.63.188:8889
```

### 修改系统配置 

 确保每个节点上 `MAC` 地址和 `product_uuid` 的唯一性

- 你可以使用命令 `ip link` 或 `ifconfig -a` 来获取网络接口的 MAC 地址
- 可以使用 `sudo cat /sys/class/dmi/id/product_uuid` 命令对 product_uuid 校验

如果你的系统`hostname`为默认的 `localhost`,请为其重命名为一个，确保每个节点的`hostname` 不相同。一般来讲，硬件设备会拥有唯一的地址，但是有些虚拟机的地址可能会重复。 Kubernetes 使用这些值来唯一确定集群中的节点。 如果这些值在每个节点上不唯一，可能会导致安装失败。

### 关闭SELinux

SELinux 可能导致安装问题，需要预先关闭

```bash
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```

### 允许 iptables 检查桥接流量

确保 `br_netfilter` 模块被加载。这一操作可以通过运行 `lsmod | grep br_netfilter` 来完成。若要显式加载该模块，可执行 `sudo modprobe br_netfilter`。

为了让你的 Linux 节点上的 iptables 能够正确地查看桥接流量，你需要确保在你的 `sysctl` 配置中将 `net.bridge.bridge-nf-call-iptables` 设置为 1。例如：

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```

### 移除交换分区

为了保证 `kubelet` 正常工作，你 **必须** 禁用交换分区。

```bash
SWAP_PATH=$(cat /etc/fstab | grep " swap " | grep '^[^#]'  | awk '{print $1}')
echo current swap path: $SWAP_PATH
sed -i "s@$SWAP_PATH@# $SWAP_PATH@g" /etc/fstab
swapoff $SWAP_PATH
```

 ### 导入安装源

#### Containerd

Docker 源地址下附带了Containerd，所以我们直接使用 Docker 中的 Containerd.

```bash
yum install -y yum-utils
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sed -i "s/download.docker.com/mirrors.ustc.edu.cn\/docker-ce/g" /etc/yum.repos.d/docker-ce.repo 
```

#### Kubeadm

```bash
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.ustc.edu.cn/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.ustc.edu.cn/kubernetes/kubernetes/yum/doc/yum-key.gpg
       https://mirrors.ustc.edu.cn/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```

## 安装

### 安装 Containerd 

kubernetes 需要一个容器运行时，你可以选择任何支持 `CRI`接口的运行时容器上下文，本教程使用 `Containerd `

```bash
sudo yum install -y containerd
sudo systemctl enable --now containerd
```

#### 配置 Containerd 代理 (可选)

如果服务器在内网无法拉取镜像的话可配置 HTTP 代理。

```bash
mkdir /etc/systemd/system/containerd.service.d/
cat > /etc/systemd/system/containerd.service.d/http-proxy.conf << EOF
[Service]
Environment="HTTP_PROXY=$http_proxy"
Environment="HTTPS_PROXY=$http_proxy"
Environment="NO_PROXY=localhost,127.0.0.1,harbor.powersi.com,.powersi.com"
EOF
systemctl daemon-reload
systemctl restart docker
```

#### 配置自定义镜像站点 （可选）

编辑 `/etc/containerd/config.toml` 文件，可自定义地址的镜像站点

```toml
 version = 2
 [plugins."io.containerd.grpc.v1.cri"]
   [plugins."io.containerd.grpc.v1.cri".registry]
     [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
       [plugins."io.containerd.grpc.v1.cri".registry.mirrors."harbor.powersi.com"]
         endpoint = ["https://harbor.pcloud.com"]
         # 
     [plugins."io.containerd.grpc.v1.cri".registry.configs]
       [plugins."io.containerd.grpc.v1.cri".registry.configs."harbor.powersi.com".tls]
         insecure_skip_verify = true
         ca_file = "/etc/containerd/ca.crt"
         # 指定自定义证书的 CA
       [plugins."io.containerd.grpc.v1.cri".registry.configs."harbor.powersi.com".auth]
         username = "admin"
         password = "admin"
         # 指定自定义地址的注册账户

```



### 安装 kubernetes 部署组件

```bash
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet
```

### 安装高可用组件

高可用组件采用`keepalived` 和 `haproxy` 组合，需要将 `VIP` 绑定到某个物理网卡

```bash
# ip 绑定的网卡
export ha_eth=ens192
# master 1 的ip
export ha_m_ip_1=172.18.40.171
# master 2 的ip
export ha_m_ip_2=172.18.40.172
# master 3 的ip
export ha_m_ip_3=172.18.40.174
# VIP
export ha_m_vip=172.18.40.219
# 转发的 IP
export ha_forward_port=6443
# haproxy 映射的 IP
export ha_port=8443
```

#### 安装 keepalived 和 haproxy

```bash
yum install keepalived haproxy -y
```

#### 配置 keepalived

##### 导入配置文件

编辑文件 `/etc/keepalived/keepalived.conf`

```conf
cat << EOF > /etc/keepalived/keepalived.conf
global_defs {
    router_id LVS_DEVEL
}
vrrp_script check_apiserver {
  script "/etc/keepalived/check_apiserver.sh"
  interval 3
  weight -2
  fall 10
  rise 2
}

vrrp_instance VI_1 {
    state MASTER
    interface $ha_eth
    virtual_router_id 52
    priority 100
    authentication {
        auth_type PASS
        auth_pass 42
    }
    virtual_ipaddress {
        $ha_m_vip
    }
    track_script {
        check_apiserver
    }
}
EOF
```

##### 导入测试脚本

编辑文件 `/etc/keepalived/check_apiserver.sh`

```bash
cat << "EOF" | sed "s@<VIP>@$ha_m_vip@g" | sed "s@<PORT>@$ha_forward_port@g" > /etc/keepalived/check_apiserver.sh
#!/bin/sh
errorExit() {
    echo "*** $*" 1>&2
    exit 1
}

APISERVER_DEST_PORT=<PORT>
APISERVER_VIP=<VIP>
curl --silent --max-time 2 --insecure https://localhost:$APISERVER_DEST_PORT/ -o /dev/null || errorExit "Error GET https://localhost:$APISERVER_DEST_PORT/"
if ip addr | grep -q ${APISERVER_VIP}; then
    curl --silent --max-time 2 --insecure https://$APISERVER_VIP:$APISERVER_DEST_PORT/ -o /dev/null || errorExit "Error GET https://$APISERVER_VIP:$APISERVER_DEST_PORT/"
fi
EOF
chmod +x  /etc/keepalived/check_apiserver.sh
```

#### 安装 `haproxy`

编辑文件 `/etc/haproxy/haproxy.cfg`

```bash
cat << EOF > /etc/haproxy/haproxy.cfg

# /etc/haproxy/haproxy.cfg
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    log /dev/log local0
    log /dev/log local1 notice
    daemon

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 1
    timeout http-request    10s
    timeout queue           20s
    timeout connect         5s
    timeout client          20s
    timeout server          20s
    timeout http-keep-alive 10s
    timeout check           10s

#---------------------------------------------------------------------
# apiserver frontend which proxys to the control plane nodes
#---------------------------------------------------------------------
frontend apiserver
    bind *:$ha_port
    mode tcp
    option tcplog
    default_backend apiserver

#---------------------------------------------------------------------
# round robin balancing for apiserver
#---------------------------------------------------------------------
backend apiserver
    option httpchk GET /healthz
    http-check expect status 200
    mode tcp
    option ssl-hello-chk
    balance     roundrobin
        server k8s-01 $ha_m_ip_1:$ha_forward_port check
        server k8s-02 $ha_m_ip_2:$ha_forward_port check
        server k8s-03 $ha_m_ip_3:$ha_forward_port check
        
#---------------------------------------------------------------------
# check status
#---------------------------------------------------------------------

listen 0.0.0.0:10080
    bind 0.0.0.0:10080
    mode http
    stats enable
    stats uri /
    stats realm Strictly\ Private
    stats auth admin:haproxy
EOF
```

#### 启动高可用环境

```bash
systemctl restart keepalived haproxy
systemctl enable keepalived haproxy
```

### 安装 kubernetes

#### 安装控制节点

> 如果你已经安装过 `kubernetes`想重置的话可使用 `yes | kubeadm reset`

```bash
kubeadm init \
	--control-plane-endpoint "$ha_m_vip:$ha_port" \ 
	--upload-certs \
	--pod-network-cidr=10.244.0.0/16
```

其中：

- `--control-plane-endpoint`: 指定暴露面板的地址和端口，一般为高可用地址IP和端口
- `--upload-certs`: 自动更新证书
- `--pod-network-cidr`: Pod 内部通信的网段，取决于 CNI 插件定义的网段

#### 安装其他控制节点

当第一个控制节点安装完成，输出类似于：

```bash
You can now join any number of control-plane node by running the following command on each as a root:
kubeadm join <END_POINT_IP:PORT> --token <TOKEN> --discovery-token-ca-cert-hash sha256:<CA_HASH> --control-plane --certificate-key <CA_KEY>

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use kubeadm init phase upload-certs to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:
  kubeadm join <END_POINT_IP:PORT> --token <TOKEN> --discovery-token-ca-cert-hash sha256:<CA_HASH>
```

使用第一段指令：

```bash
kubeadm join <END_POINT_IP:PORT> --token <TOKEN> --discovery-token-ca-cert-hash sha256:<CA_HASH> --control-plane --certificate-key <CA_KEY>
```

将当前节点加入集群中，在本教程中，`<END_POINT_IP:PORT>`指代高可用IP+端口。

#### 安装工作节点

正如第一个节点的提示所说，使用：

```bash
  kubeadm join <END_POINT_IP:PORT> --token <TOKEN> --discovery-token-ca-cert-hash sha256:<CA_HASH>
```

将当前节点作为工作节点加入到集群下。

### 安装 Pod 网络附加组件

> 你必须部署一个基于 Pod 网络插件的 **容器网络接口 (CNI)**，以便你的 Pod 可以相互通信。 在安装网络之前，**集群 DNS (CoreDNS) 将不会启动**。

可选的 CNI 插件你可以从[此地址](https://kubernetes.io/zh/docs/concepts/cluster-administration/networking/#how-to-implement-the-kubernetes-networking-model)获取。

本教程使用 `flannel-io`下的 [Flannel](https://github.com/flannel-io/flannel)插件。

#### Flannel 安装指南

##### 下载`Flannel`配置文件

将此文件下载至 Master 节点下

```bash
wget https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml -O kube-flannel.yml
```

##### 修改 `Flannel`配置

主要注意的是 `net-conf.json`配置，其中：

- `Network`:表示的是通信的网段，需要与 kubernetes 安装时指定的 `--pod-network-cidr` 一致。
- `Backend > Type`: 表示的是后端实现，具体详细配置可参考 [Flannel Backends](https://github.com/flannel-io/flannel/blob/master/Documentation/backends.md)，本文采用的是 `wireguard`,关于 `wireguard`在 `CentOS` 的安装配置请参考 [Wireguard Install](https://www.wireguard.com/install/)。

##### 导入 `Flanner`

```bash
kubectl -f apply kube-flannel.yml
```

注意: 导入 CNI 插件时需要下载镜像，如无法连接外部网络请自行配置代理或导入镜像。

## 验证

### 查看各个节点状态

```bash
kubectl get nodes -o wide
```

如果 `STATUS` 一栏不为 `READY`则表示存在问题

### 查看内部容器运行状态

```bash
kubectl get pods -n kube-system -o wide
```

如果 `STATUS` 一栏下容器状态不是 `Running`则表示存在问题，可使用 `kubectl -n kube-system describe pod <POD名称>`来检查问题。

## 扩展内容

### 常见问题

更多故障排除请查看[官方教程](https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/) 或者 `Kuberetes Issues`。

#### 替换 CNI 插件后Pod无法通信

删除 `/etc/cni/net.d/` 目录下无效的配置即可

#### CoreDNS 无法启动

- 如果 CNI 组件未安装则无法启动，安装 CNI 插件即可。
- CoreDNS 启动依赖 `/etc/resolv.conf`文件，如果此文件不存在则无法启动，创建即可并添加默认DNS即可。



更多故障排除请查看[官方教程](https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/) 或者 `Kuberetes Issues`。

### 常用指令

#### 添加自定义域名

```bash
kubectl edit configmap coredns -n kube-system
```

在 `     kubernetes cluster.local in-addr.arpa ip6.arpa` 配置块之后添加:

```nginx
hosts {
    <IP>    <域名>
    fallthrough
}

```

然后删除 `CoreDNS`的 Pod触发配置更新即可。

一个标准的配置如下:

```nginx
.:53 {
    errors
    health {
       lameduck 5s
    }
    ready
    kubernetes cluster.local in-addr.arpa ip6.arpa {
       pods insecure
       fallthrough in-addr.arpa ip6.arpa
       ttl 30
    }
    hosts {
       172.18.40.127    harbor.pcloud.com
       127.18.40.127    harbor.powersi.com
       fallthrough
    }
    prometheus :9153
    forward . /etc/resolv.conf {
       max_concurrent 1000
    }
    cache 30
    loop
    reload
    loadbalance
}

```

### 使用 Harbor 作为容器仓库

> 本教程使用 Harbor 2.4 

#### 下载离线安装包

```bash
cd /opt
wget -c https://github.com/goharbor/harbor/releases/download/v2.4.2/harbor-offline-installer-v2.4.2.tgz
tar zxvf harbor-offline-installer-v2.4.2.tgz
```

#### 安装 Docker

```bash
yum install -y yum-utils
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sed -i "s/download.docker.com/mirrors.ustc.edu.cn\/docker-ce/g" /etc/yum.repos.d/docker-ce.repo 
yum install -y docker-ce docker-compose
```

#### 创建证书 （可选）

> 如果你的域名证书不可信（不是由权威机构签发），则需要将根证书导入系统中，否则会标记为不可信

##### 创建 CA 证书

```bash
mkdir -p /data/certs
cd /data/certs
# 配置地址
export CA_NAME=PowerSI Internal CA 
# 生成CA证书
openssl genrsa -out ca.key 4096
# 生成证书
openssl req -x509 -new -nodes -sha512 -days 3650  -subj "/CN=$CA_NAME"  -key ca.key  -out ca.crt
```

##### 创建域名证书

```bash
# 配置地址
export CERT_HOST=harbor.powersi.com
# 创建私钥
openssl genrsa -out server.key 4096
# 生成证书签名请求
openssl req  -new -sha512  -subj "/CN=$CERT_HOST"  -key server.key  -out server.csr
# 生成harbor仓库主机的证书
cat > v3.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth 
subjectAltName = @alt_names
[alt_names]
DNS.1=$CERT_HOST
EOF
openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in server.csr \
    -out server.crt
```

#### 配置 Harbor

复制文件 `/opt/harbor/harbor.yml.tmpl` 到 `/opt/harbor/harbor.yml`，然后编辑 `/opt/harbor/harbor.yml.tmpl`文件。

将证书配置成如下配置：

```yml
# 域名地址
hostname: $CERT_HOST
https:
  port: 443
  certificate: /data/certs/server.crt
  private_key: /data/certs/server.key
```

其他配置按需改动即可，默认管理员密码由 `harbor_admin_password:`属性控制。

#### 第一次启动 Harbor

跳转至安装目录 `/opt/harbor`，开始执行：

```bash
cd /opt/harbor
./install.sh
```

等待启动完成即可。

#### 导入证书

复制 CA 证书`/data/certs/ca.crt`到 `/etc/pki/ca-trust/source/anchors`目录，然后执行 `update-ca-trust`即可，注意将此条目添加到自定义 DNS下。

#### 重新启动 Harbor

跳转至安装目录 `/opt/harbor`，开始执行：

```bash
docker-compose up -d
```

