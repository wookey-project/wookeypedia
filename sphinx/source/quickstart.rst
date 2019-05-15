.. _quickstart:

Quick start
===========

.. contents::

This section describes how to build and execute the ‘blinky’ demo
on a STM32F407 Discovery board. It summarises informations thoroughly detailed
here:

- :ref:`dependencies`
- :ref:`build`
- :ref:`flash`


Pre-requisites
--------------

Install the dependencies
^^^^^^^^^^^^^^^^^^^^^^^^
To compile and to run the project, some dependencies need to be installed.
Please check the :ref:`dependencies` section to fetch them.

Fetch the project files
^^^^^^^^^^^^^^^^^^^^^^^
Once the dependencies are installed, create a working directory and then fetch
the project with ``repo`` ::

   mkdir disco407
   cd disco407
   repo init -u https://github.com/wookey-project/manifest.git -m disco407.xml
   repo sync

Build the firmware
------------------

Set the environment
^^^^^^^^^^^^^^^^^^^
Set the needed environment variables by sourcing the ``setenv.sh`` script ::

   . setenv.sh

Configuration
^^^^^^^^^^^^^
List the predefined configuration profiles ::

   make defconfig_list

Two demo examples are described in section :ref:`demo`.
To build the *blinky* project, choose the ``disco_blinky_ada_defconfig`` profile ::

   make boards/32f407disco/configs/disco_blinky_ada_defconfig

Building the binary files
^^^^^^^^^^^^^^^^^^^^^^^^^
Then, you can launch the compilation ::

   make

Flash the firmware
------------------

Once the firmware is built, you can flash a target board using the procedure
described in :ref:`flash`. Currently, only the **STM32 Discovert F407** is
supported ::

   openocd -f tools/stm32f4disco1.cfg -f tools/ocd_demo.cfg

Executing the new firmware
--------------------------
Press the black *reset button* to reset the board. You should see the
leds blinking. When the blue button is pressed, the blinking pattern changes.

The demo examples are compiled with output traces sent to USART1.
This USART uses GPIOs PB6 (TX) and PB7 (RX).
You can connect a USB-to-TTL converter to read those outputs from your host.
On Linux, the device ``/dev/ttyUSB0`` should be created when the USB-to-TTL
is succesfully connected.

Then, you can use ``minicom`` to read the messages from the USART and to have
some insight about what's happening ::

   minicom -c on -D /dev/ttyUSB0

Debugging
---------
To debug the new firmware, launch ``arm-eabi-gdb`` ::

   arm-eabi-gdb

Then, inside GDB, execute the following commands ::

   target extended-remote 127.0.0.1:3333
   mon reset halt
   symbol-file build/armv7-m/wookey/kernel/kernel.fw1.elf
   b main
   c

Going further
-------------
Read the :ref:`demo` section that roughly describes the user code
executed by the tasks. You can adapt it to run your own examples.

Troubleshooting
---------------
If you any problem while trying to build a new demo firmware, be sure that you
have carefully read the following:

- :ref:`dependencies`
- :ref:`build`
- :ref:`flash`

