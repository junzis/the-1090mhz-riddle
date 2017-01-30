Aircraft Identification
=======================

An aircraft identification message has ``DF: 17``, and ``TC: 1 to 4``. 

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

Additionally, a lookup table is needed convert the numbers to characters. It is defines as follows, Where the ``#`` is not used, and ``_`` represents a sepration.

::

  #ABCDEFGHIJKLMNOPQRSTUVWXYZ#####_###############0123456789######



In previous example message, it is easy to decode the ``Data`` segment:
::

  HEX: 20          2CC371C32CE0
  BIN: 00100 000 | 001011 001100 001101 110001 110000 110010 110011 100000
  DEC:           |   11     12     13     49     48     50     51     32
  LTR:           |   K      L      M      1      0      2      3      _


So the final aircraft callsign decoded is: **KLM1023_**

For detailed codes in python, refer to the pyModeS library function: ``pyModeS.adsb.callsign()``