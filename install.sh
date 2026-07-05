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

# Install ssh keys to github, config fil
PUBKEY="$HOME/.ssh/id_ed25519_sk_rk.pub"
if [[ ! -f "$PUBKEY" ]]; then
	cp config "$HOME/.ssh/"
	echo "make kubikey ssh"
	echo "You need to have your yubikey connected"
	cd "$HOME/.ssh/"
	ssh-keygen -K
fi
echo "Trying ssh connection to github"
echo "If your yubikey start to blink you have to touch it"

if ssh -T git@github.com 2>&1 | grep -q "Hi Ztrby"; then
	echo "You have access to private github"
	mkdir "$HOME/.dotfiles"
	cd "$HOME/.dotfiles"
	nix run nixpkgs#git -- clone git@github.com:Ztrby/dotfiles.git .
	
else
	echo "You can't connact to private github, make sure this key is added to github SSH, PGP"
	cat $HOME/.ssh/id_ed25519_sk_rk.pub
fi

# IF the cloning of the repository was done, run home-manager
FLAKEFILE="$HOME/.dotfiles/flake.nix"
if [[ -f "$FLAKEFILE" ]]; then
	echo "Run home-manager"
	nix run nixpkgs#home-manager -- switch --flake "$HOME/.dotfiles" -b backup
	else
	echo "Cloning of dotfiles was not done"
	fi
