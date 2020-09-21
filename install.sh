if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

cat /etc/fedora-release | grep "Fedora release 32"
if [[ $? -ne 0 ]]; then
    echo "This script must be run onto Fedora 32"
    exit 1
fi

chmod +x epidump_manager.sh
mv epidump_manager.sh /usr/bin/epidump_manager

echo -e "Epidump manager installed type epidump_manager -h to know how to use it\n"
