Decoding
========

In this section we will explain how to read the bits in a ADS-B message, decode them, and calculations.


Aircraft Identification
-----------------------

Aircraft Identification message starts with DF=17, TC= 1 to 4. For example We got a message:
::

  8D4840D6202CC371C32CE0576098


So the structure looks like:
::

  8D4840D6 | 202CC371C32CE0 | 576098
           | DATA           |

  | 10001 | 101 | 010010000100000011010110 | 00100 | 000 | 001011001100001101110001110000110010110011100000 | 010101110110000010011000
  | DF    | CA  | ICAO24                   | TC    |     | Data                                             |


Note that TC is inside of the DATA frame. We have DF and TC here:
::

  DF: 10001 -> 17
  TC: 00010 -> 4


These two value confirm that we are look at the right message for decoding aircraft identification.

Next, we will decode the date which contains the aircraft call sign in the message. Decoded numbers represent the index of the character in the lookup table blew.
::

  [?ABCDEFGHIJKLMNOPQRSTUVWXYZ????? ???????????????0123456789??????]


For example:
::

  HEX: 202CC371C32CE0
  BIN: 00100 000 | 001011 001100 001101 110001 110000 110010 110011 100000
  DEC:           |   11     12     13     49     48     50     51     32
  LETTER:        |   K      L      M      1      0      2      3      _

  Note: "_" represent the space above


So we have the aircraft ID (callsign) here: **KLM1023**

Python code example
*******************

.. code-block:: python

  def hex2bin(hexstr):
      length = len(hexstr)*4
      binstr = bin(int(hexstr, 16))[2:]
      while ((len(binstr)) < length):
        binstr = '0' + binstr
      return binstr

  def bin2int(binstr):
      return int(binstr, 2)

  data = "202CC371C32CE0"
  ais_charset = '?ABCDEFGHIJKLMNOPQRSTUVWXYZ????? ???????????????0123456789??????'
  databin = hex2bin(data)

  csbin = databin[8:]  # get the callsign part

  callsign = ''
  callsign = ais_charset[ bin2int(csbin[0:6]) ]
  callsign += ais_charset[ bin2int(csbin[6:12]) ]
  callsign += ais_charset[ bin2int(csbin[12:18]) ]
  callsign += ais_charset[ bin2int(csbin[18:24]) ]
  callsign += ais_charset[ bin2int(csbin[24:30]) ]
  callsign += ais_charset[ bin2int(csbin[30:36]) ]
  callsign += ais_charset[ bin2int(csbin[36:42]) ]
  callsign += ais_charset[ bin2int(csbin[42:48]) ]

  print callsign



Aircraft Positions
------------------

Decoding the positions of the aircraft is a bit more complicated. We would assume the latitude and longitude embedded directly in the message data. But NO... In fact, we need two different type of the position messages to find out the LAT and LON of the aircraft. The position is described in so called Compact Position Reporting (CPR) format, which is hard to understand, and not well documented on the internet.

The advantage of CPR, it is use less bits to encode the position information. The dis-advantage is obviously its complexity in calculation. We are going to explain here in detail how to convert two CPR frame (odd and even) into Latitude and Longitude.


Determine an odd and even frame
*******************************

We have following two data frames:
::

  8D40621D58C382D690C8AC2863A7
  8D40621D58C386435CC412692AD6

           | DATA           |
  8D40621D | 58C382D690C8AC | 2863A7
  8D40621D | 58C386435CC412 | 692AD6



Convert to binary strings:
::

  | DF    | CA  | ICAO24 ADDRESS           | TC    |     | Alititude    | T | F | CPR Latitude      | CPR Longitude     |
  | 10001 | 101 | 010000000110001000011101 | 01011 | 000 | 110000111000 | 0 | 0 | 10110101101001000 | 01100100010101100 | 001010000110001110100111
  | 10001 | 101 | 010000000110001000011101 | 01011 | 000 | 110000111000 | 0 | 1 | 10010000110101110 | 01100010000010010 | 011010010010101011010110



So, look into the data, we can see in both data frame:
::

  ICAO24: 40621D
  DF: 17
  TC: 11


Those means the two data frame are valid type of messages for decoding the positions. the same ICAO24 address means they are originated from the same aircraft.


Now let's look at Bit-54 (title F). We are able to determine whether the frame is odd or even:
::

  0 -> Even frame
  1 -> Odd frame


By the way, the Bit-53 (title T), shows whether it is synchronized with the UTC time, in our case, "0" means they are not.

Calculate the LAT/LON from CPR positions
****************************************

Reference: `A more mathmatically explained document on CPR positions
<http://www.eurocontrol.int/eec/gallery/content/public/document/eec/report/1995/002_Aircraft_Position_Report_using_DGPS_Mode-S.pdf>`_

Now we have CPR latitude and longitude of both CPR messages:
::

  | F | CPR Latitude      | CPR Longitude     |
  | 0 | 10110101101001000 | 01100100010101100 |
  | 1 | 10010000110101110 | 01100010000010010 |


**Step1: First we convert the binary string to decimal**
::

  cprLat0 = 93000
  cprLon0 = 51372
  cprLat0 = 74158
  cprLon0 = 50194


**Step2: Calculation the Latitude Index j, using following equation**

.. math::

  j = int\left ( \frac{(59 * cprLat0 - 60 * cprLat0}{131072} + 0.5  \right )


We have:
::

  j = 8

**step3: Calculate relative latitude**

First we need to know two constants
::

  airDLat0 = 360.0 / 60
  airDLat1 = 360.0 / 59

Then we can use the following equation to calculate the relative latitude:

.. math::

  rLat0 = airDLat0 * mod(j, 60) + \frac{crpLat0}{131072}

.. math::

 rLat0 =
  \begin{cases}
   rLat0 -360 & \text{if } (rLat0 \geq 270) \\
   rLat0       & \text{else}
  \end{cases}

.. math::

  rLat1 = airDLat1 * mod(j, 59) + \frac{crpLat1}{131072}

.. math::

 rLat1 =
  \begin{cases}
   rLat1 -360 & \text{if } (rLat1 \geq 270) \\
   rLat1       & \text{else}
  \end{cases}

If the relative latitude results are greater than 270, it means we are at southern hemisphere. We will need to subtract 360

Here we have:
::

  rLat0 = 52.2572021484
  rLat1 = 52.2657801741


**Step 4: Check relative latitudes, and get aircraft true latitude**

After previous calculation, we need to check if `rLat0` and `rLat1` are in the same `latitude zone`, if not we will simply make an exit here and not calculate further, and wait for new data frames come in.

There are 60 latitude zone pre-computed. You may refer to the python source code to see how degrees of latitudes divided into zones.

In our case, both value are in latitude zone `36`. And we are taking the `rLat1` as the current latitude (usually odd frame are most recent, however the deviation is very small anyway). So we have the latitude of the aircraft now:
::

  lat = 52.2657801741


**Step 5:**
