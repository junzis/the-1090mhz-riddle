Mode S Enhanced Surveillance (EHS)
==================================

Let's hack into the EHS messaged too! more information on aircraft air speeds.

[under editing]

For a complete Python implementation:
https://github.com/junzis/pyModeS/blob/master/pyModeS/ehs.py


The Mode-S Enhanced Surveillance (EHS) provides air traffic controller more information that what is included in the ADS-B (a.k.a Mode-S Elementary Surveillance). It responds to ATC Secondary Surveillance Radar, and broadcast specific parameters non-independently. Hence it is only available in the area where ATC presents.

There are quite a few very interesting data contained within various types of the EHS messages. Such as: airspeeds (IAS, TAS, Mach), roll angles, track angles, track angle rates, selected altitude, magnetic heading, vertical rate, etc..

There are a few challenges to decode those information:
 - Which aircraft does one message come from?
 - What is the type of one message (a.k.a. which BDS code) most likely to be?
 - How confident is the information that has been decoded?


40: A0001838CA380031440000F24177
50: A00015B7801DBB3BE00CF7B8856D
60: A0000294B409D117224C47609A81

Downlink Format
---------------
DF 20 and DF 21 are used for downlink messages.

The same as ADS-B, in all Mode-S messages, the first 5 bit contains the Downlink Format. The same identification process can be used for discover EHS messages. So the EHS messages starting bits are:

::

  DF20 - 10100
  DF21 - 10101


ICAO address recovery
---------------------

Unlike ADS-B, the ICAO address is not broadcast along with the EHS messages. One would have to "decode" the ICAO address before decoding the message.

ICAO is hidden in the message and checksum. For DF 4, 5, 20, 21, message parity field is produced by XOR ICAO bits with the checksum of data bits from CRC, as following. So to recover the ICAO bits, simply reverse XOR process as following:

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


Take an example message:
::

  Message:  A0001838CA380031440000F24177

  Data:     A0001838CA380031440000
  Encode:   CE2CA7

  Parity:   F24177

  ICAO:    [F24177] XOR [CE2CA7] => [3C6DD0]

For the implementation of CRC encoder, refer to the pyModeS libaray ``pyModeS.util.crc(msg, encode=True)``


BDS (Comm-B Data Selector)
--------------------------

BDS
