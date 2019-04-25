.. _dependencies:

Dependencies
============

Some tools need to be installed in order to build your first firmware.

.. contents::


To fetch and to manage the project
----------------------------------

Repo
^^^^
The WooKey project deployment depends on repo, a tool made by Google to manage
the Android projects.
It allows the support of various profiles and various end-user applications,
drivers and libraries without requiring complex modification of the SDK.

Installing repo is describe in the 'Install Repo' section on
`this page <https://source.android.com/setup/build/downloading>`_.

There is also a
`repo documentation <https://source.android.com/setup/develop/repo>`_

On Debian Buster and higher, this software is packaged under the name *repo* ::

   apt-get install repo

Git
^^^
*Git* distributed version-control system.
On Debian Buster and higher, this software is packaged under the name *git* ::

   apt-get install git

To compile the firmware
-----------------------

Perl
^^^^
The SDK uses some Perl scripts. It should already be installed on your station.

Python
^^^^^^
The SDK uses some Python script.
The *python-bincopy* package is needed ::

   pip3 install bincopy

This tool is used to generate .hex files from multiple elf files when
generating the firmware.

A Kconfig parser
^^^^^^^^^^^^^^^^
Various tools for parsing and managing *Kconfig* files exist.
It's possible to use the Python library *kconfiglib* ::

   pip3 install kconfiglib


It's also possible to use the *kconfig-frontends*, downloadable from it's developer's `website <http://ymorin.is-a-geek.org/download/kconfig-frontends/>`_ ::

   wget http://ymorin.is-a-geek.org/download/kconfig-frontends/kconfig-frontends-4.11.0.1.tar.bz2
   cd kconfig-frontend-upstream-latest
   ./configure
   make
   make install

On Debian Buster and higher, this software is packaged under the name *kconfig-frontends* ::

   apt-get install kconfig-frontends

By overloading the KCONF variable (see :ref:`buildprocedure`), you can use an other Kconfig parser.

GNU make
^^^^^^^^
Beware that Mac-OS uses the *BSD make*, which is not compatible ::

   apt-get install make

C cross-compiler for *ARMv7-m*
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Beware to use a *none-eabi* compiler and not a *gnu-eabi* compiler.
On Debian, it's provided by the *gcc-arm-none-eabi* package ::

   apt-get install gcc-arm-none-eabi

You might also need to install *binutils* for *ARMv7-m* ::

   apt-get install binutils-arm-none-eabi

AdaCore Ada/SPARK
^^^^^^^^^^^^^^^^^
It can be downloaded here: https://www.adacore.com/download/more
We recommand you to install the binaries in ``/opt/adacore-arm-eabi``.

Remember to set your PATH environement variable ::

    export PATH="/opt/adacore-arm-eabi/bin:$PATH"

Python-IntelHex
^^^^^^^^^^^^^^^

The *IntelHex* Python module is needed to generated *.hex* and *.bin* files.
On any system having python and ``pip`` installed, just run ::

   pip3 install IntelHex


To flash the firmware on the target board
-----------------------------------------
To flash the newly compiled firmwares on STM32 based microcontrollers and the
associated development boards, you can use one of those two open source
utilities:

   * OpenOCD, which is packaged in various distributions and allows to interact
     with the target
   * ST-link (the open source version can be found on Github:
     https://github.com/texane/stlink.git)

On Debian, *openocd* package is available ::

   apt-get install openocd

Note that *openocd* and *st-link* can also be used to debug the platform by
connecting *gdb-arm-none-eabi*.

Note also that the ST-Micro proprietary software also works on Windows, or you
can use any software able to communicate with the STLinkv2 JTAG interface.


To compile the documentation
----------------------------
To generate the whole documentation, the following utilities need to be installed:

- *Doxygen*
- *Doxygen-latex*
- *Sphinx*
- *Imagemagick*
- *rst2man*, which is part of the *python-docutils* package on Debian.

On debian ::

   apt-get install doxygen
   apt-get install doxygen-latex
   apt-get install python-sphinx
   apt-get install imagemagick
   apt-get install python-docutils


Cryptographic tools
-------------------

.. warning:: Cryptographic packages are required only for the whole WooKey project, but
             not for the demo examples.

In order to sign and generate keys for firmwares, python cryptographic modules
are needed. The SDK is using the  *python-pyscard* tool for smartcard
interaction and *python-crypto* in order to handle AES cryptographic content.

On debian ::

   apt-get install python-pyscard
   apt-get install python-crypto


