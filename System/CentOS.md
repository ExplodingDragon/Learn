 # CentOS 配置记录

> 注意：此文档仅对 CentOS 7.x 适配

## 通用配置

### 升级并部署常用软件

```bash
yum -q install Percona-Server-shared-compat-57 Percona-Server-shared-compat -y && yum update -y && rm -f /etc/yum.repos.d/CentOS-* && yum install -y nano vim sshfs bash-completion htop && reboot
```

### 磁盘扩容

```bash
pvcreate /dev/sdb
vgextend centos /dev/sdb
lvextend  -l +100%FREE /dev/mapper/centos-root
xfs_growfs /dev/mapper/centos-root 
```

### 重置 SSH 服务端密钥

```bash
rm -f /etc/ssh/ssh_host_*
systemctl restart sshd
```

### 禁止密码远程登陆

```bash
sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
systemctl restart sshd
```



### 部署公钥

```bash
# 注意：此处是我的公钥地址
cat > ~/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQC4DdxMafiZg6yJtsAGfjsGAXfBFLFq3n6tyFV4bNKgyYbNhT/IgXa+gr/feObkGJT+ge6JHuoADnFqKcFC/gb8V+wONBKz3y007EIadasQowau0ufCQxCS8T1WpmDDeV4L5SI9ui/vAN7JdI3CaN1WjF6NI/+Y0v+KruGptR80gl0otgkG4DUb380enNAhsDNyRWXokA/hrUrdKhyYE06+keUtcmGFAPc7xjhEdO/u9EkgCRQshAqyc7s/EOldKi5fWpdgAoye6znwcxt9o5ihzmOlA94SIxQCd6qoVkG5+Y7jIHUbhv/DBlv7smkWkA2POKv4fTPPtUM3nD6vJExIGVa6G8qUh+XnZZA+SYhfpMk8Qi7YHWAj+OixJH3/axZo0Jdxg+FfJJempKcN4EryKd+YVJ3ElEiD0rbKbngLclP93KnhpqZI2vJXQZqPGfYz34PETjV7ExjWacyEYIrk/VnKaG5AZ8GzIcxxhRFo/vNFGRqFnSkXEqLW0oHuUmPqmP077r1k8dTtWFuJ53XZ2XwwSiegWHnAWwzLFO1YyIHRa49jfgBUFlR7kIZj3aiKhQqxOPHA2x+8XxOJyGNFbx+WBufWBoi5ehQpkSxOaPhuXuei54qGlNOHz+0cIuPxeGdaScIlBCiR2wcIZtwTgy4QHCD2UVPm50+L13Y2/sXuD+BTTQ0mwR22j8cgObHxhouE8rJgPD7dqKCRAz7kn8GpYhqjMFhzBzpz9ymV9UMvFgErfF1YVhrWWD02uyTcVT3W4DLbnx/LiJxugXIAxNhpxQqF48I5QJE0PliJAWRULpo8D5UHUjmZVEcfsrMHKLUHfn2poz100VicJRenZozD2g5vbzfcfJ8ZXN+IQDcbjT+vhvFQN5EacizAxd3viRDZR/akQWVMmBBVlcEZMhvdkp1sG8lA5T4LSDqLcOfKBhNrg8DITg5fSTp8rWUBdDflJfu5ZE4HTQ9wtObhPX0YrD0U0HPEvV8T8gqZIYzQiZk0k80qz6stKdHCx8IHtU00dthS/Kmgq/Nepv2aqAsTcz53SyuRw3il7aS341SvNhKRUX7WlWnefJGu1Ijhh2fUPlPGiDbWoXFeRQ1xTG9I3ICuWTV+njRpWeGG7sKvN/3/PEl821hHNC2q6XQqjiMzGTh3SjaBKrByoicyKSMa1x/mePRsN72Ob0J7P0On6owdTo83LSGNFrHCs/XfXOIO4RH6UgQRVUfV6FRlmH1yk/DWHIPHywn/30DF6GJvergAw5tF7xXTHTV/W0ieai4BjAZo/c/JFfAKe4TRszO7uhL6qrYJvkGuIqpMHM3lJJOYF2EWzmlEsD7OU/xS2A7FhW0AntWnvNORPo3r public-key
EOF
```

