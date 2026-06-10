#!/bin/bash

# Mitt installationskript

echo "----- Installation av system ------"

# Installation av netbird
echo "check if netbird is installed"
if ! command -v "netbird"  &> /dev/null; then
	echo "netbird is missing and being installed"
	sudo curl -fsSL https://pkgs.netbird.io/install.sh | sh
	read -p "Netbird setup-key: " SETUPKEY
	netbird up --setup-key $SETUPKEY
else
	echo "netbird already installed"
fi
# Installation av nix
echo "check if nix is installed"
if ! command -v "nix"  &> /dev/null; then
	echo "nix is missing and being installed"
	sudo curl -fsSL https://install.determinate.systems/nix | sh -s -- install
else
	echo "nix already installed"
fi

# Add my phones wifi
if sudo netplan get network.wifis.wlan0.access-points."Jonastelefon" > /dev/null 2>&1; then
	echo "Network Jonastelefon exist"
else
	echo "Network Jonas telefonfon does not exist"
	read -p "Password to wifi Jonastelefon: " WIFIPASSWORD
	echo "make wifi"
	sudo netplan set  network.wifis.wlan0.access-points."Jonastelefon".password="$WIFIPASSWORD"
	echo "apply wifi"
	sudo netplan apply
fi

#echo "make kubikey ssh"
#nix-shell  -p git
#ssh-keygen -t ed25519-sk -C "jonas.e.strom@gmail.com"
