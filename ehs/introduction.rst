Introduction
------------

Downlink Format and message structure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DF 20 and DF 21 are used for downlink messages.

The same as ADS-B, in all Mode-S messages, the first 5 bits contain the Downlink Format. The same identification process can be used to discover EHS messages. So the EHS messages starting bits are:

::

  DF20 - 10100
  DF21 - 10101


The message is structured as follows, where the digit represents the number of binary digits:

.. code-block:: text

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

Except for the DF, the first 32 bits do not contain useful information to decode the message. The exact definitions can be found in ICAO annex 10 (Aeronautical Telecommunications).


Parity and ICAO address recovery
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Unlike ADS-B, the ICAO address is not broadcast along with the EHS messages. We will have to "decode" the ICAO address before decoding other information, and ICAO is hidden in the message and checksum.

Mode-S uses two types of parity checksum Address Parity (AP) and Data Parity (DP). Majority of the time Address Parity is used.


Address Parity
**************

For AP, the message parity field is produced by XOR ICAO with message data CRC checksum. So, to recover the ICAO bits, simply reversing the XOR process will work, shown as follows:

.. code-block:: text

  +-------------------------------+  +--------------------+
  |   DATA FIELD (32 OR 88 BIT)   |  |    PARITY BITS     |
  +--------------+----------------+  +--------------------+
                 |
                 |                           XOR
                 v
  +--------------+-----------+       +--------------------+
  |          ENCODER         |  +--> | CHECKSUM (24 BITS) |
  +--------------------------+       +--------------------+
                                              ||
                                     +--------------------+
                                     |   ICAO (24 BITS)   |
                                     +--------------------+


An example:

.. code-block:: text

  Message:      A0001838CA380031440000F24177

  Data:         A0001838CA380031440000
  Parity:                             F24177

  Encode data:  CE2CA7

  ICAO:    [F24177] XOR [CE2CA7] => [3C6DD0]

For the implementation of the CRC encoder, refer to the pyModeS library ``pyModeS.util.crc(msg, encode=True)``

.. Data parity



BDS (Comm-B Data Selector)
~~~~~~~~~~~~~~~~~~~~~~~~~~

In simple words, BDS is a number (usually a 2-digit hexadecimal) that defines the type of message we are looking at. Both ADS-B messages and other types of Mods-S messages are all assigned their distinctive BDS number. However, it is **nowhere** to be found in the messages.

When SSR interrogates an aircraft, a BDS code is included in the request message (Uplink Format - UF 4, 5, 20, or 21). This BDS code is then used by the aircraft transponder to register the type of message to be sent. But when the downlink message is transmitted, its BDS code is not included in the message (because the SSR knows what kind of message it requested). Good news for them, but challenges for us.

Here are some BDS codes that we are interested in, where additional parameters about an aircraft can be found:

.. code-block:: text

  BDS 2,0   Aircraft identification
  BDS 2,1   Aircraft and airline registration markings
  BDS 4,0   Selected vertical intention
  BDS 4,4   Meteorological routine air report
  BDS 5,0   Track and turn report
  BDS 6,0   Heading and speed report
