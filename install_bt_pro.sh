#声明或公告

echo -e "\033[32m--------------------\033[0m"

echo -e "\033[32m--------------------\033[0m"

echo -e "\033[33m喜樂君脚本\033[0m"

echo -e "\033[34m专业版升级\033[0m"

echo -e "\033[34m已有宝塔环境可执行该脚本预计耗时 10秒\033[0m"

echo -e "\033[34m脚本开源\033[0m"

echo -e "\033[32m--------------------\033[0m"

echo -e "\033[32m--------------------\033[0m"

#回车进行该代码后的代码

read -p "继续(回车)" go;

#判断 usr/bin/unzip 文件是否存在

if [ ! -f "/usr/bin/unzip" ];then

	#rm -f /etc/yum.repos.d/epel.repo

		

	#不存在就进行安装

	yum install unzip -y

fi

#开始获取破解包

#解压下列文件夹目录

wget -O panel.zip https://raw.githubusercontent.com/wxilejun/bt-/master/panel.zip -T 10

wget -O /etc/init.d/bt $download_Url/install/src/bt.init -T 10

if [ -f "$setup_path/server/panel/data/default.db" ];then

	if [ -d "/$setup_path/server/panel/old_data" ];then

		rm -rf $setup_path/server/panel/old_data

	fi

	mkdir -p $setup_path/server/panel/old_data

	mv -f $setup_path/server/panel/data/default.db $setup_path/server/panel/old_data/default.db

	mv -f $setup_path/server/panel/data/system.db $setup_path/server/panel/old_data/system.db

	mv -f $setup_path/server/panel/data/aliossAs.conf $setup_path/server/panel/old_data/aliossAs.conf

	mv -f $setup_path/server/panel/data/qiniuAs.conf $setup_path/server/panel/old_data/qiniuAs.conf

	mv -f $setup_path/server/panel/data/iplist.txt $setup_path/server/panel/old_data/iplist.txt

	mv -f $setup_path/server/panel/data/port.pl $setup_path/server/panel/old_data/port.pl

fi

unzip -o panel.zip -d $setup_path/server/ > /dev/null

if [ -d "$setup_path/server/panel/old_data" ];then

	mv -f $setup_path/server/panel/old_data/default.db $setup_path/server/panel/data/default.db

	mv -f $setup_path/server/panel/old_data/system.db $setup_path/server/panel/data/system.db

	mv -f $setup_path/server/panel/old_data/aliossAs.conf $setup_path/server/panel/data/aliossAs.conf

	mv -f $setup_path/server/panel/old_data/qiniuAs.conf $setup_path/server/panel/data/qiniuAs.conf

	mv -f $setup_path/server/panel/old_data/iplist.txt $setup_path/server/panel/data/iplist.txt

	mv -f $setup_path/server/panel/old_data/port.pl $setup_path/server/panel/data/port.pl

	

	if [ -d "/$setup_path/server/panel/old_data" ];then

		rm -rf $setup_path/server/panel/old_data

	fi

fi

rm -f panel.zip

if [ ! -f $setup_path/server/panel/tools.py ];then

	echo -e "\033[31mERROR: Failed to download, please try again!\033[0m";

	echo '============================================'

	exit;

fi

