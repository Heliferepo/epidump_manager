# epidump_manager
A simple manager linked to Epitech/dump repo to fix anytime in one command anything that is provided in the dump repository

This Dump manager provides thoses commands :

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
If you write multiple times the flag it will be counted as one :
```
epidump_manager -ssseebbdsb
#or
epidump_manager -s -s -s -e -e -b -b -d -s -b
#Is the same as
epidump_manager -sedb
#or
epidump_manager -s -e -d -b
```

To install the epidump_manager :
```sh
git clone https://github.com/Heliferepo/epidump_manager
cd epidump_manager
chmod +x install.sh
sudo ./install.sh
```

If you notice something is missing in the package manager or you found a bug please open an issue
