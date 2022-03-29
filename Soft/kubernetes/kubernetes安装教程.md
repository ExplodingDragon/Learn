# Kubernetes 安装教程

> 此教程基于 Kubeadm + CentOS 7.x

## 前置配置

### 配置代理

```bash
export http_proxy=http://172.16.63.188:8889
export https_proxy=http://172.16.63.188:8889
```

### 安装 kubeadm

#### 配置 RPM 源

```bash
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
setenforce 0
```

#### 选择版本

```bash
yum list kubelet kubeadm kubectl  --showduplicates|sort -r
```

#### 安装指定版本

```bash
# 此处是 1.19
yum install kubelet-1.19.16-0 kubeadm-1.19.16-0 kubectl-1.19.16-0
```

### 配置 Containerd

#### 安装Containerd

```bash
yum remove docker docker-common docker-selinux docker-engine
yum install -y yum-utils device-mapper-persistent-data lvm2 wget
wget -O /etc/yum.repos.d/docker-ce.repo https://download.docker.com/linux/centos/docker-ce.repo
sed -i 's+download.docker.com+mirrors.tuna.tsinghua.edu.cn/docker-ce+' /etc/yum.repos.d/docker-ce.repo
yum makecache fast
yum install containerd -y
systemctl enable containerd.service 
```

#### 配置 Containerd

##### 配置镜像地址

 ```bash
cat << "EOF" > /etc/containerd/config.toml
version = 2
[plugins."io.containerd.grpc.v1.cri"]
#   [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
#     [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
#       SystemdCgroup = true
  [plugins."io.containerd.grpc.v1.cri".registry]
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors."harbor.pcloud.com"]
        endpoint = ["https://harbor.pcloud.com"]
    [plugins."io.containerd.grpc.v1.cri".registry.configs]
      [plugins."io.containerd.grpc.v1.cri".registry.configs."harbor.pcloud.com".tls]
        insecure_skip_verify = true
        ca_file = "/etc/containerd/ca.crt"
      [plugins."io.containerd.grpc.v1.cri".registry.configs."harbor.pcloud.com".auth]
        username = "admin"
        password = "admin"
EOF
 ```

##### 配置证书

> 注意，此步骤针对自签名证书

```bash
cat <<< EOF > /etc/containerd/ca.crt
<ca 证书内容>
EOF
```

##### 导入证书至系统

```bash
cp  /etc/containerd/ca.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust
```

##### 配置 cgroup 驱动

```bash
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
# 设置必需的 sysctl 参数，这些参数在重新启动后仍然存在。
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# 应用 sysctl 参数而无需重新启动
sudo sysctl --system
systemctl restart containerd.service
```

##### 配置代理

```bash
mkdir /etc/systemd/system/containerd.service.d
cat > /etc/systemd/system/containerd.service.d/http_proxy.conf << EOF
[Service]
Environment="HTTP_PROXY=$http_proxy"
Environment="HTTPS_PROXY=$http_proxy"
Environment="http_proxy=$http_proxy"
Environment="https_proxy=$http_proxy"
Environment="NO_PROXY=localhost,127.0.0.1,172.18.40.171,172.18.40.172,172.18.40.173,172.18.40.174,172.18.40.175,harbor.pcloud.com,.corp"
EOF
systemctl daemon-reload
systemctl restart containerd.service 
```



### 预下载集群组件镜像

```bash
for i in `kubeadm config images list`; do
	ctr i pull $i
done;
```

## 安装

```bash
yes | kubeadm reset
rm -rf /etc/cni/net.d/
kubeadm init --control-plane-endpoint 172.18.40.171:6443 --upload-certs --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
/bin/cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
```

CNI 插件为：https://github.com/flannel-io/flannel
