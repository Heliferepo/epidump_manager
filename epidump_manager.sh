#!/usr/bin/env bash

ALL=0
SFML=0
DEPS=0
BLIH=0
EPIMACS=0
ZSHELL=0
addtouser=""

show_help() {
    echo -e "Usage: epidump_manager [OPTION]...\n"
    echo -e "\t-a\trebuild the entire Epitech dump. This ignores every other flag (except -h and -z)"
    echo -e "\t-s\trebuild the CSFML with Epitech's script"
    echo -e "\t-d\tupdate / install the packages from Epitech's package list"
    echo -e "\t-b\treinstall blih with Epitech's script"
    echo -e "\t-e\tinstall Emacs with dnf and Epitech Emacs (SYSTEM Install) with Epitech's script"
    echo -e "\t-z\tInstall zsh with ohmyzsh"
    echo -e "\t-h\tdisplay this help and exit"
}

# $1 is a representative name of whatever you want to check for to make it clearer to the user what we're doing when installing the package to get the file
# $2 is the file to check for
# $3 is the package to install to get the file
check_for_file_and_install_package_if_not_present() {
    if [ ! -f "$2" ]; then
        echo "warning: $1 not found... Installing $1..."
        dnf install -y "$3"

        if [ ! -f "$2" ]; then
            echo "fatal error: Could not find $1 nor install it"
            exit 1
        fi
    fi
}

check_for_git() {
    check_for_file_and_install_package_if_not_present "Git" /usr/bin/git git-core
}

check_for_dnf_copr() {
    # The `?` in `python3.?` should make it so that this works for any version of Python 3 installed on the target system
    check_for_file_and_install_package_if_not_present "DNF copr plugin" /usr/lib/python3.?/site-packages/dnf-plugins/copr.py "dnf-command(copr)"
}

check_for_SFML() {
    check_for_file_and_install_package_if_not_present "Development files for SFML" /usr/include/SFML/Main.hpp SFML-devel
}

check_for_curl() {
    check_for_file_and_install_package_if_not_present "Curl" /usr/bin/curl curl
}

check_for_zsh() {
    check_for_file_and_install_package_if_not_present "Z shell" /usr/bin/zsh zsh
}

check_for_wget() {
    check_for_file_and_install_package_if_not_present "wget" /usr/bin/wget wget
}

check_for_chsh() {
    check_for_file_and_install_package_if_not_present "chsh" /usr/bin/chsh util-linux-user
}

check_for_emacs() {
    check_for_file_and_install_package_if_not_present "GNU Emacs without X support" /usr/bin/emacs-nox emacs-nox
}

get_user_install_zsh() {
    echo "Please give the username of the user you want to install to : "
    read addtouser
        
    if [ "$addtouser" == "root" ]; then
        addtouser = "/root"
    elif [ -d "/home/$addtouser" ]; then
        addtouser = "/home/$addtouser"
    else
        echo "Could not find /home/$addtouser"
        exit 1
    fi
}
        

check_for_basic_invocation_errors() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" 1>&2
        exit 1
    fi
}

enabling_rpm_fusion() {
    sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    
    if [ $? -ne 0 ]; then
        echo "Could not enable rpm fusion"
    fi
}

# Implements -a
rebuild_all() {
    check_for_git

    echo "Cloning Epitech's dump repository to ${PWD}/${epitech_dump_directory}..."
    local epitech_dump_directory=epitech-dump
    git clone https://github.com/Epitech/dump ${epitech_dump_directory}
    cd ${epitech_dump_directory}
    chmod +x install_packages_dump.sh

    echo "Executing Epitech install_packages_dump.sh script..."
    ./install_packages_dump.sh
    cd ..
}

