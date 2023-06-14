dpkg -i /media/*.deb

# 更换源
echo '' > /etc/apt/sources.list
echo 'deb http://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb http://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb http://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb http://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb [trusted=yes] http://mirrors.unilake.net/unilake/ubuntu/jammy/ ./' > /etc/apt/sources.list.d/unilake.list

echo 'nameserver 223.5.5.5' > /etc/resolv.conf
ip a

# 安装指定包
apt update && apt install -y apt-utils frr iproute2 ipset dnsmasq python3 tini curl ca-certificates apt-transport-https sudo uuid-runtime jq iputils-ping \
 frr-pythontools vim
