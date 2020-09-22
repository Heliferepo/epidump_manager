#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

echo "Checking for Fedora 32..."
if [[ "xFedora release 32 (Thirty Two)" != "x$(cat /etc/fedora-release)" ]]; then   # Check if /etc/fedora-release contains the text stored in it in Fedora 32. The x is to avoid an initial `-` character in /etc/fedora-release being interpreted as an option to test.
    echo "This script must be run onto Fedora 32"
    exit 1
fi

install epidump_manager.sh /usr/bin/epidump_manager
cp epidump_manager.8.gz /usr/share/\man/man8

echo -e "The epidump manager was successfully installed. Type \`man epidump_manager\` to learn how to use it\n"
