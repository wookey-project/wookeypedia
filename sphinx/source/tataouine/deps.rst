.. _dependencies:

Tools needed by the SDK itself
------------------------------

Now that when the SDK is deployed, some tools need to be installed in order to
build your first firmware.

.. note::
   **TL;DR**: summary of the tools needed by the Tataouine SDK, and detailed in the next paragraphs.

   **To syncrhonize the repositories:**
       * repo

   **For the firmware compilation:**
       * *perl*
       * *python*, and specifically its *python-bincopy* package
       * A Kconfig parser
          There is no constraint on the Kconfig parser tool that can be used. Nevertheless, we have tested
          the `kconfiglib <https://github.com/ulfalizer/Kconfiglib>`_ python tool and `kconfig-frontends <https://salsa.debian.org/Philou-guest/kconfig-frontends/tree/upstream/latest>`_
       * A GNU ARM none-eabi toolchain (usually *gcc-arm-none-eabi*)
       * The *AdaCore ARM cross-toolchain* for the Ada microkernel (https://www.adacore.com/download/more)

   **For the documentation compilation:**
       * *sphinx* for the main documentation
       * *doxygen* for the technical API amnuals, and *doxygen-latex* to compile
         the generated TeX documentation

   **For the firmware flashing on the target board:**
       * *OpenOCD* **or** *st-link* (https://github.com/texane/stlink.git)


Local tools and utilities
^^^^^^^^^^^^^^^^^^^^^^^^^

Repo
""""

Repo is a tool created by Google to manage the multiple repositories of Android in order to keep a
consistent structure when building an Android image from the sources. It has been used for various
projects requiring the integration of multiple softwares in a single SDK to simplify the deployment,
development phases and integration.

Installing repo can be done by following the steps of the 'Install Repo' part of the `Android documentation <https://source.android.com/setup/build/downloading>`_.

.. hint::
   Only the install step is needed for Wookey, other steps targeting the Android project

Perl
""""

The SDK depends on perl for its internal tools (including *ldscripts* generators). You need
to have perl installed on your host. There is no specific constraint on the version of perl you use.

.. hint::
   Most of the time, no action is requested here, as perl is usually installed by default in
   many distributions

Kconfig parser
""""""""""""""

As explained before, we don't want to impose any Kconfig parsing tool to the user. There is various
tools which support parsing Kconfig files and manipulate .config configuration files.

Whe have tested kconfiglib::

   pip3 install kconfiglib

We have tested kconfig-frontends (downloadable from the `Debian salsa <https://salsa.debian.org/Philou-guest/kconfig-frontends/tree/upstream/latest>`_ repository, and installable as ususally::

   wget https://salsa.debian.org/Philou-guest/kconfig-frontends/-/archive/upstream/latest/kconfig-frontends-upstream-latest.tar.bz2
   cd kconfig-frontend-upstream-latest
   ./configure
   make

In order to let you choose the tool of your choice, you can specify the tool you which using the following variables when
calling make:

   * MCONF: the menuconfig binary
   * CONF:  the oldconfig binary
   * CONF_ARGS: the oldconfig binary options (if needed)
   * CONFGEN: the C header generation binary
   * CONFGEN_ARGS: the C header generation binary arguments (typically the path to the header, which is include/generated/autoconf.h in Wookey)

MCONF and CONF binaries are called with the Kconfig file as last argument. CONF binary supports the CONF_ARGS to add specific argument if needed, for e.g. to add *--silentoldconfig* argument.

Here is an example of custom Kconfig parser usage::

    MCONF=my_mconf_tool CONF=my_conf_tool CONF_ARGS='' CONFGEN=my_header_gen_tool \
       CONFGEN_ARGS=include/generated/autoconf.h make menuconfig


.. caution::
   Only kconfig-frontends and kconfiglib python tool have been tested with the Kconfig files of the project. The Kconfig syntax is a Linux standard, but tools may differ in their way to parse an generate the configuration file. If you have problems with another tool, check with one of the above

.. hint::
   If your tool doesn't need a separate call to a specific oldconfig and header generation tool but use a single step for the whole generation, you can use 'true' as the missing header name

Doc tools
"""""""""

If you wish to generate the documentation, you will need *doxygen* (to generate the technical manuals), and
*sphinx* (to generate the complete documentation website). As doxygen generates LaTeX sources that
need to be compiled, you also have to install a LaTeX compiler. On Debian *doxygen-latex* will do
this for you.

The sphinx documentation also depend on LaTeX source image which are converted into png image using imagemagick.
You will need *imagemagick* in order to build the sphinx documentation properly.

.. hint::
   doxygen and sphinx are proposed in nearly all the OSes and distributions. You can use these packages as there is no specific usage that would make specific requirements on them

In order to generate man pages for the kernel API and Ewok stdlib, you need rst2man tool. This tool
is a part of the python *docutils*. It is packaged, on Debian & derivative, as *python-docutils*.

About the toolchain
^^^^^^^^^^^^^^^^^^^

The goal of the SDK is to build a firmware for a microcontroler. In this case this is an armv7m based
microcontroller. As a consequence, you need a cross-toolchain to do that, including:

*GNU make*, to support the Gmake syntax of the Makefiles. Please note that BSD Make will not be able to parse the SDK Makefiles.
The cross-compiler, named in Debian *gcc-arm-none-eabi*, which is a cross-compiler for native non-GNU targets.

Beware to use a none-eabi compiler, as the target is not a GNUeabi one. The Debian distribution proposes
such packages natively if needed.

.. hint::
   On Debian, just install gcc-arm-none-eabi

If you want to compile the Ada/Spark kernel, you will need the Ada cross-toolchain. This toolchain
can be downloaded here for GNU/Linux:

https://www.adacore.com/download/more

You can download the toolchain for various host type and architectures. Beware to download the ARM ELF gnat
cross-toolchain (not the native one!).

The AdaCore GNAT toolchain will help you installing the toolchain with a graphic installer. Although, remember to add the <install_path>/bin directory to your PATH variable in order to be able to use the toolchain binaries without their full paths. For this, export the proper path with and **export PATH="/gnat/install/path/bin:$PATH"**.

.. warning::
   Having the gnat toolchain binaries in your PATH is required as the Makefiles call them directly without using a full path.

About the binary generation
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Python-IntelHex
"""""""""""""""

You need IntelHex python module (and as a consequence python) to be installed. This tool is used to
generate .hex files from multiple elf and create bin files from hex files. On Debian, IntelHex
is not packaged, but you can install it using pip or pip3 (pip3 install IntelHex).

.. hint::
   On any system having python and pip installed, just run pip3 install IntelHex to download and deploy locally the IntelHex module

Cryptographic part
""""""""""""""""""

In order to sign and generate keys for firmwares, python cryptographic modules are needed.
The SDK is using the  *python-pyscard* tool for smartcard interaction and *python-crypto* in order
to handle AES cryptographic content.

These two packages are required at build time.

About the flashing tools
^^^^^^^^^^^^^^^^^^^^^^^^

The following last dependencies are not inherent to the SDK itself: they are only necessary when interacting with
the target microcontrollers in order to **flash the firmware** produced by the SDK.

Flashing and interacting with a target usually use a JTAG/SWD interface, and dedicated tools are needed in order
to control them. Such interactions also include debugging features (through an exposed gdb server).

For STM32 based microcontrollers and the associated development boards, two open source utilities are useful:

   * OpenOCD, which is packaged in various distributions and allows to interact with the target
   * st-link (the open source version can be found on Github: https://github.com/texane/stlink.git)

OpenOCD and st-util (one of the st-link tools) can be used to connect a cross gdb (typically installed
with *gdb-arm-none-eabi*) in order to debug and interact with the execution of the microcontroller.
Breakpoints, watchpoints and many debugging features are then available to analyze the running
code.

.. hint::
   You can flash the firmware with whatever the tool you want, there is no constraints. OpenOCD and ST-link are opensource, the STMicro proprietary software also works (on Windows only), or you can use any software able to communicate with the STLinkv2 JTAG interface.
