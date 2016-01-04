Aircraft Identification
=======================

An aircraft identification message has ``DF: 17``, and ``TC: 1 to 4``. 

For example:
::

  8D4840D6202CC371C32CE0576098


The structure of the message is:
::

  |    | ICAO24 |      DATA      |        |
  |----|--------|----------------|--------|
  | 8D | 4840D6 | 202CC371C32CE0 | 576098 |

  | DF    | CA  | ICAO24 ADDRESS           | TC    |     | Data                                             |
  |-------|-----|--------------------------|-------|-----|--------------------------------------------------|--------------------------|
  | 10001 | 101 | 010010000100000011010110 | 00100 | 000 | 001011001100001101110001110000110010110011100000 | 010101110110000010011000 |


Note that TC is inside of the DATA frame. DF and TC can be easily calculated:
::

  DF: 10001 -> 17
  TC: 00010 -> 4


Those two values confirm that the message is good for decoding aircraft identification.

Next, we are decoding the data frame containing the aircraft callsign (identification). In order to get the callsign, a look-up table is needed for mapping index numbers to letters:
::

  '#ABCDEFGHIJKLMNOPQRSTUVWXYZ#####_###############0123456789######'


In our message data frame, it is easy to decode following:
::

  HEX: 202CC371C32CE0
  BIN: 00100 000 | 001011 001100 001101 110001 110000 110010 110011 100000
  DEC:           |   11     12     13     49     48     50     51     32
  LTR:           |   K      L      M      1      0      2      3      _


So now we have the aircraft ID here: **KLM1023**


Following is the calculation implemented in Python:

.. code-block:: python

  def hex2bin(hexstr):
    length = len(hexstr)*4
    binstr = bin(int(hexstr, 16))[2:]
    while ((len(binstr)) < length):
      binstr = '0' + binstr
    return binstr

  def bin2int(binstr):
    return int(binstr, 2)

  charset = '#ABCDEFGHIJKLMNOPQRSTUVWXYZ#####_###############0123456789######'

  msg = "8D4840D6202CC371C32CE0576098"
  msgbin = hex2bin(msg)
  csbin = msgbin[40:96]

  csbin = databin[8:]  # get the callsign part

  callsign = ''
  callsign += charset[ bin2int(csbin[0:6]) ]
  callsign += charset[ bin2int(csbin[6:12]) ]
  callsign += charset[ bin2int(csbin[12:18]) ]
  callsign += charset[ bin2int(csbin[18:24]) ]
  callsign += charset[ bin2int(csbin[24:30]) ]
  callsign += charset[ bin2int(csbin[30:36]) ]
  callsign += charset[ bin2int(csbin[36:42]) ]
  callsign += charset[ bin2int(csbin[42:48]) ]

  # clean string, remove spaces and marks, if any.
  cs = cs.replace('_', '')
  cs = cs.replace('#', '')

  print callsign
