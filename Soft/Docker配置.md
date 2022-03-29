# Docker 配置

> 教程基于 Debian , Docker 使用官方deb安装，非 Debian 源中的 docker

## 部署 Docker

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sed "s#download.docker.com#mirrors.ustc.edu.cn/docker-ce#g" |  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
```



## 使用 UFW 配置 Docker 防火墙 

### UFW 开启转发

编辑文件 `/etc/default/ufw`,找到字段 `DEFAULT_FORWARD_POLICY`,将字段修改为如下所示

```
DEFAULT_FORWARD_POLICY="ACCEPT"
```

### 配置 UFW 规则

编辑文件 `/etc/ufw/before.rules`,在`*filter`前面添加下面内容

```
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING ! -o docker0 -s 172.17.0.0/16 -j MASQUERADE
COMMIT
```

### 配置 Docker 规则

#### 禁用 Docker 操作 `iptables`

编辑文件 `/etc/docker/daemon.json`，如没有则新建，添加/修改如下内容

```json
{
"iptables": false
}
```

编辑文件 `/etc/default/docker`,修改字段 `DOCKER_OPTS` 如下所示

```
DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4 --iptables=false"
```

### 应用规则

```
systemctl restart docker
systemctl restart ufw
reboot
```

## 添加第三方镜像源

编辑文件 `/etc/docker/daemon.json`，如没有则新建，添加/修改如下内容

```json
{
  "iptables": false,
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn/",
    "https://registry.docker-cn.com",
    "https://dockerhub.azk8s.cn",
    "https://reg-mirror.qiniu.com"
  ]
}
```

**DockerHub镜像加速器列表**

| 镜像加速器          | 镜像加速器地址                            |
| :------------------ | :---------------------------------------- |
| `Docker` 中国官方镜像 | `https://registry.docker-cn.com`        |
| `DaoCloud`镜像站    | `http://<your_code>.m.daocloud.io`        |
| `Azure` 中国镜像    | `https://dockerhub.azk8s.cn`              |
| 科大镜像站          | `https://docker.mirrors.ustc.edu.cn`      |
| 阿里云              | `https://<your_code>.mirror.aliyuncs.com` |
| 七牛云              | `https://reg-mirror.qiniu.com`            |
| 网易云              | `https://hub-mirror.c.163.com`            |
| 腾讯云              | `https://mirror.ccs.tencentyun.com`       |


## 参考

1. https://www.jianshu.com/p/5a911f20d93e
2. https://docs.docker.com/
3. https://blog.csdn.net/sinat_33384251/article/details/94409846