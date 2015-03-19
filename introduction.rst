Introduction
============

.. Hardware
.. --------
.. TODO: add an introduction of the hardware used for the project here


Mode S
------

Mode S is the signal carrying the ADS-B data from aircrafts. Modulation and demodulation of Mode S signal is out of scope of this guide. From our antenna and  A/D converter, we are able to receive the encoded messages to a Linux agent. Our focuses are from this point on; working with those data.

If you are interested on digging deeper on the Mode S signal, a good starting point is to have a look at this Wikipedia page, and follow the references:

https://en.wikipedia.org/wiki/Secondary_surveillance_radar#Mode_S


ADS-B
-----

An ADS-B message is 120 bits long, following is an example:
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
| 17  | 9 to 18  | Aircraft position               |
+-----+----------+---------------------------------+
| 17  | 19       | Aircraft velocities             |
+-----+----------+---------------------------------+

Note that within different type of the messages, the configurations of the bits in data frame are different. In next chapter, those will be explained in detail.

