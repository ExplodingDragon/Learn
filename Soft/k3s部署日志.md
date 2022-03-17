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
ExecStart=/usr/bin/dockerd  --exec-opt native.cgroupdriver=cgroupfs  -H fd:// --containerd=/run/containerd/containerd.sock
EOF
systemctl daemon-reload 
systemctl start docker
```

### 部署 MariaDB Galera集群

此处使用三台机器创建集群。其中，三台机器的配置为：

|    节点地址    |    MariaDB版本    |  集群 VIP   | 类型 |
| :------------: | :---------------: | :---------: | :--: |
| `10.0.0.21/24` | `10.5.12-MariaDB` | `10.0.0.20` |  主  |
| `10.0.0.22/24` | `10.5.12-MariaDB` | `10.0.0.20` |  从  |
| `10.0.0.23/24` | `10.5.12-MariaDB` | `10.0.0.20` |  从  |

#### 安装MariaDB依赖并初始化

```bash
apt install mariadb-server  galera-4 rsync  mariadb-client -y
mysql_secure_installation # 配置默认安全密钥
```

#### 配置集群

> 不建议对捆绑的配置文件进行更改。相反，建议在 `include` 目录创建自定义配置文件。 `include` 目录中的配置文件按字母顺序读取。如果您希望您的自定义配置文件覆盖捆绑的配置文件，那么最好在自定义配置文件的名称前加上一个排序的字符串，例如`z-`.
>
> - 在 Debian 和 Ubuntu 上，一个可行的自定义配置文件应该是：`/etc/mysql/mariadb.conf.d/z-custom-my.cnf`

##### 预先配置

```bash
 systemctl stop mariadb.service
export CLU_1=10.0.0.21
export CLU_2=10.0.0.22
export CLU_3=10.0.0.23
```

##### 第一台机器配置

```bash
cat << EOF > /etc/mysql/mariadb.conf.d/z-cluster.cnf
[mariadb]

# Server Configuration
log_error                = mariadbd.err
innodb_buffer_pool_size  = 1G
bind-address             = 0.0.0.0

# Cluster Configuration
wsrep_on                 = ON
wsrep_provider           = /usr/lib/galera/libgalera_smm.so
wsrep_cluster_address    = gcomm://
wsrep_cluster_name       = k3s-cluster
wsrep_node_address       = $CLU_1

default_storage_engine   = InnoDB
binlog_format            = ROW
innodb_autoinc_lock_mode = 2
EOF
sudo galera_new_cluster
systemctl restart mariadb.service
```

##### 第二台机器配置

```bash
cat << EOF > /etc/mysql/mariadb.conf.d/z-cluster.cnf
[mariadb]

# Server Configuration
log_error                = mariadbd.err
innodb_buffer_pool_size  = 1G
bind-address             = 0.0.0.0

# Cluster Configuration
wsrep_on                 = ON
wsrep_provider           = /usr/lib/galera/libgalera_smm.so
wsrep_cluster_address    = gcomm://$CLU_1,$CLU_2,$CLU_3
wsrep_cluster_name       = k3s-cluster
wsrep_node_address       = $CLU_2

default_storage_engine   = InnoDB
binlog_format            = ROW
innodb_autoinc_lock_mode = 2
EOF
systemctl restart mariadb.service
```

##### 第三台机器配置

```bash
cat << EOF > /etc/mysql/mariadb.conf.d/z-cluster.cnf
[mariadb]

# Server Configuration
log_error                = mariadbd.err
innodb_buffer_pool_size  = 1G
bind-address             = 0.0.0.0

# Cluster Configuration
wsrep_on                 = ON
wsrep_provider           = /usr/lib/galera/libgalera_smm.so
wsrep_cluster_address    = gcomm://$CLU_1,$CLU_2,$CLU_3
wsrep_cluster_name       = k3s-cluster
wsrep_node_address       = $CLU_3

