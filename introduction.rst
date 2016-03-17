Introduction
============

.. Hardware
.. --------
.. TODO: add an introduction of the hardware used for the project here


ADS-B
-----

ADS-B is short for Automatic Dependent Surveillance–Broadcast. it is a satellite based survillance system. Aircraft position, velocity, together with identification are transmitted through Mode-S Extended Squitter (1090 MHz).

Majority of the aircraft nowadays are broadcasting ADS-B messages constantly. There are many ways you can set up you own receiver and antenna to start tapping into those signals (DVB-T usb stick, ModeSBeast, Raspberry Pi, RadarScape, etc). 

An ADS-B message is 112 bits long, following is an example:
::

  BIN format:
  10001101010010000100000011010110001000000010110011000011
  01110001110000110010110011100000010101110110000010011000

  HEX format:
  8D4840D6202CC371C32CE0576098
  

This table lists the key bits of a message:

+----------+----------+----------+------------------------+
| Bit from | Bit to   | Abbr.    | Name                   |
+==========+==========+==========+========================+
| 1        | 5        | DF       | Downlink Format        |
+----------+----------+----------+------------------------+
| 6        | 8        | CA       | Message Subtype        |
+----------+----------+----------+------------------------+
| 9        | 32       | ICAO24   | ICAO aircraft address  |
+----------+----------+----------+------------------------+
| 33       | 88       | DATA     | Data frame             |
+----------+----------+----------+------------------------+
| 89       | 112      | PC       | Parity check           |
+----------+----------+----------+------------------------+


The type of the message can be identified by checking its Downlink Format (DF), bit 1 to 5. For ADS-B message, we need: DF = 17 (in decimal), or 10001 (in binary),

Within the data frame, another import value is the Type Code. it tells what is inside of the data frame, it is located from bit 33 to 37 (5 bits)

+----------+----------+----------+------------------------+
| Bit from | Bit to   | Abbr.    | Name                   |
+==========+==========+==========+========================+
| 33       | 37       | TC       | Type Code              |
+----------+----------+----------+------------------------+


ADS-B message types
-------------------

By looking at the DF and TC we can quickly understand what kind of information is contained in the data frame. The relations are listed as following:

+-----+----------+---------------------------------+
| DF  | TC       | Content                         |
+=====+==========+=================================+
| 17  | 1 to 4   | Aircraft identification         |
+-----+----------+---------------------------------+
| 17  | 5 to  8  | Surface position                |
+-----+----------+---------------------------------+
| 17  | 9 to 18  | Airborne position (Baro Alt)    |
+-----+----------+---------------------------------+
| 17  | 19       | Airborne velocities             |
+-----+----------+---------------------------------+
| 17  | 20 to 22 | Airborne position (GNSS Height) |
+-----+----------+---------------------------------+
| 17  | 23       | Test message                    |
+-----+----------+---------------------------------+
| 17  | 24       | Surface system status           |
+-----+----------+---------------------------------+
| 17  | 25 to 27 | Reserved                        |
+-----+----------+---------------------------------+
| 17  | 28       | Extended squitter AC status     |
+-----+----------+---------------------------------+
| 17  | 29       | Target state and status (V.2)   |
+-----+----------+---------------------------------+
| 17  | 30       | Reserved                        |
+-----+----------+---------------------------------+
| 17  | 31       | Aircraft Operation status       |
+-----+----------+---------------------------------+

Note that within different type of the messages, the configurations of the bits in data frame are different. In next chapter, those will be explained in detail.


ADS-B Checksum
--------------

ADS-B uses cyclic redundancy check to validate the correctness of received message. The parity check bits are the last 6 bytes (bit 89 to 112)

