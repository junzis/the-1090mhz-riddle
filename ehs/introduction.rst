Introduction
------------

Downlink Format and message structure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DF 20 and DF 21 are used for downlink messages.

The same as ADS-B, in all Mode-S messages, the first 5 bit contains the Downlink Format. The same identification process can be used for discover EHS messages. So the EHS messages starting bits are:

::

  DF20 - 10100
  DF21 - 10101


The message is structured as following, where the digit represents the number of binary digits:

::

  +--------+--------+--------+--------+-------------+------------------+------------+
  |  DF 5  |  FS 3  |  DR 5  |  UM 6  |    AC 13    |       MB 56      |  AP/DP 24  |
  +-----------------+--------+-----------------------------------------+------------+
  |    <---------+      32 bits      +-------->     |


  DF:     downlink format
  FS:     flight status
  DR:     downlink request
  UM:     utility message
  ID:     identity
  MB:     message, Comm-B
  AP/DP:  address/parity or data/parity

Except the DF, the first 32 bits does not contain useful information for decode the message. The exact definitions can be found in ICAO annex 10 (Aeronautical Telecommunications).


Parity and ICAO address recovery
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Unlike ADS-B, the ICAO address is not broadcast along with the EHS messages. We will have to "decode" the ICAO address before decoding other information, and ICAO is hidden in the message and checksum.

Mode-S uses two types of parity checksum Address Parity (AP) and Data Parity (DP). Majority of the time Address Parity is used.


Address Parity
**************

For AP, message parity field is produced by XOR ICAO with message data CRC checksum. So, to recover the ICAO bits, simply reverse XOR process will work, shown as follows:

::

  +-------------------------------+  +------------------+
  |   DATA FIELD (32 OR 88 BIT)   |  |   PARITY BITS    |
  +--------------+----------------+  +------------------+
                 |
                 |                           XOR
                 v
  +--------------+-----------+       +------------------+
  |          ENCODER         |  +--> | CHECKSUM (24BIT) |
  +--------------------------+       +------------------+
                                              ||
                                     +------------------+
                                     |   ICAO (24BIT)   |
                                     +------------------+


An example:
::

  Message:      A0001838CA380031440000F24177

  Data:         A0001838CA380031440000
  Parity:                             F24177

  Encode data:  CE2CA7

  ICAO:    [F24177] XOR [CE2CA7] => [3C6DD0]

For the implementation of CRC encoder, refer to the pyModeS library ``pyModeS.util.crc(msg, encode=True)``

.. Data parity



BDS (Comm-B Data Selector)
~~~~~~~~~~~~~~~~~~~~~~~~~~

In simply words, BDS is a number (usually a 2-digit hexadecimal) that defines the type of message we are looking at. Both ADS-B messages and other types of Mods-S messages are all assigned their distinctive BDS number. However, it is **no where** to be found in the messages.

When SSR interrogates aircraft, a BDS code is included in request message ( Uplink Format - UF 4, 5, 20, or 21). This BDS code are then used by the aircraft transponder to register the type of message to be sent. But when the downlink message is transmitted, its BDS code is not included in the message (because the SSR knows what kind message it requested). Good new for them, but challenges for us.

Here are some BDS codes that we are interested, where additional parameters about aircraft can be found:
::

  BDS 2,0   Aircraft identification
  BDS 2,1   Aircraft and airline registration markings
  BDS 4,0   Selected vertical intention
  BDS 4,4   Meteorological routine air report
  BDS 5,0   Track and turn report
  BDS 6,0   Heading and speed report
