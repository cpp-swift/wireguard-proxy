#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	printf 'Must be run as root, exiting!\n'
	exit 1
fi

read -sp 'Plase input the Wireguard public key of the on-prem server: ' PUB_KEY

sed -i "s/<insert-public-key-of-onprem>/$PUB_KEY/" /etc/wireguard/wg0.conf

systemctl restart wg-quick@wg0