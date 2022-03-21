# Kubernetes 部署日志 

> 此日志部署环境为 `Debian bullseye`

## 环境准备

### 部署 Docker

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sed "s#download.docker.com#mirrors.ustc.edu.cn/docker-ce#g" |  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
# 更改 cgroup 驱动为 systemd
systemctl stop docker.service docker.socket
mkdir -p /etc/systemd/system/docker.service.d
cat << "EOF" >/etc/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd  --exec-opt native.cgroupdriver=cgroupfs -H fd:// --containerd=/run/containerd/containerd.sock
EOF
systemctl daemon-reload 
systemctl start docker
```


#### 创建 k3s 用户

```mysql
create user k3s identified by 'k3s-password';
create database k3s;
grant all privileges on k3s.* to k3s@'%' identified by 'k3s';
SET PASSWORD FOR 'k3s' = PASSWORD("k3s-password");
flush  privileges;
```

## 部署 k3s

### 部署 Server

```bash
curl -sfL https://get.k3s.io | sh -s - server --datastore-endpoint="mysql://k3s:k3s-password@tcp(127.0.0.1:3307)/k3s" --token c83f0510-a5b3-11ec-b909-0242ac120002 --cluster-cidr "10.254.0.0/16" --service-cidr "10.253.0.0/16" --docker --flannel-backend wireguard --cluster-dns 10.253.0.254 --cluster-domain "cluster.local"  --cluster-init --flannel-iface wg0 --node-ip 10.10.10.1 --node-external-ip 10.10.10.1
```

各个配置详情请查看 [rancher]( https://docs.rancher.cn/docs/k3s/installation/install-options/server-config/_index)

#### 增加 HAProxy 高可用规则

```bash
cat << EOF >> /etc/haproxy/haproxy.cfg
#---------------------------------------------------------------------
# apiserver frontend which proxys to the control plane nodes
#---------------------------------------------------------------------
frontend apiserver
    bind *:8443
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
        server k8s-01  $CLU_1:6443 check
        server k8s-02  $CLU_2:6443 check
        server k8s-03  $CLU_3:6443 check
EOF
systemctl reload haproxy.service
```

注意：如果想在外部使用 `kubectl` 则需将配置文件 `~/.kube/config` 下 IP 和端口改为 **VIP 地址**和 **HAProxy 端口**

### 部署 Agent

```bash
curl -sfL https://get.k3s.io | sh -s - agent --token c83f0510-a5b3-11ec-b909-0242ac120002 --server https://10.0.0.20:8443
```