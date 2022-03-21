# Debian 命令 / 配置 记录

> 测试的 Debian 版本为 `debian bullseye`

## 安装后配置

### 部署公钥

```bash
mkdir .ssh
chmod 600 .ssh
cat << EOF >> ~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQC4DdxMafiZg6yJtsAGfjsGAXfBFLFq3n6tyFV4bNKgyYbNhT/IgXa+gr/feObkGJT+ge6JHuoADnFqKcFC/gb8V+wONBKz3y007EIadasQowau0ufCQxCS8T1WpmDDeV4L5SI9ui/vAN7JdI3CaN1WjF6NI/+Y0v+KruGptR80gl0otgkG4DUb380enNAhsDNyRWXokA/hrUrdKhyYE06+keUtcmGFAPc7xjhEdO/u9EkgCRQshAqyc7s/EOldKi5fWpdgAoye6znwcxt9o5ihzmOlA94SIxQCd6qoVkG5+Y7jIHUbhv/DBlv7smkWkA2POKv4fTPPtUM3nD6vJExIGVa6G8qUh+XnZZA+SYhfpMk8Qi7YHWAj+OixJH3/axZo0Jdxg+FfJJempKcN4EryKd+YVJ3ElEiD0rbKbngLclP93KnhpqZI2vJXQZqPGfYz34PETjV7ExjWacyEYIrk/VnKaG5AZ8GzIcxxhRFo/vNFGRqFnSkXEqLW0oHuUmPqmP077r1k8dTtWFuJ53XZ2XwwSiegWHnAWwzLFO1YyIHRa49jfgBUFlR7kIZj3aiKhQqxOPHA2x+8XxOJyGNFbx+WBufWBoi5ehQpkSxOaPhuXuei54qGlNOHz+0cIuPxeGdaScIlBCiR2wcIZtwTgy4QHCD2UVPm50+L13Y2/sXuD+BTTQ0mwR22j8cgObHxhouE8rJgPD7dqKCRAz7kn8GpYhqjMFhzBzpz9ymV9UMvFgErfF1YVhrWWD02uyTcVT3W4DLbnx/LiJxugXIAxNhpxQqF48I5QJE0PliJAWRULpo8D5UHUjmZVEcfsrMHKLUHfn2poz100VicJRenZozD2g5vbzfcfJ8ZXN+IQDcbjT+vhvFQN5EacizAxd3viRDZR/akQWVMmBBVlcEZMhvdkp1sG8lA5T4LSDqLcOfKBhNrg8DITg5fSTp8rWUBdDflJfu5ZE4HTQ9wtObhPX0YrD0U0HPEvV8T8gqZIYzQiZk0k80qz6stKdHCx8IHtU00dthS/Kmgq/Nepv2aqAsTcz53SyuRw3il7aS341SvNhKRUX7WlWnefJGu1Ijhh2fUPlPGiDbWoXFeRQ1xTG9I3ICuWTV+njRpWeGG7sKvN/3/PEl821hHNC2q6XQqjiMzGTh3SjaBKrByoicyKSMa1x/mePRsN72Ob0J7P0On6owdTo83LSGNFrHCs/XfXOIO4RH6UgQRVUfV6FRlmH1yk/DWHIPHywn/30DF6GJvergAw5tF7xXTHTV/W0ieai4BjAZo/c/JFfAKe4TRszO7uhL6qrYJvkGuIqpMHM3lJJOYF2EWzmlEsD7OU/xS2A7FhW0AntWnvNORPo3r my-pulic-key
EOF
```



### 修改 APT 源

由于官方源速度太慢，现使用 [中科大](https://mirrors.ustc.edu.cn/) 提供的镜像，或者可以使用 `ftp.cn.debian.org` 。

```bash
cat << EOF | sed "s@deb-src@# deb-src@g" > /etc/apt/sources.list
deb https://mirrors.ustc.edu.cn/debian/ bullseye main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ bullseye main contrib non-free

deb https://mirrors.ustc.edu.cn/debian/ bullseye-updates main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ bullseye-updates main contrib non-free

deb https://mirrors.ustc.edu.cn/debian/ bullseye-backports main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ bullseye-backports main contrib non-free

deb https://mirrors.ustc.edu.cn/debian-security/ bullseye-security main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian-security/ bullseye-security main contrib non-free
EOF
```

### 配置 OpenSSH

 ```bash
 cat << EOF > /etc/ssh/sshd_config.d/security.conf
 # 开启公钥
 PubkeyAuthentication yes
 # 指定公钥位置
 AuthorizedKeysFile     .ssh/authorized_keys
 # 关闭密码登陆
 PasswordAuthentication no
 EOF
 systemctl restart ssh
 ```

### 配置 防火墙

```bash
apt install ufw -y
ufw default deny
ufw allow ssh 
# 放行服务
ufw allow 80,443/tcp
# 放行端口
 ufw enable
```

