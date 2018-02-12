Aircraft identification (BDS 2,0)
---------------------------------

Similar to an ADS-B aircraft identification message, the callsign of an aircraft can be decoded in the same way. For the 56-bit MB (message, Comm-B) field, information decodes as follows:

.. code-block:: text

  +--------------+---------+---------+---------+---------+---------+---------+---------+---------+
  |  BDS2,0  (8) |  C1 (6) |  C2 (6) |  C3 (6) |  C4 (6) |  C5 (6) |  C6 (6) |  C7 (6) |  C8 (6) |
  +--------------+---------+---------+---------+---------+---------+---------+---------+---------+
    0010 0000      6 bits

Here, 8 bits are 0010 0000 (2,0 in hexadecimal) and the rest of chars are 6 bits each. To decode the chars, the same char map as ADS-B is used:

.. code-block:: text

  '#ABCDEFGHIJKLMNOPQRSTUVWXYZ#####_###############0123456789######'


Example:

.. code-block:: text

  MSG:  A000083E202CC371C31DE0AA1CCF
  DATA:         202CC371C31DE0

  BIN:  0010 0000 001011 001100 001101 110001 110000 110001 110111 100000
  HEX:     2    0
  DEC:             11     12     13     49     48     49     55     32
  CHR:             K      L      M      1      0      1      7      _

  ID:   KLM1017
