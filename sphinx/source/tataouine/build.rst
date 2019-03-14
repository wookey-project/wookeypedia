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

Build the firmware
""""""""""""""""""

Now that your environment is set and you have selected and configured the target, you can build
the firmware::

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

The build system internals
--------------------------

The WooKey build system is based on Makefiles and Kconfig. It requires GNU Make syntax.

Global Makefile hierarchy
^^^^^^^^^^^^^^^^^^^^^^^^^

Here is a list of the Makefiles in the project:

   * ./Makefile, manages the overall project build and the build dependencies at the project level
   * ./apps/Makefile, manages the build of the various applications, depending on the configuration (see Kconfig section)
   * ./apps/_appname_/Makefile, manages a given app build
   * ./drivers/Makefile, manages the drivers build
   * ./libs/Makefile, manages the libraries build
   * ./external/Makefile, manages the external projects build
   * ./doc/Makefile, builds the documentation

Other Makefiles (.objs, .conf, .gen) are included in theses Makefiles.

Integrating the Configuration set in Kconfig
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The configuration generated (through menuconfig) is hosted in the .config file. This file is
sourced and its variables are cleaned by the ./Makefile.conf file. This Makefile also creates a minimal
configuration to support some targets when no .config file exists. This file can be hosted from any
Makefile in the project while the variable PROJ\_FILES exists and targets the project root directory.

Some targets are common to all apps (clean, distclean, all etc.) and are therefore hosted in the
root Makefile.gen (for generic) file. This file can be hosted from any Makefile in the project while
the variable PROJ\_FILES exists and targets the project root directory.

The pretty-printing build system
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Most of the build commands are executed silently (using classical "CC   ...", "LD    ...", etc.) pretty
printing. This pretty printing is managed using the standard Linux pretty printing support.
The command are called using::

   $(call if_changed,buildcmd)

or::

   $(call cmd,buildcmd)

syntax in the Makefile targets, where:

   * `buildcmd` is the name of the command to execute
   * `if_changed` is the macro to use when the command has to be executed if any requirements have changed
   * `cmd` is the macro to use when the command has to be always executed

The macros are written in Makefile.build file. This is the very same file as the Linux Kernel and
most other files and should not be modified.

The buildcmd is the name of the command, as defined in the Makefile.build file. This file does not have
to be included explicitly, as it is included by Makefile.gen.
The buildcmd corresponds to the command name without the "(quiet\_)\_cmd\_" string.

Here is an example of a classical compilation of object files from source files:::

   %.o:%.c
   	$(call if_changed,cc_o_c)

When building in quiet mode, all commands are written in files named as the target, starting with a dot
and finishing with .cmd. As an illustration, the command used to build helpers.o is written in .helpers.o.cmd,
in the same directory as the object file.

To disable the quiet mode, just pass V=1 to the command line. All commands will be printed in the console.

Makefile.objs and configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In order to support .config-based compilation, the activation of:

   * applications
   * SoC features
   * drivers and peripherals support

is made using Makefile.objs files.

In each Makefile.objs, the corresponding variable (app-y, drv-y, etc.) is filled based on the according
configuration variable set in the .config file.

Here is an example of such a Makefile.objs:

   drv-y :=

   drv-$(CONFIG_DRV_USR_USART) += usart/

Here, drv-y is first set to (null), and then, for each option:

   * If the option is set to y (this means that the corresponding KConfig option is "bool"), the driver dir is
     added to drv-y
   * If the option is set to n, the file is added to drv-n.

All Makefile.objs fulfill their variables. Makefile.gen then includes all Makefile.objs. As said above, this
inclusion can be done from any Makefile including Makefile.gen file, whatever its directory is, while PROJ\_FILES
variable exists.

.. FIXME
As a consequence, applications Makefile can now use the Makefile.objs variables to be built. Only their own sources
(being hosted in apps/_appname_/) are neither managed by Makefile.objs nor by the Kconfig mechanism.

By now, _varname_-n is not used, yet it exists if needed. The applications Makefile only use the _varname_-y var.


