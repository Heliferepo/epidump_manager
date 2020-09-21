#!/usr/bin/env bash

ALL=0
SFML=0
DEPS=0
BLIH=0
EPIMACS=0

show_help() {
    echo -e "Usage: epidump_manager [OPTION]...\n"
    echo -e "\t-a\trebuild the entire Epitech dump. This ignores every other flag (except -h)"
    echo -e "\t-s\trebuild the CSFML with Epitech's script and update SFML with dnf"
    echo -e "\t-d\tupdate / install the packages from Epitech's package list"
    echo -e "\t-b\treinstall blih with Epitech's script"
    echo -e "\t-e\tinstall Emacs with dnf and Epitech Emacs (SYSTEM Install) with Epitech's script"
    echo -e "\t-h\tdisplay this help and exit"
}

check_for_git() {
    if [ ! -f "/usr/bin/git" ]; then
        echo "warning: Git not found... Installing git"
        dnf install -y git-core
        if [ ! -f "/usr/bin/git" ]; then
            echo "fatal error: Could not find git nor install it"
            exit 1
        fi
    fi
}

check_for_basic_invocation_errors() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" 1>&2
        exit 1
    fi

    if [ -z "$1" ]; then
        echo "fatal error: no arguments"
        show_help
        exit 1
    fi
}

rebuild_all() {
    check_for_git
    git clone https://github.com/Epitech/dump epitech-dump
    cd epitech-dump
    chmod +x install_packages_dump.sh
    ./install_packages_dump.sh
}

dependencies_installer() {
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    bash -c 'echo -e "[teams]\nname=teams\nbaseurl=https://packages.microsoft.com/yumrepos/ms-teams\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/teams.repo'
    dnf -y install dnf-plugins-core && dnf -y copr enable petersen/stack2 && dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    dnf upgrade -y

    local packages=$(curl https://raw.githubusercontent.com/Epitech/dump/master/install_packages_dump.sh | grep -oPz 'packages_list=\(\K[^\)]+')

    if [ -z "$packages" ]; then
        echo "Could not get the package list" 2>&1
        echo "Please report it to the repo manager by creating an issue" 2>&1
        exit 1
    fi

    dnf -y install $packages
}

rebuild_sfml_plus_csfml() {
    dnf install -y SFML.x86_64 SFML-devel.x86_64
    if [ ! -d "/usr/include/SFML/" ]; then
        echo -e "There is two possibilities : \n\t- SFML is not installed in the default path\n\t- SFML is not installed\nAborting..."
        exit 1
    fi
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Epitech/dump/master/build_csfml.sh)" || echo "There has been an error while building csfml"
}

blih_installer() {
    curl -LO https://raw.githubusercontent.com/Epitech/dump/master/blih.py
    if [ ! -f "blih.py" ]; then
        echo "Could not download blih... Aborting..."
        exit 1
    fi
    chmod +x blih.py
    rm -rf /usr/bin/blih
    mv blih.py /usr/bin/blih
}

reinstall_epitech_emacs() {
    check_for_git
    dnf install -y emacs-nox
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
    ./INSTALL.sh system
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
        blih_installer
    fi
    if [ "$EPIMACS" == 1 ]; then
        echo "Installing / Reinstalling epitech emacs"
        reinstall_epitech_emacs
    fi
}

parse_argument() {
    while getopts "asdbeh" opt; do
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
    cd `mktemp -d`  # Create temporary directory and cd to it
    check_for_basic_invocation_errors $@
    parse_argument $@
    launch
}

main "$@"
