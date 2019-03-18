.. _buildprocedure:

Install and build procedure
===========================

.. contents::

Install the project
-------------------

The project working directory is downloaded using repo (see :ref:`dependencies` for more information about the tool).

The installation is explained in the :ref:`repo` page.

The working directory is then deployed in the *wookey* local subdirectory. You can then enter it.

Build the project
-----------------

Set the build environment
"""""""""""""""""""""""""

First you have to set your environment to specify some paths and prefix depending on your current installation.
This permit to support various user intallations such as various GNU/Linux distros, \*BSD or MacOS installations.

This is done through the **setenv.sh** script. This script is highly documented, but here is how it works:

the setenv.sh script is the script for setting user environment in order to set the various
tools paths and names. It is separated from the Kconfig content in order to allow the user
to specify its own paths and name without having them overloaded when using
defconfig files.

The environment variables that can be configurable by the user are the following:

   * ADA_RUNTIME:[*required for Ada kernel*] The path to your Ada cross-toolchain installation. Needed if you use the Ada version of the EwoK kernel
   * ST_FLASH: The path to the st-flash tool binary, used to flash the device. This make the *make burn* operational
   * ST_UTIL: the path to the st-link tool binary, which can be useful to get informational infos about the board
   * CROSS_COMPILE:[*required*] the C cross-compiler prefix
   * USE_LLVM: activate LLVM compilation. This is an **experimental feature**, which is not fully operational. This is mostly used in order to use scan-build for code checking
   * CLANG_PATH: associated with USE_LLVM. replace gcc with clang
   * JAVA_SC_SDK:[*required*] Specify the path to the Java SmartCard Globalplatform Software Development Kit root directory. See :ref:`dependencies` for more informations.


As the user is intented to update this very variables with
this own values, this script is sourcing the local file named 'setenv.local.sh'
in the same way as OpenBSD configuration scripts. This last script is not keeped in git and is yours.
This permit to write a setenv.local.conf file with its own variables set, with a fallback to the setenv.sh variables if not needed.
The setenv.local.sh file is not requested if the following variables are correctly set for the local user's configuration.

.. hint::
   Take a look at the setenv.sh script, which is highly documented

Once you have set your environment variables in your `setenv.local.sh` script, just source the `setenv.sh` script::

In the root directory::

   $ . setenv.sh
   =========================================================
   === Tataouine environment configuration
   =========================================================

     ADA_RUNTIME   = /home/user/opt/adacore-toolchain
     ST_FLASH      = /home/user/opt/stlink/st-flash
     ST_UTIL       = /home/user/opt/stlink/st-util
     CROSS_COMPILE = arm-eabi-
     USE_LLVM      = n
     CLANG_PATH    = /usr/bin/clang-6.0
     JAVA_SC_SDK   = /opt/Jc_jdk_304

   =========================================================

Now that your environment is set, you are ready to configure and compile the project.

Configure the build target
""""""""""""""""""""""""""

In the root directory::

   $ make defconfig_list
   $ make <defconfig_file>
   $ make

When giving the defconfig file as argument, the project is configured using this file.

.. hint::
   You can use the *menuconfig* target if you wish to modify the current configuration

.. warning::
   When customizing the configure file (with *menuconfig* for instance), beware of the possible inconsistencies leading
   to non-working configurations!

Using the default target you can build the project with **make**.

The project is built in the directory set by CONFIG_BUILD_DIR in .config, in the ARCH/BOARD subdir.
For example, when choosing the 32f407discovery board in the menuconfig, the project is built in
*CONFIG_BUILD_DIR*/armv7-m/32f407discovery/. The doc are also generated in this directory.
This allows to build different configurations in different directories and keep multiple build contexts
without issues.

The menuconfig supports the search of keywords and informational descriptions for each option, see
the integrated command help for more information. The global behavior of the menuconfig is the
same as for the Linux kernel or the U-Boot one.

If you do not want to create your configuration from scratch, there is default configs in configs
dir. They can be set by calling them by their relative path, as listed in the
defconfig_list target, like for e.g.::

   $ make boards/32f407disco/configs/disco_blinky_ipc_ada_defconfig

.. warning::
   It is unwise to start a configuration from scratch, as there are a lot of possible options. It is
   easier to start from an existing defconfig file

This will set a .config file and generate the corresponding header files. The menuconfig is then no
more needed. You can still use it to update the config file generated by the defconfig.

Generate the applets
""""""""""""""""""""

The applets sources are hosted in the javacard directory. In order to compile JavaCard applets, you
need various tools on your host, including:

   * A Java SDK (SE is enough). OpenJDK 8u191 and greater should work. This SDK provides the Java compiler
   * A JavaCard SDK (specific to Globalplatform Javacard environment). This JDK can be found on
     the Oracle website

To these two JDKs, we need the ant-javacard.jar ant plugin and gb.jar globalplatform runtime. In tataouine,
we let the user chosse between:

   * compiling the opensource ant plugin and the globalplatform runtime (prepare to install maven !)
   * use precompiled version of these two files


**1. Compiling everything from the sources**

If you are ready to compile everything, install maven and the maven surefire test framework.
When it is done::

   $ make -C externals gp
   $ make -C externals antjavacard


This will generate two files: *gp.jar* and *ant-javacard.jar*, which will be copied in javacard/applet
directory.

**2. Use the preexisting releases**

If you dont want to install the overall maven dependencies, you can download directly the
archives from the opensource projects github repositories.

You can regulary check for new releases, at the time of this page write, the releases versions are
as described bellow.
You can directly download the jar files in the *javacard/applet* directory of tataouine::

   $ cd javacard/applet
   $ wget https://github.com/martinpaljak/ant-javacard/releases/download/19.03.04/ant-javacard.jar
   $ wget https://github.com/martinpaljak/GlobalPlatformPro/releases/download/19.01.22/gp.jar


Now that you have everything needed to compile the applets, you can build them::

   $ make javacard_compile

Build the firmware
""""""""""""""""""

Now that your environment is set, you have selected and configured the target and your applets are
ready, you can build the firmware::

   $ make

The firmware is built in the CONFIG_BUILD_DIRroot directory.
This directory hold two files:

   * <boardname>.hex
   * <boardname>.bin

The first file is the firmware in Intel HEX format, with its hole fullfill to avoid any cavecoding and
signature failure.
The second file is the same one, directly in binary format.

Both format can be used by usual JTAG clients such as openocd or st-flash.
See :ref:`flash` section for more information about flashing a device for the first time.

Sign and encrypt the firmware
"""""""""""""""""""""""""""""

When generating DFU image (i.e. updates for an existing board, which will be downloaded through the
firmware DFU mode), you will need to use subset of the overall firmware. The overall firmware contains
the two banks (FLIP and FLOP images) and the bootloader. the DFU images contain only one of the bank.

This is done using the *sign* target::

   $ make sign

This target will generate, aside the <boardname>.hex, the following files:

   * flip_fw.hex, flip_fw.bin, flip_fw.bin.signed
   * flop_fw.hex, flop_fw.bin, flop_fw.bin.signed

The .signed images are encrypted and include a signed header holding all the necessary informations
about the file (CRC32, calculated HASH, version number, and so on).

This file can be directly used by any DFU tool to update the target, such as standard dfu-util package.


