#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	printf 'Must be run as root, exiting!\n'
	exit 1
fi

read -p 'Please input the port number you want Wireguard to listen on: ' LISTEN_PORT

# installing wireguard
printf '\n'
echo "============================================"
echo "Installing Wireguard..."

apt update
apt install wireguard -y

# generating wireguard keys
echo "Generating Wireguard keys..."
(umask 077 && printf "[Interface]\nPrivateKey = " | sudo tee /etc/wireguard/wg0.conf > /dev/null)

printf "\n"
echo "============================================"
wg genkey | sudo tee -a /etc/wireguard/wg0.conf | wg pubkey | sudo tee /etc/wireguard/publickey
echo "============================================"

# don't change these
echo "This is your public key! Copy it and save it somewhere!"
printf "\n"
echo "Editing /etc/wireguard/wg0.conf..."

WG_CONF="/etc/wireguard/wg0.conf"

# you can change these to your liking
IP_ADDR="192.168.4.1"
ALLOWED_IPS="192.168.4.2/32"

# editing /etc/wireguard/wg0.conf file...
echo "ListenPort = $LISTEN_PORT" >> $WG_CONF
echo "Address = $IP_ADDR" >> $WG_CONF
echo "[Peer]" >> $WG_CONF
echo "PublicKey = <insert-public-key-of-onprem>" >> $WG_CONF
echo "AllowedIPs = $ALLOWED_IPS" >> $WG_CONF

# starting wireguard...
echo "Starting Wireguard..."

systemctl start wg-quick@wg0
systemctl enable wg-quick@wg0

printf '\n'
echo "============================================"
echo "Please run onprem-wg.sh on the on-prem server..."
read -sp 'Please input the Wireguard public key of the on-prem server: ' PUB_KEY

sed -i "s/<insert-public-key-of-onprem>/$PUB_KEY/" $WG_CONF

systemctl restart wg-quick@wg0

