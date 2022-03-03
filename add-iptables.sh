#!/bin/bash

read -p "Are you NOW ready for iptables? (Y/N): " $IPTABLES

iptables() {

	read "Please input the port you want to open: " $FORWARD_PORT

	echo "Creating default rule..."
    iptables -F
    iptables -F -t nat
	iptables -P FORWARD DROP

	echo "Allowing port $FORWARD_PORT..."
	iptables -A FORWARD -i eth0 -o wg0 -p tcp --syn --dport $FORWARD_PORT -m conntrack --ctstate NEW -j ACCEPT
	iptables -A FORWARD -i eth0 -o wg0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
	iptables -A FORWARD -i wg0 -o eth0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

	echo "Creating PREROUTING/POSTROUTING rules..."
	sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport $FORWARD_PORT -j DNAT --to-destination 192.168.4.2
	sudo iptables -t nat -A POSTROUTING -o wg0 -p tcp --dport $FORWARD_PORT -d 192.168.4.2 -j SNAT --to-source 192.168.4.1

	echo "Saving rules..."
	netfilter-persistent save
	systemctl enable netfilter-persistent

	printf '\n'
	echo "Finished! Please make sure that you modify your firewall rules!"
}

if [ "$IPTABLES" == "Y" ]; then
	iptables()
else
    printf '\nI will assume that you are not ready for iptables. WEAK! QUITTING!\n'
fi