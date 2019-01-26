# MupenGUI 
### Summary
Mupen64plus Frontend Application written in Vala and C, still in development.

![Alt text](data/screenshots/Welcome.png?raw=true "Welcome Screen")

![Alt text](data/screenshots/Welcome_Dark.png?raw=true "Welcome Screen in Dark Mode")

![Alt text](data/screenshots/Pantheon_Running.png?raw=true "Running SM64")

![Alt text](data/screenshots/KDE_Welcome.png?raw=true "Looking sexy on KDE")

![Alt text](data/screenshots/KDE_Input.png?raw=true "The whole reason why I'm making this")

This frontend's goal for the first release is to feature:

* Basic graphics configuration (Fullscreen, resolution ...)
* Mupen64plus plugins configuration
* Complete input configuration (including keyboard, mouse and joysticks)
* Rom directory listing and remembering state from last use.
*note: The first Alpha release is already available with some of these features.*

Although primarily targeted for the Elementary OS Desktop and AppStore, it may work under any Desktop Environment
given that libgranite is available - including KDE.

Differently from some of the frontends available for Mupen64plus, this frontend interfaces
directly with the emulator by interfacing with its shared library instead of sending
commands to the Mupen64plus CLI frontend. This allows for a greater control over
the emulation and its configuration options.

## Building and Installing [![Build Status](https://travis-ci.com/EFDos/mupengui.svg?branch=master)](https://travis-ci.com/EFDos/mupengui)

### Elementary OS

You can look for it on the AppCenter, or install it through apt-get in the command line:

`$ apt install com.github.efdos.mupengui`

### Arch Linux

Arch Linux users can find MupenGui under the name mupengui-git in the AUR:

`$ aurman -S mupengui-git`

### Other

Your system must be at least compatible with a Gnome Environment and libgranite must be installed.
The project used the Meson build system.

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
