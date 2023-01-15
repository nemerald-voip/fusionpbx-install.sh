#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"


#add the includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#send a message
verbose "Configuring IPTables"

#defaults to nftables by default this enables iptables
if [ ."$os_codename" = ."buster" ]; then
        update-alternatives --set iptables /usr/sbin/iptables-legacy
        update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
fi
if [ ."$os_codename" = ."bullseye" ]; then
	apt-get install -y iptables
	update-alternatives --set iptables /usr/sbin/iptables-legacy
	update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
fi

#remove ufw
ufw reset
ufw disable
apt-get remove -y ufw
#apt-get purge ufw

#run iptables commands
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -j DROP -p udp --dport 35000:36000 -m string --string "friendly-scanner" --algo bm --icase
iptables -A INPUT -j DROP -p tcp --dport 35001:36001 -m string --string "friendly-scanner" --algo bm --icase
iptables -A INPUT -j DROP -p udp --dport 35000:36000 -m string --string "sipcli/" --algo bm --icase
iptables -A INPUT -j DROP -p tcp --dport 35001:36001 -m string --string "sipcli/" --algo bm --icase
iptables -A INPUT -j DROP -p udp --dport 35000:36000 -m string --string "VaxSIPUserAgent/" --algo bm --icase
iptables -A INPUT -j DROP -p tcp --dport 35001:36001 -m string --string "VaxSIPUserAgent/" --algo bm --icase
iptables -A INPUT -j DROP -p udp --dport 35000:36000 -m string --string "pplsip" --algo bm --icase
iptables -A INPUT -j DROP -p tcp --dport 35001:36001 -m string --string "pplsip" --algo bm --icase
iptables -A INPUT -j DROP -p udp --dport 35000:36000 -m string --string "system " --algo bm --icase
iptables -A INPUT -j DROP -p tcp --dport 35001:36001 -m string --string "system " --algo bm --icase
iptables -A INPUT -j DROP -p udp --dport 35000:36000 -m string --string "exec." --algo bm --icase
iptables -A INPUT -j DROP -p tcp --dport 35001:36001 -m string --string "exec." --algo bm --icase
iptables -A INPUT -j DROP -p udp --dport 35000:36000 -m string --string "multipart/mixed;boundary" --algo bm --icase
iptables -A INPUT -j DROP -p tcp --dport 35001:36001 -m string --string "multipart/mixed;boundary" --algo bm --icase
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 7443 -j ACCEPT
iptables -A INPUT -p tcp --dport 35001 -j ACCEPT
iptables -A INPUT -p tcp --dport 36001 -j ACCEPT
iptables -A INPUT -p tcp --dport 36003 -j ACCEPT
iptables -A INPUT -p udp --dport 35002 -j ACCEPT
iptables -A INPUT -p udp --dport 35000 -j ACCEPT
iptables -A INPUT -p udp --dport 36000 -j ACCEPT
iptables -A INPUT -p udp --dport 16384:32768 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p udp --dport 1194 -j ACCEPT
iptables -t mangle -A OUTPUT -p udp -m udp --sport 16384:32768 -j DSCP --set-dscp 46
iptables -t mangle -A OUTPUT -p udp -m udp --sport 35000:36000 -j DSCP --set-dscp 26
iptables -t mangle -A OUTPUT -p tcp -m tcp --sport 35001:36001 -j DSCP --set-dscp 26
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

#Allow connection from Thinq:
iptables -A INPUT -p udp --dport 35000 -s 192.81.236.20/32 -j ACCEPT
iptables -A INPUT -p udp --dport 35000 -s 192.81.237.20/32 -j ACCEPT

#Allow connection from Peerless:
iptables -A INPUT -p udp --dport 35000 -s 207.223.73.201/32 -j ACCEPT
iptables -A INPUT -p udp --dport 35000 -s 208.51.154.71/32 -j ACCEPT
iptables -A INPUT -p udp --dport 35000 -s 207.223.71.227/32 -j ACCEPT
iptables -A INPUT -p udp --dport 35000 -s 208.79.55.168/32 -j ACCEPT
iptables -A INPUT -p udp --dport 35000 -s 208.93.43.141/32 -j ACCEPT

#Allow connection from API server:
iptables -A INPUT -p tcp --dport 5432 -s 54.218.160.40/32 -j ACCEPT

#Allow connection from redundant database
iptables -A INPUT -p tcp --dport 5432 -s 50.116.25.52/32 -j ACCEPT
iptables -A INPUT -p tcp --dport 5432 -s 45.76.175.117/32 -j ACCEPT
iptables -A INPUT -p tcp --dport 5432 -s 66.42.110.158/32 -j ACCEPT
iptables -A INPUT -p tcp --dport 5432 -s 50.116.24.160/32 -j ACCEPT


#answer the questions for iptables persistent
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt-get install -y iptables-persistent



