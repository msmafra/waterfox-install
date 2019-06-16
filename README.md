# Waterfox Install for Linux

Waterfox download and installation script.
Tested on [Fedora](https://getfedora.org/), [POP!_OS](https://system76.com/pop), [openSUSE](https://www.opensuse.org/), [Manjaro](https://manjaro.org) and of course [Arch Linux](https://www.archlinux.org/) 64bit versions. I see no reason it would not work on any other 64bit Linux distro.

### Some References
- [Alex Kontos](https://github.com/MrAlex94) awesome work. Find out more about Waterfox and [the guys](https://www.waterfox.net/about/). Waterfox is [here](https://github.com/MrAlex94/Waterfox) on GitHub;

- The waterfox.desktop file is adapted from [Arch Linux's AUR waterfox-bin.git](https://aur.archlinux.org/cgit/aur.git/plain/waterfox.desktop?h=waterfox-bin).
  - Changes:
  Added to the [waterfox.desktop](https://github.com/msmafra/waterfox-install/blob/master/waterfox.desktop) the [TryExec](https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s06.html) entry at line 85 key with the full path of the application and also altered the Icon key adding the full path for the 256px x 256px png icon. To point to the most beautiful version of the icon:

    `85: + TryExec=/usr/lib64/waterfox/waterfox`

    `88: Icon=waterfox-icon => Icon=/usr/lib64/waterfox/browser/chrome/icons/default/default256.png`

- /usr/bin/waterfox file is adapted from Fedora's version of /usr/bin/firefox as a base, to do a quick adaptation. File is created by DNF package manager during the installation of Mozilla Firefox browser.

### Some Information
The installation script will, download waterfox-xx.xx.xx.en-US.linux-x86_64.tar.bz2 and extract it to /usr/lib64/, create a symbolic link in /usr/bin/, create a [desktop entry](https://specifications.freedesktop.org/desktop-entry-spec/latest/index.html) file (waterfox.desktp) on /usr/share/applications/. And there is no uninstallation yet.

## Using It
### Install


Run

    sudo bash ./waterfox-install.sh

or

Run

    chmod +x ./waterfox-install.sh

then

    sudo ./waterfox-install.sh



### Uninstall

Created separated uninstallation file for the 0.x installation because of its place of installation /usr/lib64/. It will probably change on the next version.
Will be integrated in the final version.

Run

    sudo bash ./uninstall-waterfox.sh

or

Run

    chmod +x ./uninstall-waterfox.sh

then

    sudo ./uninstall-waterfox.sh

## Newer Versions Of Waterfox

The script was pointing to the old... previous download page https://waterfoxproject.org/en-US/waterfox/new/?scene=1, which is not updated anymore. Actually https://waterfoxproject.org/ is now redirected to https://www.waterfox.net/. The "new" download page has now all OSes and also the possiblity to download the testing and production versions. The ability to choose between production and development version is not implemented in the current version 0.x but will be in 1.0. Also t