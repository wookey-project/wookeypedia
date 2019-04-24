.. _dependencies:

Dependencies
============

Some tools need to be installed in order to build your first firmware.


To fetch and to manage the project
----------------------------------

Repo
^^^^
Repo is a tool made by Google to manage the Android projects.
Installing repo is describe in the 'Install Repo' section on 
`this page <https://source.android.com/setup/build/downloading>`_.
There is also a
`repo documentation <https://source.android.com/setup/develop/repo>`_

Git
^^^


To compile the firmware
-----------------------

Perl
^^^^
The SDK uses some Perl scripts. Thus, you need to have perl installed on your
station.

Python
^^^^^^
The SDK uses some Python script.
The *python-bincopy* package is needed.

A Kconfig parser 
^^^^^^^^^^^^^^^^
Various tools for parsing and managing *Kconfig* files exist.
It's possible to use the Python *Kconfiglib*::

   pip3 install kconfiglib

It's also possible to use the *kconfig-frontends*, downloadable from it's developer's `website <http://ymorin.is-a-geek.org/download/kconfig-frontends/>`_ ::
   wget http://ymorin.is-a-geek.org/download/kconfig-frontends/kconfig-frontends-4.11.0.1.tar.bz2
   cd kconfig-frontend-upstream-latest
   ./configure
   make
   make install

On Debian Buster and higher, this software is packaged under the name *kconfig-frontends*.

GNU make
^^^^^^^^
Beware that Mac-OS uses the *BSD make*, which is not compatible.

C cross-compiler for *ARMv7-m*
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Beware to use a *none-eabi* compiler and not a *gnu-eabi* compiler.
On Debian, it's provided by the *gcc-arm-none-eabi* package.

AdaCore Ada/SPARK
^^^^^^^^^^^^^^^^^
It can be downloaded here: https://www.adacore.com/download/more

Remember to add the <install_path>/bin directory
to your PATH variable in order to be able to use the toolchain binaries without
their full paths. For this, export the proper path with and **export
PATH="/gnat/install/path/bin:$PATH"**.  

Python-IntelHex
^^^^^^^^^^^^^^^

The *IntelHex* Python module is needed to generated *.hex* and *.bin* files.
On any system having python and ``pip`` installed, just run::
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


Cryptographic tools 
-------------------

In order to sign and generate keys for firmwares, python cryptographic modules
are needed. The SDK is using the  *python-pyscard* tool for smartcard
interaction and *python-crypto* in order to handle AES cryptographic content.

.. warning:: These packages are required only for the whole WooKey project, but
             not for the demo examples.
