.. _newdrv:

Creating a new Driver
=====================

What is an EwoK userspace driver?
---------------------------------

A driver, in the EwoK terminology, is built as a userspace library. This library holds the necessary
functions to initialize and configure a given device and to provide a high level API that should
abstract the device internals (registers, device address, specific behavior) from the upper layer.

An EwoK driver is allowed to use the following:

   * The EwoK kernel API
   * The EwoK libstd library

An EwoK driver may, but this should be a voluntary and explicit action, depend on another driver.
A typical example is a low level iso7816 driver, which manipulates an USART interface, requiring to
communicate with the USART driver.

.. danger::
   Dependencies between drivers should be an exception. The usual way is a standalone, autonomous implementation for
   a dedicated and well defined device

.. warning::
   A driver **should not** depend on a userspace library. Libraries are portable components that are hold generic stacks and helper algorithms, but should not provide content to any driver. The libstd is the only exception as it is the EwoK kernel abstraction library

The driver source directory
---------------------------

The driver root directory can be hold in two places in the *Tataouine* directory hierarchy:

   * drivers/socs/*<socname>* for SoC-specific drivers
   * drivers/boards/*<boardname>* for board drivers (usually external peripheral drivers)

SoC drivers handle the implementation of one of the target SoCs (System on Chip) internal hardware devices.
SoCs content depend on the SoC architecture and family, and usually embed a huge number of devices.

Board drivers handle the implementation of any peripheral that is connected to the SoC through any
of its I/O lines. A typical example is a touchscreen, an external memory controller and so on.
These peripherals are connected to the SoC using one of its I/O. This means that they depend on a
SoC driver which handles the SoC I/O device through a bus (SPI bus, I2S bus, etc.)


Given a device name AIO4237 (whatever this device does), let's imagine the associated device driver.
To avoid any misunderstanding on the driver usage, we name the driver accordingly: *aio4237*.

.. warning::
   Beware to name your driver properly. This is mostly important for board drivers as peripheral list may vary and be more or less complex depending on the board. A good name avoids unpleasant collision or misunderstanding between the various drivers needed

If this device is a SoC device, the driver will be stored in drivers/socs/*<socname>*/aio4237.
If this device is a board device, the driver will be stored in drivers/board/*<boardname>*/aio4237.

Sources integration
"""""""""""""""""""

A basic driver requires only the following files:

   * A Makefile, holding the basic build target
   * A Kconfig file, to (en|dis)able the driver
   * At least one source file, whatever its name is
   * An *api/* directory, which contains the driver API for upper stacks

.. warning::
   By convention, the driver API should be named using the driver name. Here, the API file would be *aio4237.h*. This avoids any header collision


Build mechanism
---------------

The driver's Makefile
"""""""""""""""""""""

A driver's Makefile is short and straightforward. It looks like the following::

   ###################################################################
   # About the driver name and path
   ###################################################################

   # driver library name, without extension
   LIB_NAME ?= libaio4237

   # project relative root directory
   PROJ_FILES = ../../../../

   # driver library name, with extension
   LIB_FULL_NAME = $(LIB_NAME).a

   # SDK helper Makefiles inclusion
   -include $(PROJ_FILES)/m_config.mk
   -include $(PROJ_FILES)/m_generic.mk

   # use an app-specific build dir
   APP_BUILD_DIR = $(BUILD_DIR)/drivers/$(LIB_NAME)

   ###################################################################
   # About the compilation flags
   ###################################################################

   CFLAGS += $(DRIVERS_CFLAGS)
   CFLAGS += -MMD -MP

   #############################################################
   # About driver sources
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


Considering that the sources are hold in the driver root directory. Only
the *LIB_NAME* variable needs to be updated. The other part of the Makefile
are generic to any driver.

Here, we see that the driver's Makefile support the following targets:

   * all (and default): build the driver
   * doc: build the doc, if there is some
   * show: show the drivers build info (sources, objects, etc.)
   * lib: called by all target, build the driver

You should not need to take care about CFLAGS, as drivers CFLAGS are
distributed by the DRIVERS_CFLAGS variable. Although, it is possible
to add any other compilation flag if needed.

.. hint::
   A usual case is to add the -MMD -MP compilation flags to generate the sources dependency tree

.. hint::
   A typical update of the CFLAGS variable can be to add an explicit optimisation flag, which will override the overall project default optimisation flag

.. danger::
   Beware to use **CFLAGS +=** to keep the previous CFLAGS content


The driver's build directory
""""""""""""""""""""""""""""

Any driver is built in the *APP_BUILD_DIR* directory. This directory must
be named as shown above. All drivers objects files and libraries are hold in the $(BUILD_DIR)/drivers/lib*<drivername>* directories.

In the driver build directory, you will find:

   * The driver object files (.o)
   * The driver library (libaio4237.a)
   * All the object and library compilation commands

The driver's compilation command files are hold in files named like the corresponding object file, prefixed with a dot, finishing with a .cmd extension.
For example, if the driver's Makefile has built the *aio4237.o* file, from the *aio4237.c* file, the compilation step can be found in the driver's build directory under the name *.aio4237.o.cmd*

Configuring the driver
""""""""""""""""""""""

The driver source root directory must hold a Kconfig file. This file will be automatically loaded by the configuration mechanism and will make your driver appear in the drivers list.

Each driver's Kconfig must contain, at least, the following::

   config USR_DRV_AIO4237
     bool  "userspace AIO4237 driver library"
     default n
     ---help---
     This is the sample aio4237 device driver implementation

.. danger::
   The Kcofnig driver entry **must** be named using the following: USR_DRV_*<drvname>*. This is required as the driver list and drivers CFLAGS list is calculated using the USR_DRV prefix.

A driver, like other EwoK userspace components, can have various other configuration items in this same file. Here is an example of such a more complete configurable driver Kconfig file::

   config USR_DRV_AIO4237
     bool  "userspace AIO4237 driver library"
     default n
     ---help---
        This is the sample aio4237 device driver implementation

   if USR_DRV_AIO4237

   menu "aio4237 driver options"

   config USR_DRV_AIO4237_MYOPT
      bool "enable myopt support"
      default n
      ---help---
         This option help

   config USR_DRV_AIO4237_OTHER
      bool "enable other support"
      default y
      ---help---
         This option help

   endmenu

   endif

.. warning::
   You are free to add whatever entry you wish in the driver Kconfig file, but each entry **must be named with the driver Kconfig prefix**. This avoids any collision or errors. It also helps when grep'ing in the generated .config file

Integrating your driver to the Tataouine SDK
""""""""""""""""""""""""""""""""""""""""""""

This is done by updating the manifest file to add your driver repository. Add your driver to the corresponding path, as described above. The SDK automatically detects that your driver is added and integrates it to the configuration subsystem.

Now, you only have to activate it using menuconfig, in the same way you configure the Linux kernel, by executing::

   make menuconfig

Go to 'Userspace drivers and features, Drivers'. You should see your driver and should be able to activate it. Until your configuration is saved, you can now directly compile and flash the new version of the firmware with an application using your driver integrated in it.

Interacting with devices
------------------------

Getting device information
""""""""""""""""""""""""""

All devices have their own datasheet, describing their behavior and programming interface. SoC devices are described in the SoC developer's guide.
In Tataouine, the device list is handled through a unique JSON file:

   * layout/arch/socs/*<socname>*/soc-devmap-*<boardname>*.json

