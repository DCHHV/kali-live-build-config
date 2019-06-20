Kali Linux™ live-build-config DC HHV Edition
===========================================

This is a fork of the Kali Linux™ live-build-config image creation tool.  We have added variants for hardware hacking specific tools.  The default Kali distribution is great but some of the more esoteric compilers, programmers, and debugging tools are not readily included in the base packages.  We have created a Kali build variant that includes these and other customizations.

Contributions
-------------
We welcome any feedback or pull requests.  If there is a package we missed that you find yourself using, let us know and we can bring it in to our configs.

Variants
--------
We created a customized "variant-hhv" Kali configuration. This includes nearly every electronics or scientific package available through Kali. It is intended to fit on a DVD, weighing in around 2 GB in size. All of the standard Kali features are available, including firmware, installation options, and access to the kali-rolling repositories.

Building
--------
Building is meant to take place inside of a kali-rolling installation.  This is because this set of build scripts expects to have access to kali-rolling apt repos and package aliases.  Setting this up is beyond the scope of our help.  Boot an existing live CD, install from live CD, set up a chroot, etc.  

Kali documentation is a great place to start: https://docs.kali.org/development/live-build-a-custom-kali-iso

Once in a kali-rolling environment, building can be done with:

`sudo apt install curl git live-build cdebootstrap`

`./build.sh --distribution kali-rolling --variant hhv -v`

Legal
-----
KALI LINUX™ is a trademark of Offensive Security.

The KALI LINUX™ logo and name for this project are used with permission from Offensive Security and may not be re-used without written permission from Offensive Security.

The DC HHV logo is copyright DEF CON Hardware Hacking Village.

Disc images created may not be produced or distributed commercially (whether or not it is for profit) without written permission of Offensive Security.

This project is not produced or sponsored by Offensive Security, it was created by DEF CON Hardware Hacking Village volunteers.
