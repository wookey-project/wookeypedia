.. _quickstart:

Quick start
============

Welcome to the WooKey project quick start guide. The philosophy, main purpose
and features of the project are summarized in the :ref:`target` section.

To compile and to run the project, some dependencies need to be installed.
Please check the :ref:`dependencies` section to fetch them.

Once the dependencies are installed, fetch the project with ``repo``::
   repo init -u https://github.com/wookey-project/manifest.git
   repo sync

In order to download, to compile and to run the example project, including the
EwoK microkernel and some applications executing on the top of it, please refer
to the :ref:`buildprocedure` section for a step by step walk through.

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


