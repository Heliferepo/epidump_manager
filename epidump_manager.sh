#!/bin/sh

show_help() {
    echo "-a or -all rebuild the Epitech's dump"
    echo "-s or --rebuild-sfml-csml rebuild the csfml and reinstall sfml with epitech's dump script"
    echo "-d or --install-dependencies update and install all the packages from epitech's dump"
    echo "-b or --reinstall-blih reinstall blih with epitech's repo"
    echo "-e or --reinstall-epitech-emacs to the system with epitech's repo"
    echo "-h or --help show this text"
}

check_for_errors() {
    if [ -z "$1" ]; then
        show_help
        exit 1
    fi

    if [ ! -z "$1" && ! -z "$2" ]; then
        echo "This script does not support multiple argument because it has been done in less than 2 minutes sorry not sorry"
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

    packages_list=(boost-devel.x86_64
        boost-static.x86_64
        ca-certificates.noarch
        clang.x86_64
        cmake.x86_64
        CUnit-devel.x86_64
        curl.x86_64
        flac-devel.x86_64
        freetype-devel.x86_64
        gcc.x86_64
        gcc-c++.x86_64
        gdb.x86_64
        git
        glibc.x86_64
        glibc-devel.x86_64
        glibc-locale-source.x86_64
        gmp-devel.x86_64
        ksh.x86_64
        elfutils-libelf-devel.x86_64
        libjpeg-turbo-devel.x86_64
        libvorbis-devel.x86_64
        SDL2.x86_64
        SDL2-static.x86_64
        SDL2-devel.x86_64
        libX11-devel.x86_64
        libXext-devel.x86_64
        ltrace.x86_64
        make.x86_64
        nasm.x86_64
        ncurses.x86_64
        ncurses-devel.x86_64
        ncurses-libs.x86_64
        net-tools.x86_64
        openal-soft-devel.x86_64
        python3-numpy.x86_64
        python3.x86_64
        rlwrap.x86_64
        ruby.x86_64
        strace.x86_64
        tar.x86_64
        tcsh.x86_64
        tmux.x86_64
        sudo.x86_64
        tree.x86_64
        unzip.x86_64
        valgrind.x86_64
        vim
        emacs-nox
        which.x86_64
        xcb-util-image.x86_64
        xcb-util-image-devel.x86_64
        zip.x86_64
        zsh.x86_64
        avr-gcc.x86_64
        avr-gdb.x86_64
        qt-devel
        docker
        docker-compose
        java-latest-openjdk
        java-latest-openjdk-devel
        boost
        boost-math
        boost-graph
        autoconf
        automake
        tcpdump
        wireshark
        nodejs
        python3-virtualenv-api
        python3-virtualenv
        emacs-tuareg
        libvirt
        libvirt-devel
        virt-install
        haskell-platform
        golang
        systemd-devel
        libgudev-devel
        php.x86_64
        php-devel.x86_64
        php-bcmath.x86_64
        php-cli.x86_64
        php-gd.x86_64
        php-mbstring.x86_64
        php-mysqlnd.x86_64
        php-pdo.x86_64
        php-pear.noarch
        php-json.x86_64
        php-xml.x86_64
        php-gettext-gettext.noarch
        php-phar-io-version.noarch
        php-theseer-tokenizer.noarch
        SFML.x86_64
        SFML-devel.x86_64
        irrlicht.x86_64
        irrlicht-devel.x86_64
        rust.x86_64
        cargo.x86_64
        mariadb-server.x86_64
        x264.x86_64
        lightspark.x86_64
        lightspark-mozilla-plugin.x86_64
        teams.x86_64)

        sudo dnf -y install ${packages_list[@]}
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

parse_single_argument() {
    case $1 in
        -a|--all)
            rebuild_all;
            exit 0;;
        -s|--rebuild-sfml-csfml)
            rebuild_sfml_plus_csfml;
            exit 0;;
        -d|--install-dependencies)
            dependencies_installer;
            exit 0;;
        -b|--reinstall-blih)
            blih-installer;
            exit 0;;
        -e|--reinstall-epitech-emacs)
            reinstall-epitech-emacs;
            exit 0;;
        -h|--help)
            show_help;
            exit 0;;
        *)
            echo "Did not recognized argument showing help";
            show_help;
            exit 1;;
    esac
}

main() {
    cd /tmp
    check_for_errors
    parse_single_argument
}

main
