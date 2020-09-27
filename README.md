# epidump_manager
A simple manager linked to the Epitech/dump repository to handle most dump-related problems in one command

This dump manager provides thoses commands :

```
        -a      rebuild the entire Epitech dump. This ignores every other flag (except -h and -z)
        -s      rebuild the CSFML with Epitech's script
        -d      update / install the packages from Epitech's package list
        -b      reinstall blih with Epitech's script
        -e      install Emacs with dnf and Epitech Emacs (SYSTEM Install) with Epitech's script
        Optional  (not invoked by -a) :
                -z      Install zsh with ohymzsh
                -c      Install Criterion
        -h      display this help and exit
        -u      Update the script and quit
```

You are meant to use the command as follow :
```sh
epidump_manager -sbe
# It rebuilds sfml+csfml, reinstall blih and install epitech emacs
```

To install the epidump_manager :
```sh
git clone https://github.com/Heliferepo/epidump_manager
cd epidump_manager
chmod +x install.sh
sudo ./install.sh
```

If you notice something is missing in the package manager, or you find a bug, please open an issue
