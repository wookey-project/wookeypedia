.. _roadmap:

Roadmap
=======

About the components versioning
-------------------------------

Versions of the components
""""""""""""""""""""""""""

The WooKey project is composed of multiple software and hardware components.
These components are versioned depending on their maturity level, using the standard x.y.z triplet, where:

   * **x** is the major version
   * **y** is the minor update step
   * **z** is the current patchset

In WooKey, we consider that a software component reaches its release 1.0.0 when:

   * All the features requested by the development team have been implemented and improved
   * The code quality is good enough (this part is mostly subjective, we use various code checkers to validate RTE - Run Time Errors - absence, code complexity and style, etc.)
   * The component design is portable and generic enough (depending on the component)
   * The component documentation is complete

About component maturity
""""""""""""""""""""""""


.. image:: img/maturity.png
   :alt: maturity level
   :align: center

Maturity level consideration in WooKey:


   * Up to ``0.2``, the component is a draft, neither stable nor clean
   * Up to ``0.4``, the component has a part of the requested features written. These features may be unstable in some cases. Some other features are missing, the code architecture is not clean, the quality check and the documentation is not yet made
   * up to ``0.6``, the component is stable for a given usage, but is neither portable nor architecture-clean. It may require a cleaner rewrite (automaton design, and so on). The quality check is incomplete, the documentation may be missing
   * up to ``0.8``, the component is stable. The code architecture may require some enhancement (style, simplification, optimization). The RTE check (through static analysis and so on) should have been passed at least one time. The documentation may still be missing. All core features should be written and stable. Optional features may be missing.
   * up to ``1.0``, the component architecture should be clean. Component architecture, style, RTE check should be okay. The documentation should be written. The component reaches the 1.0 version when no part is missing
   * after ``1.0``, the `master` branch of the component evolves including new features, potential bugfixes, etc.


Life-cycle of the component and evolution of the maturity level:

   * First complete release or huge evolution with potential API incompatible content impact the major value (aka ``x``).
   * New feature releases impact the minor value (aka ``y``)
   * Bugfixes, RTE check, architecture and style updates impact the patchset value (aka ``z``)


Releases
--------

2020-june
"""""""""

This releases mostly targets advanced security and genericity features, including a complete patchset to the `SSTIC 2020 <https://www.sstic.org/2020/presentation/inter-cesti_methodological_and_technical_feedbacks_on_hardware_devices_evaluations/>`_ article including security reports of the 10 French ITSEFs.

The updates include Side-Channel attacks and Fault-injection Attacks classes protections, making the Wookey device harder to corrupt, even with advanced hardware attacks.

**New Features**
   * Advanced FIA protection and control flow integrity in bootloader
   * Advanced, resilient, RDP glitch attack detection in bootloader
   * OTP-based flash erase mechanism resilient to reset
   * Fully conforming PRNG implementation and ANSI C rand() implementation in libstd using NIST HMAC-DRBG
   * New syscall in EwoK: `sys_panic()`
   * Protection against RoP through custom trampoline implementation (which we call *handler sanitization*) for all function pointers
   * Complete new memory abstraction system in EwoK kernel, more generic and portable
   * Handle (optional) differenciate nominal vs DFU profiles for apps and libs features, to reduce footprint
   * Begining of the EwoK noRTE full SPARK support

**BugFixes**
   * Vulnerability in syscall parameters handling in EwoK patched
   * FIA weakness in libiso7816 hardened with advanced check
   * Various SCA and FIA protections in Applet and various tasks and libraries
   * Improve the secure channel SCA resistance using a random challenge from the token

Planned Updates and wishlist
----------------------------

The following roadmap describes:

   * The various components planned updates
   * Potential new features the project team wishes to implement or to see in the WooKey ecosystem in the next months


Components planned updates
""""""""""""""""""""""""""

.. list-table::
   :widths: 20 80
   :header-rows: 1

   * - Component
     - Update
   * - ``EwoK``
     - Continuing the Ada/SPARK noRTE implementation (currently being tested: 90% noRTE code coverage)
     - Preparing support for SMP architectures (reentrancy, etc.)
   * - ``Tataouine``
     - Enhancement of RDP2 lock tooling through make target(s). Include other ARMv7M and other arches targets
   * - ``Bootloader``
     - Now that OTP-based erase mechanism and advance FIA protection is made, starting Frama-C anotations of the bootloader
   * - ``STM32F4 USB driver``
     - USB xDCI is now ready, associated to USB OTG HS and USB OTG FS drivers. Upper stack to be updated
   * - ``libstd``
     - Full cleaning of the allocator implementation to continue


Ecosystem wished updates
""""""""""""""""""""""""

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
   This project is Open-Source and contributions are welcome! If you wish to implement or update any
   software feature, merge requests are accepted


.. hint::
   Community updates or evolution is supported through classical github `pull requests <https://help.github.com/en/articles/about-pull-requests>`_
