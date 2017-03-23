Introduction
============

.. Hardware
.. --------
.. TODO: add an introduction of the hardware used for the project here


ADS-B
-----

ADS-B is short for Automatic Dependent Surveillance–Broadcast. it is a satellite based survillance system. Aircraft position, velocity, together with identification are transmitted through Mode-S Extended Squitter (1090 MHz).

Majority of the aircraft nowadays are broadcasting ADS-B messages constantly. There are many ways you can set up you own receiver and antenna to start tapping into those signals (DVB-T usb stick, ModeSBeast, Raspberry Pi, RadarScape, etc). 


An ADS-B message is 112 bits long, and consist of 5 parts:

::

  +--------+--------+-----------+--------------------------+---------+
  |  DF 5  |  ** 3  |  ICAO 24  |          DATA 56         |  PI 24  |
  +-----------------+-----------+--------------------------+---------+


This table lists the key bits of a message:

+----------+------------+----------+----------------------------------------+
| nBits    | Bits       | Abbr.    | Name                                   |
+==========+============+==========+========================================+
| 5        | 1 - 5      | DF       | Downlink Format (17)                   |
+----------+------------+----------+----------------------------------------+
| 3        | 6 - 8      | CA       | Capability (additional identifier)     |
+----------+------------+----------+----------------------------------------+
| 24       | 9- 32      | ICAO     | ICAO aircraft address                  |
+----------+------------+----------+----------------------------------------+
| 56       | 33 - 88    | DATA     | Data                                   |
+          +------------+----------+----------------------------------------+
|          | [33 - 37]  | [TC]     | Type code                              |
+----------+------------+----------+----------------------------------------+
| 24       | 89 - 112   | PI       | Parity/Interrogator ID                 |
+----------+------------+----------+----------------------------------------+


Example:
::

  Raw message in hexadecimal:
  8D4840D6202CC371C32CE0576098  


  -----+------------+--------------+-------------------------------+--------------
  HEX  | 8D         | 4840D6       | 202CC371C32CE0                | 576098
  -----+------------+--------------+-------------------------------+--------------
  BIN  | 10001  101 | 010010000100 | [00100]0000010110011000011011 | 010101110110
       |            | 000011010110 | 10001110000110010110011100000 | 000010011000
  -----+------------+--------------+-------------------------------+--------------
  DEC  |  17    5   |              | [4] .......................   |
  -----+------------+--------------+-------------------------------+--------------
          DF    CA     ICAO          [TC] ------ DATA ----------    PI
    

Any ADS-B must start with the Downlink Format 17 (10001 in binary code) for the first 5 bits. Bits 6-8 are used as additional identifier, which has different meanings within different types of ADS-B message.



ADS-B message types
-------------------

To identify what information is contained in a ADS-B message. We need to take a look at the ``Type Code`` of the message, indicated at bits 33 - 37 of the ADS-B message (or first 5 bits of the ``DATA`` segment)


Following are the relationship between each ``Type Code`` and its information contained in the ``DATA`` segment:

+----------+-----------------------------------------+
| TC       | Content                                 |
+==========+=========================================+
| 1 - 4    | Aircraft identification                 |
+----------+-----------------------------------------+
| 5 - 8    | Surface position                        |
+----------+-----------------------------------------+
| 9 - 18   | Airborne position (w/ Baro Altitude)    |
+----------+-----------------------------------------+
| 19       | Airborne velocities                     |
+----------+-----------------------------------------+
| 20 - 22  | Airborne position (w/ GNSS Height)      |
+----------+-----------------------------------------+
| 23 - 31  | Reserved for other uses                 |
+----------+-----------------------------------------+



ADS-B Checksum
--------------

ADS-B uses cyclic redundancy check to validate the correctness of received message, where the last 24 bits are the parity bits. Following pseudo-code describes the CRC process:

::
  
  GENERATOR = 1111111111111010000001001

  MSG = binary(8D4840D6202CC371C32CE0576098)    # 112 bits

  for i from 0 to 88:                           # 112 bits - 24 parity bits
    if MSG[i] is 1:
      MSG[i:i+24] = MSG[i:i+24] ^ GENERATOR

  CRC = MSG[-24:]                               # last 24 bits of result

  IF CRC not 0:
    MSG is corrupted


For the implementation of CRC encoder in python, refer to the pyModeS library function: ``pyModeS.util.crc()``


A comprehensive documentation on Mode-S parity coding can be found:

::

  Gertz, Jeffrey L. Fundamentals of mode s parity coding. No. ATC-117. 
  MASSACHUSETTS INST OF TECH LEXINGTON LINCOLN LAB, 1984. APA 
