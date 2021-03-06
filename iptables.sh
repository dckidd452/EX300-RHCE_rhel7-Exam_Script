#/bin/bash
systemctl disable firewalld
systemctl stop firewalld
systemctl enable iptables
systemctl start iptables


i=$(which iptables)

$i -F
$i -t nat -F
$i -P INPUT DROP
$i -P FORWARD ACCEPT
$i -P OUTPUT ACCEPT


$i -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
$i -t nat -A PREROUTING -i eth0 -p tcp --dport 8080 -j DNAT --to 172.25.16.11:22 ##port forward
$i -A INPUT -p icmp -j ACCEPT
$i -A INPUT -i lo -j ACCEPT
$i -A INPUT -p tcp --dport 2049  -j ACCEPT	##NFS4 Allow
$i -A INPUT -p tcp --dport 3260  -j ACCEPT	##ISCSI Allow
$i -A INPUT -p tcp --dport 137  -j ACCEPT	##NETBIOS Allow
$i -A INPUT -p tcp --dport 138  -j ACCEPT	##NETBIOS Allow
$i -A INPUT -p tcp --dport 139  -j ACCEPT	##NETBIOS Allow
$i -A INPUT -p tcp --dport 445  -j ACCEPT	##NETBIOS Allow
$i -A INPUT -p tcp --dport 80  -j ACCEPT	##http Allow
$i -A INPUT -p tcp --dport 443  -j ACCEPT	##https Allow
$i -A INPUT -p tcp --dport 3306  -j ACCEPT	##mysql Allow
$i -A INPUT -p tcp -s 192.168.0.0/24 --dport 22 -j DROP ##Restrict SSH
$i -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
$i -A INPUT -j REJECT --reject-with icmp-host-prohibited
$i -A FORWARD -j REJECT --reject-with icmp-host-prohibited


$i"-save" > /etc/sysconfig/iptables
systemctl restart iptables
$i -nvL
$i -nvL -t nat
