# waterfox-install
Waterfox download and installation script.
Tested on [Fedora](https://getfedora.org/), [System76's POP!_OS](https://system76.com/pop) and [Manjaro](https://manjaro.org) 64bit versions.

## Some references
- [Alex Kontos](https://github.com/MrAlex94) awesome work, [Waterfox](https://github.com/MrAlex94/Waterfox) is on GitHub;

- The waterfox.desktop file is adapted from [Arch Linux's AUR waterfox-bin.git](https://aur.archlinux.org/cgit/aur.git/plain/waterfox.desktop?h=waterfox-bin).
  - Changes:
  Added to the waterfox.desktop the TryExec(line 85) key with the full path of the application and also altered the Icon key adding the full path for the 256px x 256px png icon. To point to the most beautiful version of the icon:

    `85: + TryExec=/usr/share/applications/waterfox/waterfox`

    `88: Icon=waterfox-icon => Icon=/usr/lib64/waterfox/browser/chrome/icons/default/default256.png`

## Install


Run

    sudo bash ./waterfox-install.sh

or

Run

    chmod +x ./waterfox-install.sh

then

    sudo ./waterfox-install.sh


## Newer versions fo Waterfox

~~As there is no generic file like waterfox-latest.tar.bz2, each new version has to be changed manually inside de script until I find and elegant sollution. :wink:~~
Function that sweeps the download page and get the correct url created: getWFXURL 
