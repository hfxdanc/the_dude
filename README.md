# WinBox flatpak
**!!! This wrapper is not verified by, affiliated with, sponsored or supported by MikroTīk in any way. !!!**

------

Flatpak build for Mikrotik's The Dude network monitor.  **No** MikroTik binaries are included in the flatpak. 

After agreement to the [Export Eligibility Requirements and END USER LICENSE](https://mikrotik.com/downloadterms.html) the following will be downloaded and installed ...

- Latest version of The Dude and licence terms

#### Possible issues

##### AppStream data

When the Flatpak was built, the release notes from latest .rss message were included in the "Version" section of the AppStream Desktop files; however, after install the The Dude application may update/downgrade to a different version.

##### Child windows and multiple monitors

When a child window is opened it will always initially position itself on the monitor on which The Dude initially opened. 

### Build

The local flatpak is assembled by the flatpak-builder tooling.  On a Fedora based distro the following packages are needed (other distros may vary) ...

`$ sudo dnf install flatpak-builder appstream-compose composefs composefs-libs ostree` 

Clone the GitHub repository ...

`$ git clone https://github.com/hfxdanc/the_dude.git`

Issue the following command after cloning the repository to build and install the flatpak (in user space)

`$ cd the_dude`
`$ sh update.sh`

### Run

Run the flatpak with ...

`$ flatpak run org.flatpak.TheDude`

The code installs Appstream metadata and a .desktop file in the users `$HOME` directory.  You can execute the flatpak as a normal desktop  application using the Super key.

##### Windows System Tray

The separate small window is where Wine is managing the Windows System tray or Notification area.  It can be hidden by checking `Hide Tray Icon` in The Dude's Preferences dialog box.

### Uninstall

You can remove the application through your normal GUI process or with the command ...

```
$ flatpak uninstall --delete-data org.flatpak.TheDude
```
