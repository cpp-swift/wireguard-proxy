#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	printf 'Must be run as root, exiting!\n'
	exit 1
fi

# installing wireguard
echo "========================================"
echo "Installing Wireguard..."

sudo apt update
sudo apt install wireguard -y

# generating wireguard keys
echo "Generating Wireguard keys..."
(umask 077 && printf "[Interface]\nPrivateKey = " | sudo tee /etc/wireguard/wg0.conf > /dev/null)

echo "========================================"
wg genkey | sudo tee -a /etc/wireguard/wg0.conf | wg pubkey | sudo tee /etc/wireguard/publickey
echo "========================================"

# don't change these
echo "This is your public key! Copy it and save it somewhere!"
printf "\n"
echo "Editing /etc/wireguard/wg0.conf..."

WG_CONF="/etc/wireguard/wg0.conf"
PUB_KEY=$(cat /etc/wireguard/publickey)

# you can change these to your liking
LISTEN_PORT="55107"
IP_ADDR="192.168.4.1"
ALLOWED_IPS="192.168.4.2/32"

# editing /etc/wireguard/wg0.conf file...
echo "ListenPort = $LISTEN_PORT" >> $WG_CONF
echo "Address = $IP_ADDR" >> $WG_CONF
echo "[Peer]" >> $WG_CONF
echo "PublicKey = $PUB_KEY" >> $WG_CONF
echo "AllowedIPs = $ALLOWED_IPS" >> $WG_CONF

# starting wireguard...
echo "Starting Wireguard..."

sudo systemctl start wg-quick@wg0
sudo systemctl enable wg-quick@wg0