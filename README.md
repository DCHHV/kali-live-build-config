Kali Linux™ live-build-config DC HHV Edition
===========================================

This is a fork of the Kali Linux™ live-build-config image creation tool.  We have added variants for hardware hacking specific tools.  The default Kali distribution is great but some of the more esoteric compilers, programmers, and debugging tools are not readily included in the base packages.  We have created a Kali build variant that includes these and other customizations.

Contributions
-------------
We welcome any feedback or pull requests.  If there is a package we missed that you find yourself using, let us know and we can bring it in to our configs.

Variants
--------
There are two build variants, hhv and hhv-light.  The hhv variant is the full size, including nearly every electronics or scientific package available through Kali.  It is intended to fit on a DVD, weighing in around 2.2 GB in size.  The hhv-light variant is much more stripped down, expecting there to be no external firmware added, no installer option, and only the bare essentials of hardware hacking tools (or at least what we felt the most important are).  To make it fit on a CDROM we've even removed some of the Kali themes, it just barely squeezes on a 700 MB CD-R.

Building
--------
Building is meant to take place inside of a kali-rolling installation.  This is because this set of build scripts expects to have access to kali-rolling apt repos and package aliases.  Setting this up is beyond the scope of our help.  Boot an existing live CD, install from live CD, set up a chroot, etc.  

Kali documentation is a great place to start: https://docs.kali.org/development/live-build-a-custom-kali-iso

Once in a kali-rolling environment, building can be done with:

`sudo apt install curl git live-build cdebootstrap`

`./build.sh --distribution kali-rolling --variant hhv-light --no-firmware --no-installer -v`  # For light variant

`./build.sh --distribution kali-rolling --variant hhv -v`  # For standard variant

Note: The --no-firmware and --no-installer options must be passed to the hhv-light variant, without them they will not fit on a CD.  Even still, the menu would not list an installer option.  If you need the firmware files and the ability to install to a disk, we recommend just using the standard hhv variant.

Legal
-----
KALI LINUX™ is a trademark of Offensive Security.

The KALI LINUX™ logo and name for this project are used with permission from Offensive Security and may not be re-used without written permission from Offensive Security.

The DC HHV logo is copyright DEF CON Hardware Hacking Village.

Disc images created may not be produced or distributed commercially (whether or not it is for profit) without written permission of Offensive Security.

This project is not produced or sponsored by Offensive Security, it was created by DEF CON Hardware Hacking Village volunteers.
