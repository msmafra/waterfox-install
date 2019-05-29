# waterfox-install
Waterfox download and installation script.
Tested on [Fedora](https://getfedora.org/), [POP!_OS](https://system76.com/pop) and [Manjaro](https://manjaro.org) 64bit versions.

## Some references
- [Alex Kontos](https://github.com/MrAlex94) awesome work, [Waterfox](https://github.com/MrAlex94/Waterfox) is on GitHub;

- The waterfox.desktop file is adapted from [Arch Linux's AUR waterfox-bin.git](https://aur.archlinux.org/cgit/aur.git/plain/waterfox.desktop?h=waterfox-bin).
  - Changes:
  Added to the waterfox.desktop the TryExec(line 85) key with the full path of the application and also altered the Icon key adding the full path for the 256px x 256px png icon. To point to the most beautiful version of the icon:

    `85: + TryExec=/usr/lib64/waterfox/waterfox`

    `88: Icon=waterfox-icon => Icon=/usr/lib64/waterfox/browser/chrome/icons/default/default256.png`

## Some information
This script will extract watefox to /usr/lib64/, create a symbolic link in /usr/bin/ and a .desktop file on /usr/share/applications/. And there is no uninstallation yet.

## Install


Run

    sudo bash ./waterfox-install.sh

or

Run

    chmod +x ./waterfox-install.sh

then

    sudo ./waterfox-install.sh


## Newer versions of Waterfox

The script is pointing to the old... previous download page https://waterfoxproject.org/en-US/waterfox/new/?scene=1, which is not updated so it only downloads version 56.2.8 (at the writing of this 20190519). The "new" download page https://www.waterfox.net/releases/ has now all OSes and also the possiblity to download the testing and production versions. The ability to chose which one is not implement in the current version 0.5
And I also don't know which site to point to. ;)

## Uninstall

Created separated uninstallation file for the original (current) installation because of its place of installation /usr/lib64. It will probably change on the next version.

Run

    sudo bash ./uninstall-waterfox.sh

or

Run

    chmod +x ./uninstall-waterfox.sh

then

    sudo ./uninstall-waterfox.sh
