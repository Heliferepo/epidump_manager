# epidump_manager
A simple manager linked to the Epitech/dump repository to handle most dump-related problems in one command

This dump manager provides thoses commands :

```
  -a Rebuild the whole Epitech's dump it ignores every other flags except -h and fails if one flag is false
  -s Rebuild the CSFML with Epitech's script and update SFML with dnf
  -d Update / Install the packages of Epitech's package list
  -b Reinstall blih with Epitech's script
  -e Install Emacs with dnf and Epitech Emacs (SYSTEM Install) with Epitech's script
  -h Show the help ignore all other flags and exit
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
