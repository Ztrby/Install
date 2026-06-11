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

# Do everything with nix done
PUBKEY="$HOME/.ssh/id_ed25519_sk.pub"
if [[ ! -f "$PUBKEY" ]]; then
	echo "make kubikey ssh"
	# nix-shell  -p git
	echo "You need to have your yubikey connected"
	ssh-keygen -t ed25519-sk -C "jonas.e.strom@gmail.com"
fi
echo "Trying ssh connection to github"
echo "If your yubikey start to blink you have to touch it"

if ssh -T git@github.com 2>&1 | grep -q "Hi Ztrby"; then
	echo "You have access to private github"
else
	echo "You can't connact to private github, make sure this key is added to github SSH, PGP"
	cat $HOME/.ssh/id_ed25519_sk.pub
fi
