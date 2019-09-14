# Waterfox Install For Linux
###### Not an official one, mind you :)

Waterfox install script for Linux will download and extract the tarball file, create a symbolic link to the bin file and create a dot desktop file.
Tested on [Fedora](https://getfedora.org/), [POP!_OS](https://system76.com/pop), [openSUSE](https://www.opensuse.org/), [Manjaro](https://manjaro.org) and of course [Arch Linux](https://www.archlinux.org/) 64bit versions.

### Some References
- [Alex Kontos](https://github.com/MrAlex94) awesome work. Find out more about Waterfox and [the guys](https://www.waterfox.net/about/). Waterfox is [here](https://github.com/MrAlex94/Waterfox) on GitHub;

- The **waterfox.desktop** file is adapted from the one on [Arch Linux's AUR waterfox-bin.git](https://aur.archlinux.org/cgit/aur.git/tree/waterfox.desktop?h=waterfox-bin). Here is the raw/text only version: [waterfox.desktop raw](https://aur.archlinux.org/cgit/aur.git/plain/waterfox.desktop?h=waterfox-bin).
  - Changes:
  Added to the [waterfox.desktop](https://github.com/msmafra/waterfox-install/blob/master/waterfox.desktop) the [TryExec key](https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s06.html) entry at line `85: + TryExec=/usr/lib64/waterfox/waterfox`  with the full path of the application and also `88: Icon=waterfox-icon => Icon=/usr/lib64/waterfox/browser/chrome/icons/default/default256.png` altered the [Icon key](https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s06.html) by adding the full path for the 256px x 256px png icon. To point to the icon with the best quality;
- The **/usr/bin/waterfox** file is an adaptation from Fedora's version of **/usr/bin/firefox** as a base, to do a quick adaptation. File is installed by DNF package manager during the installation of Mozilla Firefox browser;
- As for the version 1.0 I will merge [waterfox.desktop](https://aur.archlinux.org/cgit/aur.git/tree/waterfox.desktop?h=waterfox-bin) from AUR with [waterfox.desktop](https://raw.githubusercontent.com/hawkeye116477/waterfox-deb/master/waterfox-kde/waterfox.desktop) for KDE;

### Some Information
The installation script will, download waterfox-xx.xx.xx.en-US.linux-x86_64.tar.bz2 and extract it to **/usr/lib64/**, create a symbolic link in **/usr/bin/**, create a [desktop entry](https://specifications.freedesktop.org/desktop-entry-spec/latest/index.html) file (waterfox.desktop) on **/usr/share/applications/**. And there is no uninstallation yet.

### Getting it
**You can clone the repo:**

	git clone https://github.com/msmafra/waterfox-install.git

Or just download **waterfox-install.sh** file to your machine from you browser [raw file](https://raw.githubusercontent.com/msmafra/waterfox-install/Dev/waterfox-install.sh) or:

**Download it with cURL or Wget:**

    curl --continue-at - https://raw.githubusercontent.com/msmafra/waterfox-install/Dev/waterfox-install.sh

   or

    wget --continue https://raw.githubusercontent.com/msmafra/waterfox-install/Dev/waterfox-install.sh

### Using it
**Run using bash:**

	sudo bash ./waterfox-install.sh

or

	chmod +x ./waterfox-install.sh && sudo ./waterfox-install.sh

### Uninstalling it

There is a separated uninstallation file for the 0.x.x installation because of its place of installation that I chose **/usr/lib64/**. It will probably change on the next version to **/opt/**. Will be integrated in the final version.
Your profile(s) will not be deleted. They are stored at **~/.mozilla/waterfox/**

Run using bash:

	sudo bash ./uninstall-waterfox.sh

or

	chmod +x ./uninstall-waterfox.sh && sudo ./uninstall-waterfox.sh
