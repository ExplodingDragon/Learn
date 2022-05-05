# 使用 Gitea 搭建自定义 Git  服务器

> 本文使用 [Debian 10 amd64](https://www.debian.org/) + [Gitea 1.13.2](https://dl.gitea.io/gitea/1.13.2)

## 升级系统 && 安装软件

```bash
apt update && apt full-upgrade -y
apt install git wget nginx ufw -y
```

## 启用防火墙

```bash
ufw default deny
ufw allow 22/tcp
ufw allow 80,443/tcp
ufw enable
```

## 禁止 SSH 使用密码登录 [可选]

**注意**：在禁止之前需添加登录密钥，否则推出后将无法使用密码再次登录服务器，具体步骤可百度

编辑文件 `/etc/ssh/sshd_config`,更改如下属性：

```conf
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile      .ssh/authorized_keys .ssh/authorized_keys2
```

然后重启 `SSH`

```bash
service ssh restart
```

## 创建用户

```bash
useradd --home-dir /var/lib/gitea  --create-home --no-user-group --shell /bin/bash git
```

## 暂时关闭防火墙

```bash
ufw disable
```

## 建立安装目录

```bash
mkdir /opt/gitea/
wget https://dl.gitea.io/gitea/1.13.2/gitea-1.13.2-linux-amd64 -O /opt/gitea/gitea
chown root:root /opt/gitea/gitea
chmod 755 /opt/gitea/gitea
```

## 配置安装 Gitea

```bash
su -l git
/opt/gitea/gitea --work-path /var/lib/gitea --custom-path /var/lib/gitea web --config /var/lib/gitea/app.ini
```

然后访问 `http://ip:3000`,配置安装选项

## 配置反向代理

```bash
 rm /etc/nginx/sites-enabled/default
 rm /etc/nginx/sites-available/default
 cat > /etc/nginx/sites-available/default << EOF
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://localhost:3000;
    }
}
EOF
 ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
service nginx restart
```

> 注意：**HTTP** 协议**采用明文传输**，**易被监听或篡改**，如果部署到生产环境需配置 **HTTPS** ！



## 配置开机自启

```bash
mkdir /etc/gitea
mv /var/lib/gitea/app.ini /etc/gitea/app.ini
cat > /etc/systemd/system/gitea.service << EOF
[Unit]
Description=Gitea (Git with a cup of tea)
After=syslog.target
After=network.target
###
# Don't forget to add the database service requirements
###
#
#Requires=mysql.service
#Requires=mariadb.service
#Requires=postgresql.service
#Requires=memcached.service
#Requires=redis.service

[Service]

LimitMEMLOCK=infinity
LimitNOFILE=65535
RestartSec=2s
Type=simple
User=git
WorkingDirectory=/var/lib/gitea/

ExecStart=/opt/gitea/gitea web --config /etc/gitea/app.ini
Restart=always
Environment=USER=git HOME=/var/lib/gitea GITEA_WORK_DIR=/var/lib/gitea

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl stop gitea.service && systemctl start gitea.service && systemctl status gitea.service
systemctl enable gitea.service
```

## 启用防火墙

```bash
ufw enable
```

安装结束



EOF
