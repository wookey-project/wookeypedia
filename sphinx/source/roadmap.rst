.. _roadmap:

Roadmap
=======

The following roadmap describes:

   * the various components planned updates
   * potential new features the project team wish to implement or to see on the Wookey ecosystem in the next months


Components planned updates
--------------------------

.. list-table::
   :widths: 20 80
   :header-rows: 1

   * - Component
     - Update
   * - ``EwoK``
     - Finalize the Ada/SPARK implementation. The ADA kernel should no more rely on any C code
   * - Tataouine
     - Support for RDP2 lock tooling through make target(s). Set device OTP area when locked
   * - Bootloader
     - Usage of flash OTP area for intelligent RDP2 lock check, in association with tataouine
   * - ``libmassstorage``
     - Moved USB BULK stack into a dedicated library. libmassstorage becomes libscsi
   * - ``STM32F4 USB driver``
     - Clean reimplementation of the USB FS/HS driver, control plane planeed as a libusbcontrol independent library
   * - ``libstd``
     - Full cleaning of the allocator implementation


Ecosystem wished updates
------------------------

.. list-table::
   :widths: 20 80
   :header-rows: 1

   * - Feature name
     - Description
   * - ``libusbrawhid``
     - RAW HID stack over USB driver, to prepare HID support for various standards such as FIDO2
   * - ``libjtag``
     - JTAG protocol stack over USB driver, to behave like a JTAG probe


.. note::
   This project is Open-Source and contributions are welcomes! If you wish to implement or update any
   software feature, merge requests are accepted
