Aircraft Identification
=======================

An aircraft identification message has ``DF: 17``, and ``TC: 1 to 4``, the 56-bit ``DATA`` field is configured as follows:

::

  +---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+
  |  TC (5) |  EC (3) |  C1 (6) |  C2 (6) |  C3 (6) |  C4 (6) |  C5 (6) |  C6 (6) |  C7 (6) |  C8 (6) |
  +---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+

  TC: Type code
  EC: Emitter category
  C*: Charactor


For decode charactors, a lookup table is needed for mapping numbers to characters. It is defines as follows, where the ``#`` is not used, and ``_`` represents a sepration.

::

  #ABCDEFGHIJKLMNOPQRSTUVWXYZ#####_###############0123456789######

In summary, characters and there decimal reprsentations are:
::

  A - Z :   1 - 26 
  0 - 9 :  48 - 57
      _ :  32


The ``EC`` value in combination with ``TC`` value defines the category of the aircraft (such as: heavy, large, small, light, glider, etc.). When ``EC`` is set to zeros, such information is not avaiable.


Example
-------

For example:
::

  8D4840D6202CC371C32CE0576098


The structure of the message is:
::

  
       DF--- CA-  ICAO--  DATA------------------  PI---- 
  HEX: 8   D      4840D6  2   0     2CC371C32CE0  576098
  BIN: 10001|101  ******  00100|000 ************  ******
  DEC: 17   |4            4     0
                          TC    *  

Note that ``Type Code`` is inside of the DATA frame (first 5 bits). With ``DF=17`` and ``TC=4``, we can confirm this is a aircraft identification message. Aircraft ``callsign`` then can be decoded.


In previous example message, it is easy to decode the ``Data`` segment:
::

  HEX: 20         2CC371C32CE0
  BIN: 00100000 | 001011 001100 001101 110001 110000 110010 110011 100000
  DEC:          |   11     12     13     49     48     50     51     32
  LTR:          |   K      L      M      1      0      2      3      _


So the final aircraft callsign decoded is: **KLM1023_**

For detailed codes in python, refer to the pyModeS library function: ``pyModeS.adsb.callsign()``