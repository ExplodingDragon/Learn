# Containerd 教程

> 此教程基于 `Debian bullseye`

## 安装

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sed "s#download.docker.com#mirrors.ustc.edu.cn/docker-ce#g" |  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install containerd -y
```

