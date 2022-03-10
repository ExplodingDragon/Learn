# Nacos安装与配置

Nacos 官网 :[nacos.io](https://nacos.io/zh-cn/)

> 安装系统为 [ArchLinux](https://archlinux.org/) , 如无特别说明，所有 `Shell` 命令均在 `root` 用户下执行.

## 环境准备

### 安装 JDK 及其他依赖

Nacos 依赖于 JDK ，需先部署 JDK

```bash
yes | pacman -S jdk11-openjdk wget patch
```

### 创建 Nacos 用户

```bash
useradd --create-home --home-dir /var/lib/nacos --shell /usr/bin/nologin --no-user-group nacos
```

## 安装

### 下载 Nacos

登录 nacos 用户，下载最新 [Nacos下Linux安装包](https://github.com/alibaba/nacos/releases)，本文选择的是 [Nacos2.0.3](https://github.com/alibaba/nacos/releases/tag/2.0.3).

注意：此命令需以 nacos 用户执行

```bash
wget -c -O /var/lib/nacos/nacos.tgz https://github.com/alibaba/nacos/releases/download/2.0.3/nacos-server-2.0.3.tar.gz
```

### 部署 Nacos

注意：此命令需以 nacos 用户执行

```bash
cd /var/lib/nacos/
tar zxvf /var/lib/nacos/nacos.tgz
rm /var/lib/nacos/nacos.tgz
```

### 修改启动配置

注意：此命令需以 nacos 用户执行

```bash
cat > /var/lib/nacos/nacos/bin/startup.patch << "EOF"
111c111
<   JAVA_OPT="${JAVA_OPT} -Djava.ext.dirs=${JAVA_HOME}/jre/lib/ext:${JAVA_HOME}/lib/ext"
---
>   JAVA_OPT_EXT_FIX="-Djava.ext.dirs=${JAVA_HOME}/jre/lib/ext:${JAVA_HOME}/lib/ext"
127c127
< echo "$JAVA ${JAVA_OPT}"
---
> echo "$JAVA $JAVA_OPT_EXT_FIX ${JAVA_OPT}"
134a135,138
> # check the start.out log output file
> if [ ! -f "${BASE_DIR}/logs/start.out" ]; then
>   touch "${BASE_DIR}/logs/start.out"
> fi
136,137c140,142
< echo "$JAVA ${JAVA_OPT}" > ${BASE_DIR}/logs/start.out 2>&1
< $JAVA ${JAVA_OPT} nacos.nacos
---
> echo "$JAVA $JAVA_OPT_EXT_FIX ${JAVA_OPT}" > ${BASE_DIR}/logs/start.out 2>&1 &
> nohup "$JAVA" "$JAVA_OPT_EXT_FIX" ${JAVA_OPT} nacos.nacos >> ${BASE_DIR}/logs/start.out 2>&1 &
> echo "nacos is starting，you can check the ${BASE_DIR}/logs/start.out"
EOF
cp /var/lib/nacos/nacos/bin/startup.sh /var/lib/nacos/nacos/bin/nacos.sh
patch -R /var/lib/nacos/nacos/bin/nacos.sh /var/lib/nacos/nacos/bin/startup.patch
rm /var/lib/nacos/nacos/bin/startup.patch
```

### 创建开机任务

```bash
cat > /lib/systemd/system/nacos.service << "EOF"
[Unit]
Description=Nacos Server
After=syslog.target
After=network.target
#Requires=mysql.service
#Requires=mariadb.service


[Service]
LimitMEMLOCK=infinity
LimitNOFILE=65535
RestartSec=2s
Type=simple
User=nacos
WorkingDirectory=/var/lib/nacos/nacos/
ExecStart=/var/lib/nacos/nacos/bin/nacos.sh -m standalone
Restart=always


[Install]
WantedBy=multi-user.target
EOF
systemctl start nacos.service
```

## 启动

想要启动 Nacos ，可执行如下命令

```bash
systemctl enable nacos.service
``` 

使用 `systemctl status nacos.service` 查看 Nacos 状态.