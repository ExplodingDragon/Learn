# 使用 Netboot 快速重装系统

## 引导文件下载地址

EFI: `https://boot.netboot.xyz/ipxe/netboot.xyz.efi`

lkrn: `https://boot.netboot.xyz/ipxe/netboot.xyz.lkrn`

```bash
INSTALL_PATH=/boot
BOOT_UUID=$(df $INSTALL_PATH --output=source,target | grep "dev" | head -n 1 | awk '{print $1}' |  xargs blkid --match-tag UUID --output value)
BOOT_ROOT_PATH=$(df --output=source,target  | grep `blkid --uuid $BOOT_UUID` | awk '{print $2}')
LOAD_PATH=`eval "echo $INSTALL_PATH | sed \"s#$BOOT_ROOT_PATH#/#\""`
wget https://boot.netboot.xyz/ipxe/netboot.xyz.efi -O $INSTALL_PATH/netboot.xyz.efi -c 
wget https://boot.netboot.xyz/ipxe/netboot.xyz.lkrn -O $INSTALL_PATH/netboot.xyz.lkrn -c 
cat << GRUB_END > /etc/grub.d/99_netboot
#!/bin/bash
cat << EOF
menuentry "[b] netboot.xyz" --hotkey=b {
    load_video
    insmod gzio
    if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi
    insmod part_msdos
    insmod ext2
    insmod xfs
    if [ x$feature_platform_search_hint = xy ]; then
        search --no-floppy --fs-uuid --set=root  $BOOT_UUID
    else
        search --no-floppy --fs-uuid --set=root $BOOT_UUID
    fi
	if [ "${grub_platform}" == "efi" ]; then
		chainloader $LOAD_PATH/netboot.xyz.efi
	else
		linux16 $LOAD_PATH/netboot.xyz.lkrn
	fi
}
EOF
GRUB_END
chmod +x /etc/grub.d/99_netboot
update-grub
```



## GRUB

```bash
### Start netboot.xyz
menuentry "[b] netboot.xyz" --hotkey=b {
    load_video
    insmod gzio
    if [ x$grub_platform = xxen ]; then insmod xzio; insmod lzopio; fi
    insmod part_msdos
    insmod ext2
    insmod xfs
    if [ x$feature_platform_search_hint = xy ]; then
        search --no-floppy --fs-uuid --set=root  c0b9ecd8-f922-4e5d-bccb-83fbc94ad23b
    else
        search --no-floppy --fs-uuid --set=root c0b9ecd8-f922-4e5d-bccb-83fbc94ad23b
    fi
	if [ "${grub_platform}" == "efi" ]; then
		chainloader /boot/netboot.xyz.efi
	else
		linux16 /boot/netboot.xyz.lkrn
	fi
}
### End netboot.xyz

```

其中：c0b9ecd8-f922-4e5d-bccb-83fbc94ad23b 是分区 UUID