This file hold all the necessary information for device drivers developers, including:

   * The device **type** (*block*, which means that the device is memory mapped, host in the SoC) or *peripheral*, which means that the device is onboard, accessed through an I/O bus
   * The device **address** (when the device is memory mapped)
   * The device **size** (when the device is memory mapped)
   * The device associated **gpio** list. Each GPIO pin/port couple is associated to a canonical name. Only block devices communicating with the outside world have GPIOs
   * The device associated **irq** list. Each IRQ is associated to a canonical name
   * The device associated **dma** channels, for device supporting DMA transactions from or toward the device
   * The device associated EwoK **permission**. This permission will be required when the device is requested by the userspace task

Other fields (RCC clocks and registers) are used by the EwoK kernel to enable the device input clock.

The JSON file is used in order to generate, for each device, a static const structure which can be used by the driver to declare the device information without
being SoC or board specific. This allows to keep the driver implementation portable between various SoCs or boards using the same device.

All information about how devices header are generated and named can be found in the :ref:`hardware layout chapter <layout>`.

The way this structure is used by the device driver is described below.

Declaring the device
""""""""""""""""""""

In EwoK paradigm (see the EwoK API documentation), each application is executed respecting two sequential phases:

   * One init phase, in which the application can declare resources (including devices)
   * One nominal phase, in which the application can use declared resources

As a consequence, in the EwoK drivers terminology, each driver's initialization API is separated in two independent functions:

   * The declaration function, to register the device
   * The device configuration function, to set registers and devices inner interfaces

We have defined the following naming system:

   * *aio4237_early_init()* is called during the init phase and declare the resources against the microkernel
   * *aio4237_init()* configure the device once it is mapped, during the nominal phase


.. danger::
   Beware not to access the device during the early initialization phase. During this phase, the device is **not** mapped and this would lead to a memory fault

.. danger::
   Don't try to declare any ressource (device or other) out of the early_init function, as other functions are called after the end of the init phase. The kernel refuses any ressource registration until the init phase is completed

The early_init function typically uses the sys_init(INIT_DEVACCESS) EwoK syscall to request a new device.
The complete usage of this syscall to declare a new device is explained in the :ref:`EwoK complete API explanation <ewok-devices>`.

.. hint::
   Be careful of the way devices have to be declared. GPIOs, IRQs and Posthooks principles are deeply described in the :ref:`EwoK API documentation <ewok-devices>` and must be respected

