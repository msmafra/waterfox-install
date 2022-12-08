# -- 2022-12-08 -- It's been a while since I last looked at this repo. I started, years back a new version that would be published on GitLab, but I never finished it. I'll try to revise it and publish it there. #
# -- On 2019-10-23 versioning and naming scheme changed. The installation script still working (just downloading the classic version) but will be adapted nevertheless. -- [Waterfox 2019.10 Release](https://www.waterfox.net/blog/waterfox-2019.10-release-download/). Also, the development version is not available for a while


# Waterfox Install for Linux

Waterfox download and installation script.
Tested on [Fedora](https://getfedora.org/), [POP!_OS](https://system76.com/pop), [openSUSE](https://www.opensuse.org/), [Manjaro](https://manjaro.org) and of course [Arch Linux](https://www.archlinux.org/) 64bit versions.

### Some References
- [Alex Kontos](https://github.com/MrAlex94) awesome work. Find out more about Waterfox and [the guys](https://www.waterfox.net/about/). Waterfox is [here](https://github.com/MrAlex94/Waterfox) on GitHub;

- The **waterfox.desktop** file is adapted from the one on [Arch Linux's AUR waterfox-bin.git](https://aur.archlinux.org/cgit/aur.git/tree/waterfox.desktop?h=waterfox-bin). Here is the raw/text only version: [waterfox.desktop raw](https://aur.archlinux.org/cgit/aur.git/plain/waterfox.desktop?h=waterfox-bin).
  - Changes:
  Added to the [waterfox.desktop](https://github.com/msmafra/waterfox-install/blob/master/waterfox.desktop) the [TryExec key](https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s06.html) entry at line `85: + TryExec=/usr/lib64/waterfox/waterfox`  with the full path of the application and also `88: Icon=waterfox-icon => Icon=/usr/lib64/waterfox/browser/chrome/icons/default/default256.png` altered the [Icon key](https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s06.html) by adding the full path for the 256px x 256px png icon. To point to the icon with the best quality.

- /usr/bin/waterfox file is adapted from Fedora's version of /usr/bin/firefox as a base, to do a quick adaptation. The file is installed by the DNF package manager during the installation of the Mozilla Firefox browser.

### Some Information
The installation script will, download waterfox-xx.xx.xx.en-US.linux-x86_64.tar.bz2 and extract it to /usr/lib64/, create a symbolic link in /usr/bin/, create a [desktop entry](https://specifications.freedesktop.org/desktop-entry-spec/latest/index.html) file (waterfox.desktp) on /usr/share/applications/. And there is no uninstallation yet.

## Using the script
### Getting the script
You can clone the repo:
`git clone https://github.com/msmafra/waterfox-install.git`
Or just download [waterfox-install.sh](https://raw.githubusercontent.com/msmafra/waterfox-install/master/waterfox-install.sh) file to your machine.

### Installing Waterfox


Run using bash:

    sudo bash ./waterfox-install.sh

Or make it executable:

    chmod +x ./waterfox-install.sh

And then run it:

    sudo ./waterfox-install.sh

### Installing Waterfox with the instructions of Angela  [(angela-d)](https://gist.github.com/angela-d/)

The `waterfox-download.sh` file will access the download page, get the URL and check if the file is available for downloading and print it to your console.

Instructions here: [How to Install Waterfox on Linux](https://gist.github.com/angela-d/5f6760f5512e8b8029aeda3cbb1d26dd)


### Uninstalling Waterfox

There is also a separate uninstallation file for the 0.x installation because of its place of installation /usr/lib64/. It will probably change on the next version to /opt/. Will be integrated into the final version.
Your profile(s) will not be deleted. They are located in ~/.mozilla/waterfox/

Run using bash:

    sudo bash ./uninstall-waterfox.sh

Or make it executable:

    chmod +x ./uninstall-waterfox.sh

And then run it:

    sudo ./uninstall-waterfox.sh

## Newer Versions Of Waterfox

The script was pointing to the previous download page https://waterfoxproject.org/en-US/waterfox/new/?scene=1, which is not updated anymore, https://waterfoxproject.org/ is now redirected to https://www.waterfox.net/. The new download page has now all OSes and also the possibility to download the testing and production versions. The ability to choose between production and development versions is not implemented in the current version 0.x but will be in 1.0.
