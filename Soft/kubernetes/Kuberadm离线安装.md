# Kuberadm 离线安装指南

> 此文档基于 CentOS 7.x

## 环境准备

 ### 配置代理地址

```bash
# 备份环境变量
cp /etc/environment /etc/environment.bak
# 写入全局环境变量
cat >> /etc/environment << "EOF"
export proxy="http://192.168.40.254:8889"
export http_proxy=$proxy
export https_proxy=$proxy
export ftp_proxy=$proxy
export no_proxy="localhost, 127.0.0.1, ::1,192.168.40.1,192.168.40.2,192.168.40.3,192.168.40.4,192.168.40.254"
EOF
source /etc/environment
```

### 配置 yum 镜像

**配置 CentOS-Base 镜像地址**

```bash
cat > /etc/yum.repos.d/CentOS-Base.repo << "EOF"
[base]
name=CentOS-$releasever - Base
baseurl=https://mirrors.ustc.edu.cn/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-$releasever - Updates
baseurl=https://mirrors.ustc.edu.cn/centos/$releasever/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-$releasever - Extras
baseurl=https://mirrors.ustc.edu.cn/centos/$releasever/extras/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[centosplus]
name=CentOS-$releasever - Plus
baseurl=https://mirrors.ustc.edu.cn/centos/$releasever/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF
```

**配置 Docker 地址**

```bash
yum install -y yum-utils
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sed -i "s/download.docker.com/mirrors.ustc.edu.cn\/docker-ce/g" /etc/yum.repos.d/docker-ce.repo 
```

**配置 kubernetes 地址**

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

### 配置系统

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
# 将 SELinux 设置为 permissive 模式（相当于将其禁用）
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```

### 移除 Swap

```bash
SWAP_PATH=$(cat /etc/fstab | grep " swap " | grep '^[^#]'  | awk '{print $1}')
echo current swap path: $SWAP_PATH
sed -i "s@$SWAP_PATH@# $SWAP_PATH@g" /etc/fstab
swapoff $SWAP_PATH
```

### 依赖安装

```bash
yum update  -y 
yum install -y createrepo yum-utils nfs-utils wget device-mapper-persistent-data lvm2  docker-ce docker-ce-cli containerd.io \
	chrony  kubelet kubeadm kubectl
systemctl enable --now kubelet
```

### 配置 Docker 代理

```bash
mkdir /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/http-proxy.conf << EOF
[Service]
Environment="HTTP_PROXY=http://172.16.63.188:8889"
Environment="HTTPS_PROXY=http://172.16.63.188:8889"
Environment="NO_PROXY=localhost,127.0.0.1,172.18.40.171,172.18.40.172,172.18.40.173,172.18.40.174,172.18.40.175,harbor.powersi.com,.powersi.com"
EOF
systemctl daemon-reload
systemctl restart docker
```



### 配置 cgroup 

```bash
# 修改docker Cgroup Driver为systemd
sed -i "s#^ExecStart=/usr/bin/dockerd.*#ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --exec-opt native.cgroupdriver=systemd#g" /usr/lib/systemd/system/docker.service
# 重启 docker，并启动 kubelet
echo "KUBELET_EXTRA_ARGS=--cgroup-driver=systemd" > /etc/sysconfig/kubelet
systemctl daemon-reload
systemctl restart docker kubelet
```

### 拉取镜像

```bash
for i in `kubeadm config images list`; do 
  imageName=${i#k8s.gcr.io/}
  docker pull registry.aliyuncs.com/google_containers/$imageName
  docker tag registry.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
  docker rmi registry.aliyuncs.com/google_containers/$imageName
done;
```

### 移除代理

```bash
echo > /etc/environment
rm -f /etc/systemd/system/docker.service.d/http-proxy.conf
unset proxy
unset http_proxy
unset https_proxy
unset ftp_proxy
systemctl daemon-reload
systemctl restart docker kubelet
```

## 安装

### Master 安装

```bash
kubeadm init --apiserver-advertise-address=192.168.40.1 --pod-network-cidr=10.244.0.0/16
```

```
# 部署网络组件
https://projectcalico.docs.tigera.io/getting-started/kubernetes/quickstart
```

```bash
# 配置 docker 地址
 kubectl create secret docker-registry regcred   --docker-server=harbor.pcloud.com   --docker-username=admin   --docker-password=admin  
```



```bash
for i in `cat  calico.yaml | grep "image: " | awk '{print $2}' |xargs  `; do 
	docker pull $i;
	new_tag="harbor.pcloud.com/mirrors/$i";
    docker tag $i $new_tag ;
    docker push $new_tag ;
done;
```

