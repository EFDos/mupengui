# MupenGUI 
### Summary
Mupen64plus Frontend Application written in Vala and C.

![Alt text](data/screenshots/Welcome.png?raw=true "Welcome Screen")

![Alt text](data/screenshots/Welcome_Dark.png?raw=true "Welcome Screen in Dark Mode")

![Alt text](data/screenshots/Pantheon_Running.png?raw=true "Running SM64")

![Alt text](data/screenshots/KDE_Welcome.png?raw=true "Looking sexy on KDE")

![Alt text](data/screenshots/KDE_Input.png?raw=true "The whole reason why I'm making this")

Some of the features are:

* Basic graphics configuration (Fullscreen, resolution ...)
* Selecting emulation plugins
* Rom Directory listing and remembering state from last use.
* Rom Profiles allowing for different configurations for each Rom.

Although primarily targeted for the Elementary OS Desktop and AppStore, it may work under any Desktop Environment
given that libgranite is available - including KDE.

## Building and Installing [![Build Status](https://travis-ci.com/EFDos/mupengui.svg?branch=master)](https://travis-ci.com/EFDos/mupengui)

### Elementary OS

You can look for it on the AppCenter, or install it through apt-get in the command line:

`$ apt install com.github.efdos.mupengui`

### Arch Linux

Arch Linux users can find MupenGui under the name mupengui-git in the AUR:

`$ aurman -S mupengui-git`

### Other

Your system must be at least compatible with a Gnome Environment and libgranite must be installed.
The project uses the Meson build system.

**Configure and create a build directory**

`meson build`

**If you want to install it on your system, use**

`meson build --prefix=/usr`
*or anyother prefix you'd like*

**Go into the build directory and run**

`ninja`

**and for installing...**

`ninja install`
*must be sudo if you're installing on your system*

### Credits
Arch Linux distribution support by btd1337 

Base N64 Controller used to design the icon by David Swanson from the Noun Project.
