.. _quickstart:

Quick start
===========

To compile and to run the project, some dependencies need to be installed.
Please check the :ref:`dependencies` section to fetch them.

Once the dependencies are installed, create a working directory and then fetch
the project with ``repo`` ::

   mkdir disco407
   cd disco407
   repo init -u https://github.com/wookey-project/manifest.git -m disco407.xml
   repo sync

Then, in order to configure, to compile and to flash the example project please
refer to the :ref:`buildprocedure` section for a step by step walk through.

Two examples are provided:

  * A 'blinky' application (see :ref:`blinkyapp`): a standalone user task
    running on the top of Ewok toggles the board LEDs and waits for user button
    pressing events to switch its toggling pattern

  * A 'blinky with IPC' application (see :ref:`blinkyipcapp`): functionaly do
    the same as the 'blinky' app, but with two tasks communicating with IPC.
    On task manage the LEDs while the other receive events from the blue button.

Once the firmware is built, you can flash a target board using the procedure
described in :ref:`flash`. Currently, only the **STM32 Discovert F407** is
supported.


