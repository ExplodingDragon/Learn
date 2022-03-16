# Kubernetes 高可用集群搭建

```bash
yum install keepalived haproxy -y
```



```bash
cat << "EOF" > /etc/keepalived/keepalived.conf
! /etc/keepalived/keepalived.conf
! Configuration File for keepalived
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
    interface ens192
    virtual_router_id 52
    priority 100
    authentication {
        auth_type PASS
        auth_pass 42
    }
    virtual_ipaddress {
        172.18.40.173
    }
    track_script {
        check_apiserver
    }
}
EOF
```

```bash
cat << "EOF" > /etc/keepalived/check_apiserver.sh
#!/bin/sh
errorExit() {
    echo "*** $*" 1>&2
    exit 1
}

APISERVER_DEST_PORT=6443
APISERVER_VIP=172.18.40.173
curl --silent --max-time 2 --insecure https://localhost:$APISERVER_DEST_PORT/ -o /dev/null || errorExit "Error GET https://localhost:$APISERVER_DEST_PORT/"
if ip addr | grep -q ${APISERVER_VIP}; then
    curl --silent --max-time 2 --insecure https://$APISERVER_VIP:$APISERVER_DEST_PORT/ -o /dev/null || errorExit "Error GET https://$APISERVER_VIP:$APISERVER_DEST_PORT/"
fi
EOF
chmod +x  /etc/keepalived/check_apiserver.sh
```

```bash
cat << "EOF" > /etc/haproxy/haproxy.cfg

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
        server k8s-01 172.18.40.171:6443 check
        server k8s-02 172.18.40.172:6443 check
        server k8s-03 172.18.40.174:6443 check
        
EOF
```

```bash
systemctl enable haproxy --now
systemctl enable keepalived --now
```

```bash
yes | kubeadm reset
rm -rf /etc/cni/net.d/
kubeadm init --control-plane-endpoint 172.18.40.173:8443 --upload-certs --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
/bin/cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
```

CNI 插件为：https://github.com/flannel-io/flannel
