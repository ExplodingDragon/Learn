# Kubernetes 部署日志 

> 此日志部署环境为 `Debian bullseye`

## 部署 k3s

### 部署 Server

**需要 Wireguard**

```bash
curl -sfL https://get.k3s.io | sed "s@https://github.com@https://hub.fastgit.xyz@g" |  sh -s - server --datastore-endpoint=etcd --token c83f0510-a5b3-11ec-b909-0242ac120002 --cluster-cidr "10.254.0.0/16" --service-cidr "10.253.0.0/16" --flannel-backend wireguard --cluster-dns 10.253.0.254 --cluster-domain "dragon-k3s.lan"  --flannel-iface eth0 --node-ip 10.0.0.21 --node-external-ip 10.0.0.21  --cluster-init --disable-helm-controller


curl -sfL https://get.k3s.io | sed "s@https://github.com@https://hub.fastgit.xyz@g" |  sh -s - server --datastore-endpoint=etcd --token c83f0510-a5b3-11ec-b909-0242ac120002 --cluster-cidr "10.254.0.0/16" --service-cidr "10.253.0.0/16" --flannel-backend wireguard --cluster-dns 10.253.0.254 --cluster-domain "dragon-k3s.lan"  --flannel-iface eth0 --node-ip 10.0.0.22 --node-external-ip 10.0.0.22  --server https://10.0.0.21:6443 --disable-helm-controller

curl -sfL https://get.k3s.io | sed "s@https://github.com@https://hub.fastgit.xyz@g" | sh -s - server --datastore-endpoint=etcd  --token c83f0510-a5b3-11ec-b909-0242ac120002 --cluster-cidr "10.254.0.0/16" --service-cidr "10.253.0.0/16" --flannel-backend wireguard --cluster-dns 10.253.0.254 --cluster-domain "dragon-k3s.lan"  --flannel-iface eth0 --node-ip 10.0.0.23 --node-external-ip 10.0.0.23 --server https://10.0.0.21:6443 --disable-helm-controller
```





各个配置详情请查看 [rancher]( https://docs.rancher.cn/docs/k3s/installation/install-options/server-config/_index)

注意：截至`2022/03/23` , 如果使用 Docker 作为运行时，则需要配置

#### 增加 HAProxy 高可用规则

```bash
export CLU_1=10.0.0.21
export CLU_2=10.0.0.22
export CLU_3=10.0.0.23
export CLU_VIP=10.0.0.20

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
# check status
#---------------------------------------------------------------------

listen 0.0.0.0:8080
    bind 0.0.0.0:8080
    mode http
    stats enable
    stats uri /
    stats realm Strictly\ Private
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
systemctl restart haproxy.service
```

注意：如果想在外部使用 `kubectl` 则需将配置文件 `~/.kube/config` 下 IP 和端口改为 **VIP 地址**和 **HAProxy 端口**

### 部署 Agent

```bash
curl -sfL https://get.k3s.io | sh -s - agent --token c83f0510-a5b3-11ec-b909-0242ac120002 --server https://10.0.0.20:8443
```