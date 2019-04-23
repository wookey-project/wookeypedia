.. _targetofproject:

The WooKey project
=====================

.. contents::

Context
-------

Securing the USB stack, and hence the USB hosts and devices, has been a growing
subject of research since exploitable flaws have been revealed with the BadUSB
threat [nohl2014badusb]_.

Firmwares, hosts Operating Systems, as well as user data
confidentiality are at risk. This can have critical
consequences knowing that USB mass storage devices are used to transfer public
or confidential data between different machines, including in air gaped
networks.

Target usage of WooKey
----------------------

The Wookey is a custom STM32 based USB thumb drive with mass storage capabilities
designed for user data encryption and protection, with a full-fledged set of in-depth security defenses.

The WooKey project aims at prototyping a secure and trusted USB mass storage
device featuring user data encryption and strong user authentication, with
fully open source and open hardware foundations.

Even though the WooKey focuses on the mass
storage USB class, all the provided security features
are easily portable to other USB device classes such as HID or CDC.

Beyond the mere USB oriented devices, the WooKey many defense in depth
primitives can be ported and used in **many IoT projects**.

The following sections describe the functional specifications, the
threat model as well as the security expectations.

WooKey threat model
-------------------

We consider that the adversary has logical and/or physical access to the device:

 * The adversary may try to read the data simply by connecting the
  device to a host or by physically reading the mass storage cells, for
  example when the device is lost or stolen. This can be done either
  when the device is powered up, or when it is powered down (which
  corresponds to an attack on the data at rest).
 * The adversary may try to tamper with the device using logical attacks,
  for example when it is connected to an untrusted host. These attacks
  abuse potential weaknesses in protocols used for external communication
  such as the USB stack or the external data storage buses.
 * The adversary may open the device to physically tamper with the
  internal storage, firmware, or any other component present on the
  actual device.
 * We suppose that an external authentication token is used to validate
  the legitimate user presence. We will only consider physical attacks
  where the adversary does not possess the legitimate user PIN code. In
  other words, side-channel and fault injection attacks on the device in
  a post-authentication phase are explicitly out of scope. Such kinds of
  attacks are considered during the pre-authentication phase though, either
  on the device, on the external token, or on the communication channel when
  these two exchange data.

Security features
-----------------

The WooKey provides the following main security features:

 * User data protection: all data at rest are encrypted, and their
  confidentiality protected. The data integrity is out of scope.
 * Strong user authentication: the legitimate user must be present when data
  is decrypted (implying a strong user authentication). When a user PIN code
  is used, attack vectors that can steal it must be limited.
 * Secure device software update: the device’s software is securely
  upgradable for system maintenance (e.g. security patches). Update files
  are authenticated and integrity is checked with no rollback to (possibly
  buggy) old versions. A software upgrade must be a voluntary and
  authenticated action. The firmware updates is reliable with no
  possible platform bricking.
 * Firmware robustness against software attacks: the firmware implements
  many security mechanisms and mitigation techniques to hinder
  an adversary attacking the exposed software surface (on the USB bus
  for instance) to be able to get a privileged access to the platform, and
  to gain access to the critical materials (such as sensitive cryptographic
  keys). The MPU (Memory Protection Unit) is used to confine
  software attacks in unprivileged and isolated containers.


Security vs. performance
------------------------

Integrating high security properties in both hardware and software design
impact the overall performance.

The software architecture, based on a microkernel with various security
features such as W^X protection, MPU-based partitioning and full userspace
drivers and stacks including secure DMA usage inherently generates performance
impact in comparison to basic bare metal implementations.

In the software design of WooKey, based on the EwoK microkernel, all drivers
are executed in userspace, including their associated Interrupts Service
Routines (ISR).

Any DMA request is controlled by the kernel as DMA controllers are never mapped
in userspace. This is the consequence of two constraints:

  * DMA controllers host multiple streams which associated registers are
   interlaced, making per-stream memory mapping impossible.
  * A direct access to DMA address registers is an open security hole, giving
   a task the ability to copy from or move to any part of the memory without
   any control from the kernel.

ISR are also executed in userspace as they are a part of user applications, and
may be corrupted through the corresponding application attack surface. As a
consequence, they can't be executed in handler mode but have to be executed as
a user dedicated thread, with the corresponding task permission and memory
mapping.


.. image:: img/roadmap.png
  :alt: WooKey release roadmap
  :align: center



