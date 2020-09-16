#!/bin/sh

ALL=0
SFML=0
DEPS=0
BLIH=0
EPIMACS=0

show_help() {
	echo "-a Rebuild the whole Epitech's dump it ignores every other flags except -h and fails if one flag is false"
	echo "-s Rebuild the CSFML with Epitech's script and update SFML with dnf"
	echo "-d Update / Install the packages of Epitech's package list"
	echo "-b Reinstall blih with Epitech's script"
	echo "-e Install Emacs with dnf and Epitech Emacs (SYSTEM Install) with Epitech's script"
	echo "-h Show the help ignore all other flags and exit"
	echo "Writing epidump_manager -sddbees for example will be counted as epidump_manager -sdbe"
}

check_for_errors() {
	if [ -z "$1" ]; then
		echo "Missing argument"
		show_help
		exit 1
	fi

	if [ ! -f "/usr/bin/git" ]; then
		sudo dnf install -y git
		if [ ! -f "/usr/bin/git" ]; then
			echo "Could not find git which is required for most of the commands"
		fi
	fi
}

rebuild_all() {
	git clone https://github.com/Epitech/dump dump
	cd dump
	chmod +x install_packages_dump.sh
	sudo ./install_packages_dump.sh
}

dependencies_installer() {
	rpm --import https://packages.microsoft.com/keys/microsoft.asc
	sh -c 'echo -e "[teams]\nname=teams\nbaseurl=https://packages.microsoft.com/yumrepos/ms-teams\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/teams.repo'
	sudo dnf -y install dnf-plugins-core && dnf -y copr enable petersen/stack2 && dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

	sudo dnf upgrade -y
	
	local packages=$(curl https://raw.githubusercontent.com/Epitech/dump/master/install_packages_dump.sh | grep -oPz 'packages_list=\(\K[^\)]+')

	if [ -z "$packages" ]; then
    		echo "Could not get the package list" 2>&1
    		echo "Please report it to the repo manager by creating an issue" 2>&1
   		exit 1
	fi

	sudo dnf -y install $packages
}

rebuild_sfml_plus_csfml() {
	sudo dnf install -y SFML.x86_64 SFML-devel.x86_64
	if [ ! -d "/usr/include/SFML/" ]; then
		echo -e "There is two possibilities : \n\t- SFML is not installed in the default path\n\t- SFML is not installed\nAborting..."
		exit 1
	fi
	sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/Epitech/dump/master/build_csfml.sh)" || echo "There has been an error while building csfml"
}

blih_installer() {
	curl -LO https://raw.githubusercontent.com/Epitech/dump/master/blih.py
	if [ ! -f "blih" ]; then
		echo "Could not download blih... Aborting..."
		exit 1
	fi
	chmod +x blih.py
	sudo rm -rf /usr/bin/blih
	sudo mv blih.py /usr/bin/blih
}

reinstall_epitech_emacs() {
	sudo dnf install -y emacs
	if [ ! -f "/usr/bin/emacs" ]; then
		echo "Could not install emacs... Aborting..."
		exit 1
	fi
	git clone https://github.com/Epitech/epitech-emacs.git
	if [ ! -d "epitech-emacs" ]; then
		echo "Could not download epitech-emacs... Aborting..."
		exit 1
	fi
	cd epitech-emacs
	git checkout 278bb6a630e6474f99028a8ee1a5c763e943d9a3
	sudo ./INSTALL.sh system
	cd .. && rm -rf epitech-emacs
}

launch() {
	if [ "$ALL" == 1 ]; then
		echo "Reinstalling completely epitech dump"
		rebuild_all
		exit 0
	fi
	if [ "$SFML" == 1 ]; then
		echo "Rebuilding / Installing SFML + CSFML"
		rebuild_sfml_plus_csfml
	fi
	if [ "$DEPS" == 1 ]; then
		echo "Installing / Updating dump dependencies"
		dependencies_installer
	fi
	if [ "$BLIH" == 1 ]; then
		echo "Installing / Reinstalling  blih"
		blih-installer
	fi
	if [ "$EPIMACS" == 1 ]; then
		echo "Installing / Reinstalling epitech emacs"
		reinstall-epitech-emacs
	fi
}

parse_argument() {
	while getopts "asdbe:h:" opt; do
		case "$opt" in
			a)
				ALL=1
				;;
			s)
				SFML=1
				;;
			d)
				DEPS=1
				;;
			b)
				BLIH=1
				;;
			e)
				EPIMACS=1
				;;
			h)
				show_help;
				exit 0
				;;
			*)
				echo "Did not recognized argument showing help";
				show_help;
				exit 1
				;;
		esac
	done
}

main() {
	cd /tmp
	check_for_errors $@
	parse_argument $@
	launch
}

main "$@"
