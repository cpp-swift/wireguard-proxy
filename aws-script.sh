#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	printf 'Must be run as root, exiting!\n'
	exit 1
fi

# installing wireguard
echo "========================================"
echo "Installing Wireguard..."
echo "========================================"

sudo apt update
sudo apt install wireguard -y

# generating wireguard keys
echo "========================================"
echo "Generating Wireguard keys..."
echo "========================================"
(umask 077 && printf "[Interface]\nPrivateKey = " | sudo tee /etc/wireguard/wg0.conf > /dev/null)
wg genkey | sudo tee -a /etc/wireguard/wg0.conf | wg pubkey | sudo tee /etc/wireguard/publickey

# don't change these
echo "========================================"
echo "Editing /etc/wireguard/wg0.conf..."
echo "========================================"

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
echo "========================================"
echo "Starting Wireguard..."
echo "========================================"

sudo systemctl start wg-quick@wg0
sudo systemctl enable wg-quick@wg0

