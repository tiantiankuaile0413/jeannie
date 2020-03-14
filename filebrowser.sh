#!/bin/bash
curl -fsSL https://filebrowser.xyz/get.sh | bash
filebrowser -d /etc/filebrowser.db config init
filebrowser -d /etc/filebrowser.db config set --address 0.0.0.0
echo "请输入一个1-65535之间的端口号:"
read port
while [ $port -le 0 -o $port -gt 65535 ]
do
	echo "端口必须在1-65535之间。请重新输入:"
	read port
done
filebrowser -d /etc/filebrowser.db config set --port $port
filebrowser -d /etc/filebrowser.db config set --locale zh-cn
filebrowser -d /etc/filebrowser.db config set --log /var/log/filebrowser.log
filebrowser -d /etc/filebrowser.db config set --baseurl /manager
echo "输入用户名:"
read $user
echo "输入密码:"
read $pswd
echo "filebrowser -d /etc/filebrowser.db users add $user $pswd --perm.admin" > up.sh
chmod +x up.sh
./up.sh

echo "[Unit]
Description=File Browser
After=network.target

[Service]
ExecStart=/usr/local/bin/filebrowser -d /etc/filebrowser.db

[Install]
WantedBy=multi-user.target" > /lib/systemd/system/filebrowser.service
systemctl daemon-reload
systemctl stop filebrowser.service
systemctl start filebrowser.service
sed -i "14c proxy / 127.0.0.1:$port" /etc/caddy/Caddyfile 
supervisorctl restart caddy
echo "运行：systemctl start filebrowser.service
停止运行：systemctl stop filebrowser.service
开机启动：systemctl enable filebrowser.service
取消开机启动：systemctl disable filebrowser.service
查看运行状态：systemctl status filebrowser.service"


