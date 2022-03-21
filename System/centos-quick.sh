#!/bin/bash

# 此脚本仅针对创智和宇 Cent0S 7.x 服务器使用

# 磁盘扩容
pvcreate /dev/sdb
vgextend centos /dev/sdb
lvextend  -l +100%FREE /dev/mapper/centos-root
xfs_growfs /dev/mapper/centos-root 

# 重置SSH密钥
rm -f /etc/ssh/ssh_host_*
sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
systemctl restart sshd
cat > ~/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQC4DdxMafiZg6yJtsAGfjsGAXfBFLFq3n6tyFV4bNKgyYbNhT/IgXa+gr/feObkGJT+ge6JHuoADnFqKcFC/gb8V+wONBKz3y007EIadasQowau0ufCQxCS8T1WpmDDeV4L5SI9ui/vAN7JdI3CaN1WjF6NI/+Y0v+KruGptR80gl0otgkG4DUb380enNAhsDNyRWXokA/hrUrdKhyYE06+keUtcmGFAPc7xjhEdO/u9EkgCRQshAqyc7s/EOldKi5fWpdgAoye6znwcxt9o5ihzmOlA94SIxQCd6qoVkG5+Y7jIHUbhv/DBlv7smkWkA2POKv4fTPPtUM3nD6vJExIGVa6G8qUh+XnZZA+SYhfpMk8Qi7YHWAj+OixJH3/axZo0Jdxg+FfJJempKcN4EryKd+YVJ3ElEiD0rbKbngLclP93KnhpqZI2vJXQZqPGfYz34PETjV7ExjWacyEYIrk/VnKaG5AZ8GzIcxxhRFo/vNFGRqFnSkXEqLW0oHuUmPqmP077r1k8dTtWFuJ53XZ2XwwSiegWHnAWwzLFO1YyIHRa49jfgBUFlR7kIZj3aiKhQqxOPHA2x+8XxOJyGNFbx+WBufWBoi5ehQpkSxOaPhuXuei54qGlNOHz+0cIuPxeGdaScIlBCiR2wcIZtwTgy4QHCD2UVPm50+L13Y2/sXuD+BTTQ0mwR22j8cgObHxhouE8rJgPD7dqKCRAz7kn8GpYhqjMFhzBzpz9ymV9UMvFgErfF1YVhrWWD02uyTcVT3W4DLbnx/LiJxugXIAxNhpxQqF48I5QJE0PliJAWRULpo8D5UHUjmZVEcfsrMHKLUHfn2poz100VicJRenZozD2g5vbzfcfJ8ZXN+IQDcbjT+vhvFQN5EacizAxd3viRDZR/akQWVMmBBVlcEZMhvdkp1sG8lA5T4LSDqLcOfKBhNrg8DITg5fSTp8rWUBdDflJfu5ZE4HTQ9wtObhPX0YrD0U0HPEvV8T8gqZIYzQiZk0k80qz6stKdHCx8IHtU00dthS/Kmgq/Nepv2aqAsTcz53SyuRw3il7aS341SvNhKRUX7WlWnefJGu1Ijhh2fUPlPGiDbWoXFeRQ1xTG9I3ICuWTV+njRpWeGG7sKvN/3/PEl821hHNC2q6XQqjiMzGTh3SjaBKrByoicyKSMa1x/mePRsN72Ob0J7P0On6owdTo83LSGNFrHCs/XfXOIO4RH6UgQRVUfV6FRlmH1yk/DWHIPHywn/30DF6GJvergAw5tF7xXTHTV/W0ieai4BjAZo/c/JFfAKe4TRszO7uhL6qrYJvkGuIqpMHM3lJJOYF2EWzmlEsD7OU/xS2A7FhW0AntWnvNORPo3r public-key
EOF
ssh-keygen -t rsa -b 4096