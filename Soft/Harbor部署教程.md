# Harbor 部署教程

 ## 密钥生成

```bash
mkdir -p /data/certs
cd /data/certs
# 配置地址
export CERT_HOST=harbor.pcloud.com
# 生成CA证书
openssl genrsa -out ca.key 4096
# 生成证书
openssl req -x509 -new -nodes -sha512 -days 3650  -subj "/CN=$CERT_HOST"  -key ca.key  -out ca.crt
# 生成服务器证书
# 创建私钥
openssl genrsa -out server.key 4096
# 生成证书签名请求
openssl req  -new -sha512  -subj "/CN=$CERT_HOST"  -key server.key  -out server.csr
# 生成harbor仓库主机的证书
cat > v3.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth 
subjectAltName = @alt_names
[alt_names]
DNS.1=$CERT_HOST
EOF
openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in server.csr \
    -out server.crt
cat << EOF
编辑文件 ~/harbor/harbor.yml,修改 https 配置如下 

hostname: $CERT_HOST
https:
  port: 443
  certificate: /data/certs/server.crt
  private_key: /data/certs/server.key
  
EOF
```

### 保存证书至 Docker

```bash
# 配置域名到 IP 的映射
export CERT_HOST=harbor.pcloud.com
echo "192.168.40.1    harbor.pcloud.com" >> /etc/hosts
# 部署公钥到 docker
mkdir -p "/etc/docker/certs.d/$CERT_HOST/"
cat << EOF > /etc/docker/certs.d/$CERT_HOST/server.crt 
<文件 /data/certs/server.crt> 内容
EOF

```

```bash
docker-compose up -d
```





