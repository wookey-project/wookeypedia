.. _build:

Configuring and building a new firmware
=======================================

.. contents::

Pre-requisites
--------------

To compile and to run the project, some dependencies need to be installed.
Please check the :ref:`dependencies` section to fetch them.

Fetch the project files
-----------------------

Once the dependencies are installed, create a working directory and then fetch
the project with ``repo`` ::

   mkdir disco407
   cd disco407
   repo init -u https://github.com/wookey-project/manifest.git -m disco407.xml
   repo sync

The ``disco407.xml`` is called a *manifest file*. It's
used to deploy a complete image of the SDK by cloning multiple git repositories
depending on this profile.

Set the environment
-------------------

Then, set some needed environment variables by sourcing the
``setenv.sh`` script ::

   . setenv.sh

The following table shows the variables set by this script.

.. list-table::
   :widths: 20 80
   :header-rows: 1

   * - Variable
     - Description
   * - ``ADA_RUNTIME``
     - Path to the Ada cross-toolchain installation.
   * - ``ST_FLASH``
     - Path to the *st-flash* binary, used to flash the device.
       Needed by the *make burn* target.
   * - ``ST_UTIL``
     - To the *st-link* binary, which can be useful to get
       informational infos about the board
   * - ``CROSS_COMPILE``
     - Prefix used by the C cross-compiler
   * - ``USE_LLVM``
     - **Experimental feature**. Compile with LLVM instead of GCC.
       Not fully operational, mostly used for debugging purpose
       (scan-build for code checking).
   * - ``CLANG_PATH``
     - Replace gcc with clang
   * - ``JAVA_SC_SDK``
     - Path to the Java SmartCard Globalplatform Software Development Kit root
       directory.

.. hint::
   Take a look at the ``setenv.sh`` script, which is highly documented

Most of the time, the paths proposed in this script are not the one you use in
your specific installation. 
If you need to overload some of those variables, you should not directly edit
the ``setenv.sh`` script. Instead, create a ``setenv.local.sh`` file in the
same directory and set the variables in this file.  

Once you have set your environment variables in your ``setenv.local.sh``
script, just source the ``setenv.sh`` script as described above.


Configure the target
--------------------

To list the predefined configuration profiles, use the *defconfig\_list* target ::

   make defconfig_list

If you get an error message like '*m_config.mk: Recursive variable
'CROSS_COMPILE' references itself*', check that you have sourced
the ``setenv.sh`` file as explained above.
Then, you can select a configuration profile ::

   make <defconfig_file>

For example ::

   $ make defconfig_list
   LISTDEFS   defconfig_list
   boards/32f407disco/configs/disco_blinky_ada_defconfig
   boards/32f407disco/configs/disco_blinky_defconfig
   boards/32f407disco/configs/disco_blinky_ipc_ada_defconfig
   boards/32f407disco/configs/disco_blinky_ipc_defconfig
   boards/32f407disco/configs/disco_svctests_ada_defconfig
   $ make boards/32f407disco/configs/disco_blinky_ipc_ada_defconfig

Then, to customize the profile, run *menuconfig* ::

   make menuconfig

.. warning::
   When customizing the profile with *menuconfig*, beware
   of the possible inconsistencies leading to non-working configuration!


Build the firmware
------------------

Simply run ::

   make

The project and the whole documentation are built in the directory set by the
``CONFIG_BUILD_DIR`` variable in the ``.config`` file.

This directory hold two files: ``<boardname>.hex`` and ``<boardname>.bin``.
The first file is the firmware in *Intel HEX* format, with its hole fullfill to
avoid any cavecoding and signature failure.
The second file is the same one, directly in binary format.

Both format can be used by usual JTAG clients such as *openocd* or *st-flash*.
See :ref:`flash` section for more information about flashing a device for the
first time.


Build the applets
-----------------

.. warning:: Required only for the whole WooKey project relying on an external
             token, but not for the demo examples described in section :ref:`demo`.

Install extra-dependencies
^^^^^^^^^^^^^^^^^^^^^^^^^^

The applets sources are hosted in the ``javacard/`` directory.
In order to compile JavaCard applets, you will need various tools:

   * A *Java SDK*, that provide a Java compile. *OpenJDK 8u191* or greater should work.

   * A *JavaCard SDK* (specific to Globalplatform Javacard environment). This JDK
     can be found on the Oracle website.

   * Two jars:
     * ``ant-javacard.jar``
     * ``gb.jar``

To use a precompile version of ``ant-javacard.jar`` and ``gb.jar``,
you can directly download them ::

   cd javacard/applet
   wget https://github.com/martinpaljak/ant-javacard/releases/download/19.03.04/ant-javacard.jar
   wget https://github.com/martinpaljak/GlobalPlatformPro/releases/download/19.01.22/gp.jar

If you prefer to compile them from the source, you first need to install
*maven* and the *maven surefire test* framework. Then ::

   make -C externals gp
   make -C externals antjavacard

This will generate the two jars files and it will copy them in the
``javacard/applet`` directory.

Compile the applets
^^^^^^^^^^^^^^^^^^^
To compile the applets ::

   make javacard_compile
   make javacard_push

You might have an error like this one:

*Error [...] you have asked to use one smartcard per token.Please insert a
virgin token*

The reason is that by default, the menuconfig is configured so that we use
some dedicated smartcard for each cryptographic usage. You can use a single
smartcard by unsetting the following option in menuconfig:

*Use a dedicated (different) physical smartcard for each token type
(AUTH/DFU/<SIG>)*

.. warning:: Using a single smartcard is not recommanded.

Sign and encrypt the firmware
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When generating DFU images (i.e. updates for an existing board, which will be
downloaded through the firmware DFU mode), you will need to use subset of the
overall firmware. The overall firmware contains the two banks (FLIP and FLOP
images) and the bootloader. the DFU images contain only one of the bank.

This is done using the *sign* target ::

   make sign

This target will generate, aside the <boardname>.hex, the following files:

   * flip_fw.hex, flip_fw.bin, flip_fw.bin.signed
   * flop_fw.hex, flop_fw.bin, flop_fw.bin.signed

The *.signed* images are encrypted and include a signed header holding all the
necessary informations about the file (CRC32, calculated HASH, version number,
and so on).

This file can be directly used by any DFU tool to update the target, such as
standard dfu-util package.


Build the documentation
-----------------------

If you wish to build **all** the documentation, you can execute the *doc*
target ::

   make doc

This will build the following content

   * The sphinx website (including all the documentation, helpers, principles
     and security explanations)
   * The man pages of the kernel and libstd API
   * The Doxygen-generated datasheets, less readable than sphinx but including
     all the API and structures.

You can also build only the sphinx website if you prefer not to install doxygen
and the (heavy) LaTeX backend with the following command ::

   make -C doc sphinx


