.. Wookey documentation master file, created by
   sphinx-quickstart on Thu Mar 22 10:31:37 2018.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to the WooKey project documentation!
============================================

Securing the USB stack, and hence the USB hosts and devices, has been a growing
subject of research since exploitable flaws have been revealed with the BadUSB
threat [nohl2014badusb]_.

The Wookey is a custom STM32 based USB thumb drive with mass storage capabilities
designed for user data encryption and protection, with a full-fledged set of in-depth security defenses:

- A secure DFU (Device Firmware Update) ensuring firmware integrity and
  authenticity
- Up-to-date cryptography
- An external and extractable authentication token embedding a secure element
- **EwoK**, a secure microkernel implemented in
  Ada/SPARK
- Memory confinement using the MPU (Memory Protection Unit), privilege
  separation, W^X principle, stack and heap anti-smashing
- **Tataouine**, a versatile SDK developed to easily integrate user
  applications in C and Rust.
- Open source and open hardware

Informations about the security concerns are details in some publications_.

.. _publications: publi.rst

.. toctree::
   :caption: Table of Contents
   :name: mastertoc
   :maxdepth: 2

   Quickstart <quickstart>
   Wookey architecture <architecture>
   EwoK kernel <ewok/index>
   Libraries <libs>
   Drivers <drivers>
   Tataouine SDK <tataouine>
   Basic applications <basicapps>

   About the WooKey project <target>
   Publications <publi>


.. Indices and tables
   ==================

.. * :ref:`genindex`
   * :ref:`modindex`
   * :ref:`search`

.. rubric:: References

.. [nohl2014badusb] BadUSB-On accessories that turn evil, Karsten Nohl and Jakob Lell, Black Hat USA, 2014