### 服务器交换密钥

```bash
# 生成密钥对
ssh-keygen -t rsa -b 4096
# 服务器交换密钥
ssh-exchange-pub-key(){
ssh root@$1 -C "echo $(cat ~/.ssh/id_rsa.pub) >> ~/.ssh/authorized_keys && cat ~/.ssh/id_rsa.pub" >>~/.ssh/authorized_keys 
}
# 交换公钥
ssh-exchange-pub-key <REMOTE IP>
```

### 共享磁盘挂载

```bash
mkdir /public
sshfs root@192.168.40.1:/public /public
```



## 网络配置

### 部署 WireGuard

#### 1. 安装依赖

在线安装：

```bash
    yum install kmod-wireguard wireguard-tools
```

离线安装：

1. 从 `https://pkgs.org/download/kmod-wireguard` 下载合适的 `RPM` 包
1. 推送安装包至服务器 `scp kmod-wireguard-*.rpm root@<ip>:kmod-wireguard.rpm`
1. 安装 `yum install kmod-wireguard.rpm -y`

#### 2. 配置

```bash
wg-init(){
wg_ip=$1
wg_id=$2
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p
mkdir -p /etc/wireguard/keys 
# 生成密钥对
wg genkey | tee /etc/wireguard/keys/wg.private.key | wg pubkey > /etc/wireguard/keys/wg.public.key
# 导入配置
cat > /etc/wireguard/$wg_id.conf << EOF
[Interface]
PrivateKey = $(cat /etc/wireguard/keys/wg.private.key)
Address = $wg_ip/24
ListenPort = 3918
EOF
# 配置开机服务
systemctl enable wg-quick@$wg_id
systemctl start wg-quick@$wg_id
# 防火墙放行
firewall-cmd --zone=trusted --change-interface=$wg_id --permanent
firewall-cmd --zone=public --add-port=3918/udp --permanent
firewall-cmd --reload
}
wg-init <wg-ip> <wg-id>
```

#### 3. 添加对端

```bash
# 写入对端配置
wg-get-remote-peer(){
remote_ip=$1
remote_wg_id=$2
ssh root@$1 -C "\
echo && \
echo [Peer] && \
echo AllowedIPs = \$(ip route | grep $remote_wg_id |  awk '{print \$NF;exit}')/32 && \
echo PublicKey = \$(cat /etc/wireguard/keys/wg.public.key) &&\
echo Endpoint = \$(ip route get 1 | awk '{print \$NF;exit}'):3918 && \
echo "
}
# 获取本地配置
wg-get-local-peer(){
local_wg_id=$1
echo 
echo [Peer] 
echo AllowedIPs = $(ip route | grep $local_wg_id |  awk '{print $NF;exit}')/32 
echo PublicKey = $(cat /etc/wireguard/keys/wg.public.key) 
echo Endpoint = $(ip route get 1 | awk '{print $NF;exit}'):3918 
echo 
}
wg-peer(){
tmp_path=/tmp/remote-$1-$2-$RANDOM.tmp
remote_ip=$1
remote_wg_id=$2
local_wg_id=$3
wg-get-local-peer $local_wg_id  >> $tmp_path
scp $tmp_path root@$remote_ip:$tmp_path
ssh root@$remote_ip -C "cat $tmp_path >> /etc/wireguard/$remote_wg_id.conf && systemctl reload wg-quick@$remote_wg_id"
wg-get-remote-peer $remote_ip $remote_wg_id >> /etc/wireguard/$local_wg_id.conf
systemctl reload wg-quick@$local_wg_id
rm $tmp_path
}
wg-peer <RemoteIP> <REMOTE WG ID> <LOCAL WG ID>
```

### 配置 CURL 转发

```bash
export https_proxy=http://192.168.40.254:8889
export http_proxy=http://192.168.40.254:8889
```



