# Elastic Search 学习

## 集群部署

### 环境介绍

#### 机器介绍

|   名称  |      网络       |   配置    | Elastic Search 版本 |
| :--: | :-------------: | :-------: | :-----------------: |
|   es1   | 192.168.40.1/24 | 4C-8G-50G |        8.0.1        |
|  es2  | 192.168.40.2/24 | 4C-8G-50G |        8.0.1        |
| es3 | 192.168.40.3/24 | 4C-8G-50G |        8.0.1        |
| es4 | 192.168.40.4/24 | 4C-8G-50G |        8.0.1        |

> 其中，四台机器共享 `/public` 文件夹

### 集群搭建

#### 准备安装包

此处采用 `elastic search 8.0.1` 版本.

```bash
# 下载
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.0.1-linux-x86_64.tar.gz -O /public/pkg/elasticsearch-8.0.1-linux-x86_64.tar.gz
wget -c https://artifacts.elastic.co/downloads/kibana/kibana-8.0.1-linux-x86_64.tar.gz -0 /public/pkg/kibana-8.0.1-linux-x86_64.tar.gz
chmod -R 755 /public
```

#### 配置运行环境

ES 以 `root `用户运行可能导致未知的安全漏洞，创建普通用户以保证系统安全性

```bash
useradd --create-home --no-user-group --home-dir /var/lib/elastic elastic --shell /bin/bash
```

#### 安装

```bash
 
 #安装
su - elastic
tar -zxvf  /public/pkg/elasticsearch-8.0.1-linux-x86_64.tar.gz
ln -s /var/lib/elastic/elasticsearch-8.0.1 /var/lib/elastic/elasticsearch
tar -zxvf /public/pkg/kibana-8.0.1-linux-x86_64.tar.gz
ln -s /var/lib/elastic/kibana-8.0.1 /var/lib/elastic/kibana
```



#### 配置 `Elastic Search  `

```bash
# 按需配置系统
echo -e "elastic hard nofile 65536 \nelastic soft nofile 65536\nelastic soft nproc 4096 \nelastic hard nproc 4096" >> /etc/security/limits.conf
echo "vm.max_map_count=262144" >> /etc/sysctl.conf  
sysctl -p 

# 修改集群名称
su - elastic
mkdir ~/log
mkdir ~/data
update-config(){
sed -i "s/#cluster.name: my-application/cluster.name: elastic-cluster/g"  ~/elasticsearch/config/elasticsearch.yml
# 修改节点名称 （自定义）
sed -i "s/#node.name: node-1/node.name: $1/g"  ~/elasticsearch/config/elasticsearch.yml
# 修改数据地址
sed -i "s/#path.data: \/path\/to\/data/path.data: \/var\/lib\/elastic\/data/g"  ~/elasticsearch/config/elasticsearch.yml
# 修改日志地址
sed -i "s/#path.logs: \/path\/to\/logs/path.logs: \/var\/lib\/elastic\/log/g"  ~/elasticsearch/config/elasticsearch.yml
# 修改绑定IP
sed -i "s/#network.host: 192.168.0.1/network.host: 0.0.0.0/g"  ~/elasticsearch/config/elasticsearch.yml
# 关闭传输安全
echo -e "xpack.security.enabled: false\ningest.geoip.downloader.enabled: false
" >> ~/elasticsearch/config/elasticsearch.yml
sed -i "s/logs\/gc.log/\/var\/lib\/elastic\/log\/gc.log/g" ~/elasticsearch/config/jvm.options 
sed -i "s/HeapDumpPath=data/\HeapDumpPath=\/var\/lib\/elastic\/data/g" ~/elasticsearch/config/jvm.options 
sed -i "s/logs\/hs_err/\/var\/lib\/elastic\/log\/hs_err/g" ~/elasticsearch/config/jvm.options 
sed -i "s/-Djava.io.tmpdir/#-Djava.io.tmpdir/g" ~/elasticsearch/config/jvm.options 
}
update-config <NAME>
# 配置Master 节点
echo "cluster.initial_master_nodes: [\"<MASTER_NAME>\"]" >>  ~/elasticsearch/config/elasticsearch.yml

```

注意：防火墙需要放行 `9200/tcp`,`9300/tcp` 端口。

#### 配置开机自启

```bash
cat > /etc/systemd/system/elasticsearch.service << EOF
[Unit]
Description=Elastic Search Server
After=syslog.target
After=network.target
 
[Service]
LimitMEMLOCK=infinity
LimitNOFILE=65535
RestartSec=2s
Type=simple
User=elastic
WorkingDirectory=/var/lib/elastic/elasticsearch
ExecStart=/var/lib/elastic/elasticsearch/bin/elasticsearch
Restart=always
 
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
ps -ef | grep elasticsearch-8.0.1 | grep "elastic " | awk '{print $2}' | xargs kill
systemctl start elasticsearch.service
systemctl enable elasticsearch.service
systemctl status elasticsearch.service
```

#### 测试

 ```bash
 #获取所有节点
 curl -XGET "http://<MASTER_IP>:9200/_cat/nodes"   
 ```

## 入门



## 参考

- [ES 安装配置](https://www.elastic.co/guide/en/elasticsearch/reference/current/important-settings.html)
