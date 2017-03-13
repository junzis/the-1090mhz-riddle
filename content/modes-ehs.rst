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

.. Example:
    40: A0001838CA380031440000F24177
    50: A00015B7801DBB3BE00CF7B8856D
    60: A0000294B409D117224C47609A81


Downlink Format and message structure
-------------------------------------
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
--------------------------------

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
--------------------------

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


BDS 2,0 (Aircraft identification)
---------------------------------
Similar to ADS-B aircraft identification message, the callsign of aircraft can be decode in the same way. For the 56-bit MB (message, Comm-B) field, information decodes as follows:

::

  +--------------+---------+---------+---------+---------+---------+---------+---------+---------+
  |  BDS2,0  (8) |  C1 (6) |  C2 (6) |  C3 (6) |  C4 (6) |  C5 (6) |  C6 (6) |  C7 (6) |  C8 (6) |
  +--------------+---------+---------+---------+---------+---------+---------+---------+---------+
    0010 0000      6 bits

Here, 8 bits are 0010 0000 (2,0 in hexadecimal) and the rest of chars are 6 bits each. To decode the chars, the same char map as ADS-B is used:

::

  '#ABCDEFGHIJKLMNOPQRSTUVWXYZ#####_###############0123456789######'


Example:

::

  MSG:  A000083E202CC371C31DE0AA1CCF
  DATA:         202CC371C31DE0

  BIN:  0010 0000 001011 001100 001101 110001 110000 110001 110111 100000
  HEX:     2    0
  DEC:             11     12     13     49     48     49     55     32
  CHR:             K      L      M      1      0      1      7      _

  ID:   KLM1017


BDS 4,0 (Selected aircraft intention)
-------------------------------------

In BDS 4,0, information such as aircraft select altitude and barometric pressure settings are given. The 56-bit MB filed is structure as following:


::

   FIELD                                   START  N-BITS
                                           (END)
  +---------------------------------------+------+------+
  | Status                                |  1   |  1   |
  +---------------------------------------+------+------+
  | MCP/FCU selected altitude             |  2   |  12  |   **
  |                                       |      |      |
  | range = [0, 65520] ft                 |      |      |
  |                                       |      |      |
  | LSB: 16 ft                            |  13  |      |
  +---------------------------------------+------+------+
  | Status                                |  14  |  1   |
  +---------------------------------------+------+------+
  | FMS selected altitude                 |  15  |  12  |   **
  |                                       |      |      |
  | range = [0, 65520] ft                 |      |      |
  |                                       |      |      |
  | LSB: 16 ft                            |  26  |      |
  +---------------------------------------+------+------+
  | Status                                |  27  |  1   |
  +---------------------------------------+------+------+
  | Barometric pressure setting           |  28  |  12  |   **
  |   -> Note: actual value minus 800     |      |      |
  |                                       |      |      |
  | range = [0, 410] mb                   |      |      |
  |                                       |      |      |
  | LSB: 0.1 mb                           |  39  |      |
  +---------------------------------------+------+------+
  | Reserved                              |  40  |  8   |
  |   -> set to ZEROS                     |      |      |
  |                                       |  47  |      |
  +---------------------------------------+------+------+
  | Status                                |  48  |  1   |
  |   -> next 3 fields                    |      |      |
  +---------------------------------------+------+------+
  | Mode: VNAV                            |  49  |  1   |
  +---------------------------------------+------+------+
  | Mode: Alt hold                        |  50  |  1   |
  +---------------------------------------+------+------+
  | Mode: Approach                        |  51  |  1   |
  +---------------------------------------+------+------+
  | Reserved                              |  52  |  2   |
  |   -> set to ZEROS                     |  53  |      |
  +---------------------------------------+------+------+
  | Status                                |  54  |  1   |
  +---------------------------------------+------+------+
  | Target alt source                     |  55  |  2   |
  |   -> 00: Unknown                      |      |      |
  |   -> 01: Aircraft altitude            |      |      |
  |   -> 10: FCU/MCP selected altitude    |      |      |
  |   -> 11: FMS selected altitude        |  56  |      |
  +---------------------------------------+------+------+


An example:

::

  MSG:  A000029C85E42F313000007047D3
  MB:           85E42F31300000

  ---------------------------------------------------------------------------------
  MB BIN:   1 000010111100 1 000010111100 1 100010011000 00000000 0 0 0 0 00 0 00
  ---------------------------------------------------------------------------------
  STATUS:   1
  MCP:        188 (x16)
  ---------------------------------------------------------------------------------
  STATUS:                  1
  FMS:                       188 (x16)
  ---------------------------------------------------------------------------------
  STATUS:                                 1
  BARO:                                     2200 (x0.1 + 800)
  ---------------------------------------------------------------------------------
  FINAL:      3008 ft        3008 ft        1020 mb
  ---------------------------------------------------------------------------------


BDS 4,4 (Meteorological routine air report)
-------------------------------------------