default_storage_engine   = InnoDB
binlog_format            = ROW
innodb_autoinc_lock_mode = 2
EOF
systemctl restart mariadb.service
```

##### 集群验证

`mysql -uroot`登陆集群执行此`SQL`

```sql
SHOW GLOBAL STATUS LIKE 'wsrep_cluster_size'; # 查询集群数量
```

#### 配置高可用代理 

```bash
sudo apt install keepalived haproxy -y
```

##### 配置 HAProxy

###### 创建测试用户

```mysql
CREATE USER 'haproxy'@'%';
```

###### 装入配置文件

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
# mysql
#---------------------------------------------------------------------
listen mysql-cluster
    bind 0.0.0.0:3307
    mode tcp
    balance roundrobin
    option tcpka
	option mysql-check user haproxy
    server mysql-1 $CLU_1:3306 check weight 1
    server mysql-2 $CLU_2:3306 check weight 1
    server mysql-3 $CLU_3:3306 check weight 1

#---------------------------------------------------------------------
# check status
#---------------------------------------------------------------------

listen 0.0.0.0:8080
    bind 0.0.0.0:8080
    mode http
    stats enable
    stats uri /
    stats realm Strictly\ Private
    stats auth admin:haproxy
EOF
systemctl restart haproxy.service
```

##### 配置Keepalived

###### 装入配置文件

**修改对应的网卡地址和虚拟ip！**

```bash
cat << "EOF" > /etc/keepalived/keepalived.conf
! /etc/keepalived/keepalived.conf
! Configuration File for keepalived
global_defs {
    router_id LVS_DEVEL
}
vrrp_script check_apiserver {
  script "/etc/keepalived/check.sh"
  interval 3
  weight -2
  fall 10
  rise 2
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 52
    priority 100
    authentication {
        auth_type PASS
        auth_pass 42
    }
    virtual_ipaddress {
        10.0.0.20
    }
    track_script {
        check_apiserver
    }
}
EOF
systemctl restart keepalived.service
```

###### 装入测试脚本

```bash
cat << "EOF" > /etc/keepalived/check.sh
#!/bin/sh
errorExit() {
    echo "*** $*" 1>&2
    exit 1
}

APISERVER_DEST_PORT=8080
APISERVER_VIP=10.0.0.20 # 修改为vip地址
curl --silent --max-time 2 --insecure https://localhost:$APISERVER_DEST_PORT/ -o /dev/null || errorExit "Error GET https://localhost:$APISERVER_DEST_PORT/"
if ip addr | grep -q ${APISERVER_VIP}; then
    curl --silent --max-time 2 --insecure https://$APISERVER_VIP:$APISERVER_DEST_PORT/ -o /dev/null || errorExit "Error GET https://$APISERVER_VIP:$APISERVER_DEST_PORT/"
fi
EOF
chmod +x  /etc/keepalived/check.sh
systemctl restart keepalived.service
```

#### 创建 k3s 用户

```mysql
create user k3s identified by 'k3s-password';
create database k3s;
grant all privileges on k3s.* to k3s@'%' identified by 'k3s';
flush  privileges;
```

## 部署 k3s

### 部署 Server

```bash
curl -sfL https://get.k3s.io | sh -s - server   --datastore-endpoint="mysql://k3s:k3s-password@tcp(10.0.0.20:3307)/k3s" --token c83f0510-a5b3-11ec-b909-0242ac120002 --cluster-cidr "10.254.0.0/16" --service-cidr "10.253.0.0/16" --docker --flannel-backend wireguard --cluster-dns 10.253.0.254 --cluster-domain "cluster.local"  --cluster-init 
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
systemctl restart haproxy.service
```

注意：如果想在外部使用 `kubectl` 则需将配置文件 `~/.kube/config` 下 IP 和端口改为 **VIP 地址**和 **HAProxy 端口**

### 部署 Agent

```bash
curl -sfL https://get.k3s.io | sh -s - agent --token c83f0510-a5b3-11ec-b909-0242ac120002 --server https://10.0.0.20:8443
```