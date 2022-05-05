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
        172.18.40.249
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

APISERVER_DEST_PORT=8848
APISERVER_VIP=172.18.40.249
curl --silent --max-time 2 --insecure http://localhost:$APISERVER_DEST_PORT/nacos -o /dev/null || errorExit "Error GET https://localhost:$APISERVER_DEST_PORT/"
if ip addr | grep -q ${APISERVER_VIP}; then
    curl --silent --max-time 2 --insecure http://$APISERVER_VIP:$APISERVER_DEST_PORT/nacos -o /dev/null || errorExit "Error GET https://$APISERVER_VIP:$APISERVER_DEST_PORT/"
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
    bind *:8849
    mode http
    default_backend apiserver

#---------------------------------------------------------------------
# round robin balancing for apiserver
#---------------------------------------------------------------------
backend apiserver
    mode http
    balance     roundrobin
        server k8s-01 172.18.40.229:8848 check
        server k8s-02 172.18.40.230:8848 check
        server k8s-03 172.18.40.231:8848 check

listen 0.0.0.0:8080
    bind 0.0.0.0:8080
    mode http
    stats enable
    stats uri /
    stats realm Strictly\ Private
    stats auth admin:haproxy
EOF
```

```bash
systemctl enable haproxy --now
systemctl enable keepalived --now
systemctl restart haproxy keepalived

```