rm -f $setup_path/server/panel/class/*.pyc

rm -f $setup_path/server/panel/*.pyc

python -m compileall $setup_path/server/panel

#rm -f $setup_path/server/panel/class/*.py

#rm -f $setup_path/server/panel/*.py

rm -f /dev/shm/session.db

chmod +x /etc/init.d/bt

chkconfig --add bt

chkconfig --level 2345 bt on

chmod -R 600 $setup_path/server/panel

chmod +x $setup_path/server/panel/certbot-auto

chmod -R +x $setup_path/server/panel/script

ln -sf /etc/init.d/bt /usr/bin/bt

echo "$port" > $setup_path/server/panel/data/port.pl

/etc/init.d/bt start

password=`cat /dev/urandom | head -n 16 | md5sum | head -c 8`

cd $setup_path/server/panel/

python tools.py username

username=`python tools.py panel $password`

cd ~

echo "$password" > $setup_path/server/panel/default.pl

chmod 600 $setup_path/server/panel/default.pl

isStart=`ps aux |grep 'python main.pyc'|grep -v grep|awk '{print $2}'`

if [ "$isStart" == '' ];then

	echo -e "\033[31mERROR: The BT-Panel service startup failed.\033[0m";

	echo '============================================'

	exit;

fi

if [ -f "/etc/init.d/iptables" ];then

	sshPort=`cat /etc/ssh/sshd_config | grep 'Port ' | grep -oE [0-9] | tr -d '\n'`

	if [ "${sshPort}" != "22" ]; then

		iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport $sshPort -j ACCEPT

	fi

	iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 20 -j ACCEPT

	iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 21 -j ACCEPT

	iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT

	iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT

	iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport $port -j ACCEPT

	iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 39000:40000 -j ACCEPT

	#iptables -I INPUT -p tcp -m state --state NEW -m udp --dport 39000:40000 -j ACCEPT

	iptables -A INPUT -p icmp --icmp-type any -j ACCEPT

	iptables -A INPUT -s localhost -d localhost -j ACCEPT

	iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

	iptables -P INPUT DROP

	service iptables save

	sed -i "s#IPTABLES_MODULES=\"\"#IPTABLES_MODULES=\"ip_conntrack_netbios_ns ip_conntrack_ftp ip_nat_ftp\"#" /etc/sysconfig/iptables-config

	iptables_status=`service iptables status | grep 'not running'`

	if [ "${iptables_status}" == '' ];then

		service iptables restart

	fi

fi

if [ "${isVersion}" == '' ];then

	if [ ! -f "/etc/init.d/iptables" ];then

		sshPort=`cat /etc/ssh/sshd_config | grep 'Port ' | grep -oE [0-9] | tr -d '\n'`

		yum install firewalld -y

		systemctl enable firewalld

		systemctl start firewalld

		firewall-cmd --set-default-zone=public > /dev/null 2>&1

		if [ "${sshPort}" != "22" ]; then

			firewall-cmd --permanent --zone=public --add-port=$sshPort/tcp > /dev/null 2>&1

		fi

		firewall-cmd --permanent --zone=public --add-port=20/tcp > /dev/null 2>&1

		firewall-cmd --permanent --zone=public --add-port=21/tcp > /dev/null 2>&1

		firewall-cmd --permanent --zone=public --add-port=22/tcp > /dev/null 2>&1

		firewall-cmd --permanent --zone=public --add-port=80/tcp > /dev/null 2>&1

		firewall-cmd --permanent --zone=public --add-port=$port/tcp > /dev/null 2>&1

		firewall-cmd --permanent --zone=public --add-port=39000-40000/tcp > /dev/null 2>&1

		#firewall-cmd --permanent --zone=public --add-port=39000-40000/udp > /dev/null 2>&1

		firewall-cmd --reload

	fi

fi

pip install psutil chardet web.py psutil virtualenv cryptography==2.1 > /dev/null 2>&1

if [ ! -d '/etc/letsencrypt' ];then

	yum install epel-release -y

	if [ "${country}" = "CN" ]; then

		isC7=`cat /etc/redhat-release |grep ' 7.'`

		if [ "${isC7}" == "" ];then

			wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo

		else

			wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

		fi

	fi

	mkdir -p /var/spool/cron

	if [ ! -f '/var/spool/cron/root' ];then

		echo '' > /var/spool/cron/root

		chmod 600 /var/spool/cron/root

	fi

fi

wget -O acme_install.sh $download_Url/install/acme_install.sh

nohup bash acme_install.sh &> /dev/null &

sleep 1

rm -f acme_install.sh

address=""

address=`curl -sS --connect-timeout 10 -m 60 https://www.bt.cn/Api/getIpAddress`

if [ "$address" == '0.0.0.0' ] || [ "$address" == '' ];then

	isHosts=`cat /etc/hosts|grep 'www.bt.cn'`

	if [ "$isHosts" == '' ];then

		echo "" >> /etc/hosts

		echo "125.88.182.170 www.bt.cn" >> /etc/hosts

		address=`curl -sS --connect-timeout 10 -m 60 https://www.bt.cn/Api/getIpAddress`

		if [ "$address" == '' ];then

			sed -i "/bt.cn/d" /etc/hosts

		fi

	fi

fi

ipCheck=`python -c "import re; print re.match('^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$','$address')"`

if [ "$ipCheck" == "None" ];then

	address="SERVER_IP"

fi

if [ "$address" != "SERVER_IP" ];then

	echo "$address" > $setup_path/server/panel/data/iplist.txt

fi

curl -sS --connect-timeout 10 -m 60 https://www.bt.cn/Api/SetupCount?type=Linux\&o=$1 > /dev/null 2>&1

if [ "$1" != "" ];then

	echo $1 > /www/server/panel/data/o.pl

	cd /www/server/panel

	python tools.py o

fi

#安装成功

echo -e "\033[32m恭喜宝塔专业版环境安装成功\033[0m"

echo  "宝塔控制面板: http://$address:$port"

echo -e "用户名: $username"

echo -e "密码: $password"

echo -e "\033[33m提示\033[0m"

echo -e "\033[33m安装完成还是打不开控制面板请放行以下端口\033[0m"

echo -e "\033[33m(8888|888|80|443|20|21) 问题还是无法解决?交流群461909009\033[0m"

#重启控制面板

service bt restart

endTime=`date +%s`

((outTime=($endTime-$startTime)/60))

echo -e "安装耗时:\033[32m $outTime \033[0m分钟"

#删除所执行脚本用户下载的bash文件

rm -f install_bt_pro.sh
