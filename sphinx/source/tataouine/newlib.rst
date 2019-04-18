Creating a new library
======================

What is an EwoK userspace library ?
-----------------------------------

A library, in the EwoK terminology, is an implementation of a portable toolkit or protocol stack in order
to share useful content between applications.
Libraries are statically linked to each application requiring it, which means that there is no runtime shared objects. As a consequence, libraries, like drivers, must be position independent.

.. danger::
   Do not write position-dependent code in libraries


An EwoK userspace library usually provides:

   * A protocol stack (SCSI, DFU, ISO7816, Ethernet, ...)
   * A toolkit (graphic user interface API, firmware handling API, ...)


EwoK libraries can depend on each others and on drivers. Although, take care to make at most portable as possible the library/driver interactions to support driver substitution from a given target board to another target board.

The library source directory
----------------------------

The library root directory is held in the libs/ directory in the *Tataouine* directories hierarchy.

A library should be named wisely, depending on its content. When implementing a protocol stack, please name the library after the corresponding protocol stack name.

.. hint::
   A library should not require a specific permission. Only on rare cases (e.g. for TRNG access) a permission can be requested. Other permissions (like device access permission) are handled by the driver with which the library is communicating

About the library integration
"""""""""""""""""""""""""""""

A basic library requires only the following files:

   * A Makefile, holding the basic build target
   * A Kconfig file, to (en|dis)able the library
   * one source file, whatever its name is
   * an *api/* directory, which hold the library API

.. warning::
   By convention, the library API should be named using the library name


About the library build mechanism
--------------------------------

The library's Makefile
""""""""""""""""""""""

A library's Makefile is short and straightforward. Like drivers Makefile, it looks like the following (for the DFU stack library)::

   ###################################################################
   # About the library name and path
   ###################################################################

   # library name, without extension
   LIB_NAME ?= libdfu

   # project relative root directory
   PROJ_FILES = ../../

   # library name, with extension
   LIB_FULL_NAME = $(LIB_NAME).a

   # SDK helper Makefiles inclusion
   -include $(PROJ_FILES)/m_config.mk
   -include $(PROJ_FILES)/m_generic.mk

   # use an app-specific build dir
   APP_BUILD_DIR = $(BUILD_DIR)/libs/$(LIB_NAME)

   ###################################################################
   # About the compilation flags
   ###################################################################

   CFLAGS += $(LIBS_CFLAGS)
   CFLAGS += -MMD -MP

   #############################################################
   # About library sources
   #############################################################

   SRC_DIR = .
   SRC = $(wildcard $(SRC_DIR)/*.c)
   OBJ = $(patsubst %.c,$(APP_BUILD_DIR)/%.o,$(SRC))
   DEP = $(OBJ:.o=.d)

   OUT_DIRS = $(dir $(OBJ))

   # file to (dist)clean
   # objects and compilation related
   TODEL_CLEAN += $(OBJ)
   # targets
   TODEL_DISTCLEAN += $(APP_BUILD_DIR)

   ##########################################################
   # generic targets of all libraries makefiles
   ##########################################################

   .PHONY: app doc

   default: all

   all: $(APP_BUILD_DIR) lib

   doc:

   show:
   	@echo
   	@echo "\tAPP_BUILD_DIR\t=> " $(APP_BUILD_DIR)
   	@echo
   	@echo "C sources files:"
   	@echo "\tSRC_DIR\t\t=> " $(SRC_DIR)
   	@echo "\tSRC\t\t=> " $(SRC)
   	@echo "\tOBJ\t\t=> " $(OBJ)
   	@echo

   lib: $(APP_BUILD_DIR)/$(LIB_FULL_NAME)

   $(APP_BUILD_DIR)/%.o: %.c
   	$(call if_changed,cc_o_c)

   $(APP_BUILD_DIR)/$(LIB_FULL_NAME): $(OBJ) $(ARCH_OBJ)
   	$(call if_changed,mklib)
   	$(call if_changed,ranlib)

   $(APP_BUILD_DIR):
   	$(call cmd,mkdir)

   -include $(DEP)


Considering that the sources are hold in the library root directory. Only
the *LIB_NAME* variable needs to be updated. The other part of the Makefile
are generic to any library.

Here, we see that the library's Makefile support the following targets:

   * all (and default): build the library
   * doc: build the doc, if there is some
   * show: show the library build info (sources, objects, etc.)
   * lib: called by all target, build the library

You should not need to take care about CFLAGS, as libraries CFLAGS are
distributed by the LIBS_CFLAGS variable. Although, it is possible
to add any other compilation flag if needed.

.. hint::
   A usual case is to add the -MMD -MP compilation flags to generate the sources dependency tree

.. hint::
   A typical update of the CFLAGS variable can be to add an explicit optimisation flag, which will override the overall project default optimisation flag

.. danger::
   Beware to use **CFLAGS +=** to keep the previous CFLAGS content


The libraries build directory
"""""""""""""""""""""""""""""

All libraries are built in their *APP_BUILD_DIR* directory. This directory must
be named as shown above. for DFU library, all library's built files are hold in the $(BUILD_DIR)/libs/libdfu directory.

In this directory, you will find:

   * The library object files (.o)
   * The library itself (lib*<libname>*.a)
   * All the object and library compilation commands

The library's compilation command files are hold in files named like the corresponding object file, prefixed with a dot, finishing with a .cmd extension.
For example, if the library's Makefile has built the *dfu.o* file, from the *dfu.c* file, the compilation step can be found in the library's build directory under the name *.dfu.o.cmd*

Configuring the library
"""""""""""""""""""""""

The library source root directory must hold a Kconfig file. This file will be automatically loaded by the configuration mechanism and will make your library appear in the libraries list.

Each library's Kconfig must contain, at least, the following::

   config USR_LIB_DFU
     bool  "userspace DFU stack library"
     default n
     ---help---
     This is an USB DFU device-side protocol stack implementation

.. danger::
   The Kconfig library entry **must** be named using the following: USR_LIB_*<drvname>*. This is required as the library list and library CFLAGS list is calculated using the USR_LIB prefix.

A library, like other EwoK userspace components, can have various other configuration items in this same file. Here is an example of such a more complete configurable library Kconfig file::

   config USR_LIB_DFU
     bool  "userspace DFU stack library"
     default n
     ---help---
     This is an USB DFU device-side protocol stack implementation

   if USR_DRV_DFU

   menu "DFU stack options"

   config USR_LIB_DFU_UPLOAD
      bool "enable upload support"
      default n
      ---help---
         This option allow the device to upload its firmware to the host

   config USR_LIB_DFU_OTHER
      bool "enable other support"
      default y
      ---help---
         This option help

   endmenu

   endif

.. warning::
   You are free to add whatever entry you wish in the library's Kconfig file, but each entry **must be named with the library Kconfig prefix**. This avoid any collision or errors. It also helps when grep'ing in the generated .config file

Integrating your library to the Tataouine SDK
"""""""""""""""""""""""""""""""""""""""""""""

This is done by updating the manifest file to add your library repository. Add your library to the corresponding path (libs/<yourlib>), as described above. The SDK automatically detects that your library is added and integrates it to the configuration subsystem.

Now, you only have to activate it using menuconfig, in the same way you configure the Linux kernel, by executing::

   make menuconfig

Go to Userspace drivers and features, Libraries. You should see your library and should be able to activate it. Until your configuration is saved, you can now directly compile and flash the new version of the firmware with an application using your library integrated in it.