As explained before, fulfilling the device information is done for most of the device elements by using the generated device header.
When using the generated header described in the :ref:`Hardware layout <layout>` page, a typical device declaration would look like the following::

   static device_t  aio4237_dev;
   static int       aio4237_desc;
   static const     char devname[] = "aio4237";

   [...]

   mbed_error_t aio4237_early_init(void)
   {
     /* memsetting device_t struct to 0. This is requested as EwoK is paranoid */
     memset(&aio4237_dev, 0x0, sizeof(device_t));
     /* setting device address, size, irqs and gpios numbers */
     strncpy(aio4237_dev.name, devname, strlen(devname));
     aio4237_dev.address = aio4237_dev_infos.address;
     aio4237_dev.size = aio4237_dev_infos.size;
     aio4237_dev.irq_num = 1;
     aio4237_dev.gpio_num = 2;
     /* setting map mode to auto (mapped until end of init phase) */
     aio4237_dev.map_mode = DEV_MAP_AUTO;

     /* declaring IRQ handler and posthooks (see EwoK API) */
     aio4237_dev.irqs[0].handler = my_aio4237_irq_handler;
     aio4237_dev.irqs[0].irq = AIO4237_IRQ;
     aio4237_dev.irqs[0].mode = IRQ_ISR_STANDARD;

     aio4237_dev.irqs[0].posthook.status = 0x0000; /* SR register */
     aio4237_dev.irqs[0].posthook.data   = 0x0004; /* DR register */

     aio4237_dev.irqs[0].posthook.action[0].instr = IRQ_PH_READ;
     aio4237_dev.irqs[0].posthook.action[0].read.offset = 0x0000; /* SR register */

     aio4237_dev.irqs[0].posthook.action[1].instr = IRQ_PH_READ;
     aio4237_dev.irqs[0].posthook.action[1].read.offset = 0x0004; /* DR register */

     aio4237_dev.irqs[0].posthook.action[2].instr = IRQ_PH_WRITE;
     aio4237_dev.irqs[0].posthook.action[2].write.offset = 0x0000;
     aio4237_dev.irqs[0].posthook.action[2].write.value  = 0x00;
     aio4237_dev.irqs[0].posthook.action[2].write.mask   = 0x3 << 6; /* clear TC & Tx status */

     /* declaring device's GPIO (RX and TX port to external world) */
     aio4237_dev.gpios[0].kref.port = aio4237_dev_infos.gpios[AIO4237_TX].port;
     aio4237_dev.gpios[0].kref.pin = aio4237_dev_infos.gpios[AIO4237_TX].pin;
     aio4237_dev.gpios[0].mask =
       GPIO_MASK_SET_MODE | GPIO_MASK_SET_TYPE | GPIO_MASK_SET_SPEED |
       GPIO_MASK_SET_PUPD | GPIO_MASK_SET_AFR;
     aio4237_dev.gpios[0].type = GPIO_PIN_OTYPER_PP;
     aio4237_dev.gpios[0].pupd = GPIO_NOPULL;
     aio4237_dev.gpios[0].mode = GPIO_PIN_ALTERNATE_MODE;
     aio4237_dev.gpios[0].speed = GPIO_PIN_VERY_HIGH_SPEED;
     aio4237_dev.gpios[0].afr = aio4237s[config->aio4237].af;

     aio4237_dev.gpios[1].kref.port = aio4237_dev_infos.gpios[AIO4237_RX].port;
     aio4237_dev.gpios[1].kref.pin = aio4237_dev_infos.gpios[AIO4237_RX].pin;
     aio4237_dev.gpios[1].mask =
       GPIO_MASK_SET_MODE | GPIO_MASK_SET_TYPE | GPIO_MASK_SET_SPEED |
       GPIO_MASK_SET_PUPD | GPIO_MASK_SET_AFR;
     aio4237_dev.gpios[1].afr = aio4237s[config->aio4237].af;
     aio4237_dev.gpios[1].mode = GPIO_PIN_ALTERNATE_MODE;
     aio4237_dev.gpios[1].speed = GPIO_PIN_VERY_HIGH_SPEED;
     aio4237_dev.gpios[1].type = GPIO_PIN_OTYPER_PP;
     aio4237_dev.gpios[1].pupd = GPIO_NOPULL;

     /* now let's declare the device against the kernel */
     ret = sys_init(INIT_DEVACCESS, &aio4237_dev, &aio4237_desc);
     if (ret != SYS_E_DONE) {
       printf("Error while declaring device: %d\n", ret);
       goto err;
     }
     return MBED_ERROR_NONE;
     err:
     return MBED_ERROR_DENIED;
   }


.. hint::
   From all your device driver API, take care to use the libstd mbed_error_t return type instead of custom return types. This allows to use unified, embedded systems centric return values which permit to simplify the applications and libraries API handling. This type is defined in the libc/types.h header of the libstd