# Implements -d
dependencies_installer() {
    check_for_dnf_copr
    enabling_rpm_fusion

    echo "Importing RPM keys from Microsoft..."
    rpm --import https://packages.microsoft.com/keys/microsoft.asc

    echo "Adding Microsoft Teams repository to repositories..."
    bash -c 'echo -e "[teams]\nname=teams\nbaseurl=https://packages.microsoft.com/yumrepos/ms-teams\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/teams.repo'

    echo "Enabling petersen/stack2 copr and installing rpmfusion..."
    dnf -y copr enable petersen/stack2 && dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    echo "Updating all packages to the latest available version (i.e. doing dnf upgrade)..."
    dnf upgrade -y

    local packages=$(curl https://raw.githubusercontent.com/Epitech/dump/master/install_packages_dump.sh | grep -oPz 'packages_list=\(\K[^\)]+')

    if [ -z "$packages" ]; then
        echo "Could not get the package list" 2>&1
        echo "Please report this to the repo manager by creating an issue" 2>&1
        exit 1
    fi

    echo "Installing packages from Epitech dump package list..."
    dnf -y install $packages criterion criterion-devel
}

# Implements -s
rebuild_sfml_plus_csfml() {
    check_for_SFML

    echo "Downloading and executing install script for CSFML..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Epitech/dump/master/build_csfml.sh)" || echo "There has been an error while building CSFML"
}

# Implements -b
blih_installer() {
    check_for_curl

    echo "Downloading blih..."
    curl -LO https://raw.githubusercontent.com/Epitech/dump/master/blih.py
    if [ ! -f "blih.py" ]; then
        echo "Could not download blih... Aborting..."
        exit 1
    fi

    echo "Installing blih..."
    install blih.py /usr/bin/blih
}

# Implements -e
reinstall_epitech_emacs() {
    check_for_git
    check_for_emacs

    echo "Cloning Epitech emacs repo..."
    git clone https://github.com/Epitech/epitech-emacs.git
    if [ ! -d "epitech-emacs" ]; then
        echo "Could not download epitech-emacs... Aborting..."
        exit 1
    fi
    cd epitech-emacs

    # Checkout latest stable commit (ugly hack but it works at least)
    git checkout 278bb6a630e6474f99028a8ee1a5c763e943d9a3

    echo "Running Epitech emacs install script..."
    ./INSTALL.sh system

    cd .. && rm -rf epitech-emacs
}

#Implements -z
zsh_installer() {
    get_user_install_zsh
    check_for_zsh
    check_for_wget
    check_for_chsh

    echo "Download ohmyzsh + installation"
    sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" || echo "There has been an error while download ohmyzsh" 1>&2
    
    echo "Copy zsh files to /usr/share for all user access"
    mv /root/.oh-my-zsh /usr/share/oh-my-zsh
    
    echo "Move into the dir and copy the zshrc template to zshrc (which will be the default for users)"
    cd /usr/share/oh-my-zsh/
    cp templates/zshrc.zsh-template zshrc
    
    echo "Nab the patch file from MarcinWieczorek's AUR Package and apply to the zshrc file"
    wget https://aur.archlinux.org/cgit/aur.git/plain/0001-zshrc.patch\?h\=oh-my-zsh-git -O zshrc.patch && patch -p1 < zshrc.patch
    
    echo "Create hard link to the zshrc file so it creates an actual independent copy on new users"
    sudo ln /usr/share/oh-my-zsh/zshrc /etc/skel/.zshrc
    
    echo "Set default shell to zsh"
    sudo adduser -D -s /bin/zsh
    
    echo "Giving a zshrc to specific user"
    cp /usr/share/oh-my-zsh/zshrc $addtouser/.zshrc
}

launch() { 
    if [ "$ALL" == 1 ]; then
        echo "Reinstalling completely epitech dump"
        rebuild_all
        exit 0
    fi
    
    if [ "$ZSHELL" == 1 ]; then
        echo "Installing / Reinstalling zsh"
        zsh_installer
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
        blih_installer
    fi

    if [ "$EPIMACS" == 1 ]; then
        echo "Installing / Reinstalling epitech emacs"
        reinstall_epitech_emacs
    fi
}

parse_argument() {
    while getopts "asdbezh" opt; do
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
            z)
                ZSHELL=1
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
    cd `mktemp -d`  # Create temporary directory and cd to it
    check_for_basic_invocation_errors $@
    parse_argument $@ # Process command line
    launch  # Do stuff based on the processed command line options
}

main "$@"
