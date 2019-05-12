Using layout in drivers
=======================

Generated devinfo structure
---------------------------


All generated header files are based on a generic device description which is defined
in the *generated/devinfo.h* file. This file is included in the device generated header
file and then does not need to be explicitly included in the driver.

The devinfo file generate a dedicated device information structure, which includes:
   * the device address
   * the device size (in bytes)
   * the device GPIO table

The device information structure is defined as the following::

   struct user_driver_device_gpio_infos {
       uint8_t    port;
       uint8_t    pin;
   };

   struct user_driver_device_infos {
       physaddr_t address;    /**< Device MMIO base address */
       uint32_t   size;       /**< Device MMIO mapping size */
       /** GPIO informations of the device (pin, port) */
       struct user_driver_device_gpio_infos gpios[14];
   };

Using the generated data
------------------------

Each device GPIO table entry is named after the GPIO name in the JSON file.
This allows the device driver to use names instead of indices in the device definition
structure, avoiding any problem if GPIO order is modified in the JSON file.

To this structure, the device IRQ(s) are also defined using preprocessing, and can
be directly used in the device driver.

For the USART1 device declared as a JSON structure described previously, the header file generated
has the following structure::

   #ifndef USART1_H_
   # define USART1_H_

   #include "generated/devinfo.h"

   #define USART1_IRQ 53
   /* naming indexes in structure gpios[] table */
   #define USART1_TX 0
   #define USART1_RX 1
   #define USART1_SC_TX 2
   #define USART1_SC_CK 3

   static const struct user_driver_device_infos usart1_dev_infos = {
       .address = 0x40011000,
       .size    = 0x400,
       .gpios = {
         { GPIO_PB, 6 },
         { GPIO_PB, 7 },
         { GPIO_PA, 9 },
         { GPIO_PA, 8 },
         { 0, 0 },
         { 0, 0 },
         { 0, 0 },
         { 0, 0 },
         { 0, 0 },
         { 0, 0 },
         { 0, 0 },
         { 0, 0 },
         { 0, 0 },
         { 0, 0 },
       }
   };
   #endif

Each GPIO can be accessed, for example, using::

   uint8_t usart1_xmit_port = usart1_dev_infos.gpios[USART1_TX].port;
   uint8_t usart1_xmit_pin = usart1_dev_infos.gpios[USART1_TX].pin;

   uint8_t usart1_rcv_port = usart1_dev_infos.gpios[USART1_RX].port;
   uint8_t usart1_rcv_pin = usart1_dev_infos.gpios[USART1_RX].pin;

