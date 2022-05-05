# NFS 安装文档

## 安装 NFS 服务端

```bash
sudo yum install nfs-utils -y
```

## 服务端配置

### 设置 NFS 服务开机启动

```bash
sudo systemctl enable rpcbind
sudo systemctl enable nfs
```

### 启动 NFS 服务

```bash
sudo systemctl start rpcbind
sudo systemctl start nfs
```

### 防火墙需要打开 rpc-bind 和 nfs 的服务

```bash
sudo firewall-cmd --zone=public --permanent --add-service={rpc-bind,mountd,nfs}
sudo firewall-cmd --reload
```

## 配置共享目录

服务启动之后，我们在服务端配置一个共享目录

```bash
sudo mkdir /share
sudo chmod 755 /share
```

根据这个目录，相应配置导出目录

```
sudo vi /etc/exports
```

添加如下配置

```
/share/     172.18.40.0/24(rw,sync,no_root_squash,no_all_squash)
```

1. `/data`: 共享目录位置。
2. `172.18.40.0/24`: 客户端 IP 范围，`*` 代表所有，即没有限制。
3. `rw`: 权限设置，可读可写。
4. `sync`: 同步共享目录。
5. `no_root_squash`: 可以使用 root 授权。
6. `no_all_squash`: 可以使用普通用户授权。

`:wq` 保存设置之后，重启 NFS 服务。

```
sudo systemctl restart nfs
```

可以检查一下本地的共享目录

```bash
showmount -e localhost
```

## 安装NFS客户端

安装方法与服务端类似

```bash
sudo yum install nfs-utils
```

设置 rpcbind 服务的开机启动

```bash
sudo systemctl enable rpcbind
```

启动 NFS 服务

```bash
sudo systemctl start rpcbind
```

> 客户端不需要打开防火墙，因为客户端时发出请求方，网络能连接到服务端即可。客户端也不需要开启 NFS 服务，因为不共享目录。



## 参考

1. [CentOS 7 下 yum 安装和配置 NFS](https://qizhanming.com/blog/2018/08/08/how-to-install-nfs-on-centos-7)