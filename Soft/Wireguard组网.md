 

# Wireguard 组网

```bash
apt install ufw wireguard-tools -y
mkdir /etc/wireguard
KEY_PATH=/etc/wireguard/keys/wg0
mkdir -p $KEY_PATH
cd $KEY_PATH
wg genkey | tee wg_key | wg pubkey > wg_key.pub
wg genpsk > wg_key.psk
WG_KEY=$(cat wg_key)
WG_KEY_PUB=$(cat wg_key.pub)
WG_KEY_PSK=$(cat wg_key.psk)
cat << EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $WG_KEY
Address = 10.10.10.1/24
MTU = 1420
ListenPort = 3918
PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE

EOF
systemctl enable wg-quick@wg0
chmod -Rv 700 /etc/wireguard/
cat << EOF
[Peer]
PublicKey = $WG_KEY_PUB
AllowedIPs = 10.10.10.1/32
Endpoint = 0.0.0.0:3918
PersistentKeepalive = 25
EOF

sudo ufw allow in on wg0
```

