About the hardware layout
=========================

.. _layout:

Managing the portability
------------------------

There are multiple issues when dealing with portability management. The initial one is the architecture (ASP) support.
Architecture-specific content, in the kernel, should be hosted in the arch/<arch_type> directory. The other
parts of the kernel should be portable enough to support various architectures without requesting complex modifications
or implementation design.

This is, for this part of the portability, mostly a kernel-specific constraint.

Handing multiple SoCs and boards
--------------------------------

The other part of the portability problem is the way to handle multiple SoCs, for which potential IPs (Intellectual
Property) may exist in different (but not all) SoCs. This means that the driver associated to the IP should be portable
enough to support the IP instantiation in various SoCs.

In the same way, a given SoC may be configured in various ways in term of board I/O (e.g. what GPIO is connected where).
This is a board specification and should not affect the driver implementation as the IP programming interface is not modified.

Handling heterogeneous boards
"""""""""""""""""""""""""""""

In order to support various boards, the WooKey project has designed a specific file in JSON format, declaring a dictionary
of SoC devices (named 'block') and board peripherals (named 'peripheral'). Peripherals can be acceded only through one of the
SoC block (SPI bus device, CAN bus, USART or any SoC component able to generate I/O with the external world).

The JSON file as the following syntax: ::

   {
      "usart1": {
         "type":"block",
         "address":"0x40011000",
         "size":"0x400",
         "memory_subregion_mask":"0",
         "irqs": [
           { "name":"USART1_IRQ", "value":"53" }
         ],
         "gpios": [
           { "name":"USART1_TX", "port":"GPIO_PB", "pin":"6" },
           { "name":"USART1_RX", "port":"GPIO_PB", "pin":"7" },
           { "name":"USART1_SC_TX", "port":"GPIO_PA", "pin":"9" },
           { "name":"USART1_SC_CK", "port":"GPIO_PA", "pin":"8" }
         ],
         "read_only": "false",
         "permission": "PERM_RES_DEV_BUSES",
         "enable_register":"r_CORTEX_M_RCC_APB2ENR",
         "enable_register_bits": ["RCC_APB2ENR_USART1EN"]
      },
   }

The above example is the definition of a SoC USART1 device. This dictionary entry
hosts all the required information to generate:

   * a kernel header named devmap.h, hosting allowed devices list
   * userspace headers, hosting information that generic drivers need (IRQ number, GPIO references, device mapping address and size)

Device maps are generated at pre-build time, from a single source JSON file, as shown below:

.. image:: img/layout.png
   :scale: 100 %
   :alt: ewok icon
   :align: center

In order to support multiple boards, we manage multiple JSON files, holding various devices information. JSON files are named with the
current board configured in the configuration system of the Tataouine SDK.



