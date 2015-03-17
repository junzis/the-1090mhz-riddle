Decoding
========

In this section we will explain how to read bits in different types of ADS-B messages, decode and calculate information, such as aircraft ID, position, speed, and heading.


Aircraft Identification
-----------------------

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

  [?ABCDEFGHIJKLMNOPQRSTUVWXYZ????? ???????????????0123456789??????]


In our message data frame, it is easy to decode following:
::

  HEX: 202CC371C32CE0
  BIN: 00100 000 | 001011 001100 001101 110001 110000 110010 110011 100000
  DEC:           |   11     12     13     49     48     50     51     32
  LTR:           |   K      L      M      1      0      2      3      _

  Note: "_" represent the space above


So now we have the aircraft ID here: **KLM1023**


Following is the calculation implemented in python code.

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

Decoding the positions of the aircraft is a bit more complicated. Naturally, we would assume to read latitude and longitude directly from the data frame. Unfortunately its not that simple...

In fact, two different types of the position messages (odd and even frames) are needed to find out the LAT and LON of the aircraft. The position is described in so called Compact Position Reporting (CPR) format, which is hard to understand, and not well documented.

The advantage of CPR is that it uses less bits to encode the position information. The dis-advantage is obviously the complexity of calculation.


An aircraft position message has ``DF: 17``, and ``TC: from 9 to 18``. 


Determine an odd and even frame
*******************************

For example, two following messages are received:
::

  8D40621D58C382D690C8AC2863A7
  8D40621D58C386435CC412692AD6

  |    | ICAO24 |      DATA      |        |
  |----|--------|----------------|--------|
  | 8D | 40621D | 58C382D690C8AC | 2863A7 |
  | 8D | 40621D | 58C386435CC412 | 692AD6 |



Convert both messages to binary strings:
::

  | DF    | CA  | ICAO24 ADDRESS           | TC    |     | Altitude     | T | F | CPR Latitude      | CPR Longitude     |                          |
  |-------|-----|--------------------------|-------|-----|--------------|---|---|-------------------|-------------------|--------------------------|
  | 10001 | 101 | 010000000110001000011101 | 01011 | 000 | 110000111000 | 0 | 0 | 10110101101001000 | 01100100010101100 | 001010000110001110100111 |
  | 10001 | 101 | 010000000110001000011101 | 01011 | 000 | 110000111000 | 0 | 1 | 10010000110101110 | 01100010000010010 | 011010010010101011010110 |



In both message we can find: ``DF=17`` and ``TC=11``, with the same ICAO24 address ``40621D``. So those two frames are valid for decoding the positions of this aircraft.


At each frame, Bit-54 (title F) determine whether it is odd or even:
::

  0 -> Even frame
  1 -> Odd frame


*Bit-53 (title T) shows whether it is synchronized with the UTC time. It's not used in our calculation.*


Calculate latitude and longitude
********************************

There are a few documents explain in detail the math behind the CPR. for example: `A document from Eurocontrol
<http://www.eurocontrol.int/eec/gallery/content/public/document/eec/report/1995/002_Aircraft_Position_Report_using_DGPS_Mode-S.pdf>`_.
Our foucus is on decoding, hence the reversing of those math equations.

Let's frist seperate the CPR latitude and longitude bits in both messages. And the steps after will guide you to calculate LAT/LON of the aircraft.
::

  | F | CPR Latitude      | CPR Longitude     |
  |---|-------------------|-------------------|
  | 0 | 10110101101001000 | 01100100010101100 |
  | 1 | 10010000110101110 | 01100010000010010 |


**Step 1: Convert the binary string to decimal value**
::

  cprLat0 = 93000
  cprLon0 = 51372
  cprLat0 = 74158
  cprLon0 = 50194


**Step 2: Calculate the Latitude Index j, using following equation**

.. math::

  j = floor\left ( \frac{(59 * cprLat0 - 60 * cprLat0}{131072} + 0.5  \right )


::

  j = 8


**Step 3: Calculate relative latitudes**

First, two constants will be used:
::

  airDLat0 = 360.0 / 60
  airDLat1 = 360.0 / 59

Then we can use the following equations to compute the relative latitudes:

.. math::

  rLat0 = airDLat0 * mod(j, 60) + \frac{crpLat0}{131072}

.. math::

 rLat0 =
  \begin{cases}
   rLat0 -360  & \text{if } (rLat0 \geq 270) \\
   rLat0       & \text{else}
  \end{cases}

.. math::

  rLat1 = airDLat1 * mod(j, 59) + \frac{crpLat1}{131072}

.. math::

 rLat1 =
  \begin{cases}
   rLat1 -360  & \text{if } (rLat1 \geq 270) \\
   rLat1       & \text{else}
  \end{cases}

If a relative latitude results are greater than 270, it means the aircraft is at southern hemisphere. Then a substraction of 360 is applied.

Here, we have:
::

  rLat0 = 52.2572021484
  rLat1 = 52.2657801741


**Step 4: Check relative latitudes, and get aircraft true latitude**

After previous calculation, we still need to check if `rLat0` and `rLat1` are in the same latitude zone. If not, simply make an exit here; wait for new CPR data frames, the run the computation again.

There are 60 latitude zones pre-computed. You may refer to the python source code to see how latitudes degrees are divided into different zones. We have a function `cprNL()` retrieving the ``NL`` value In our case, both value are in latitude zone `36`, good to continue.

In order to find a better latitude value ``lat`` from ``lat0`` and ``lat1``, we need to have a look the time stamp of both odd and even frames. The newest one is used:

.. math::

  lat =
  \begin{cases}
   lat0     & \text{if } (rLat0_{time} \geq rLat1_{time}) \\
   lat1     & \text{else}
  \end{cases}


**Step 5: Calculate longitude**

In order to compute the longitude, we need to get the ``N(i)`` and longitude index ``m``. ``N(i)`` is computed using ``cprN()`` function, which also look into the latitude zone table; together with the latest ``rLat`` frame (``rLat0`` or ``rLat1``, depends which is the newest).

.. math::

  N(i) =
  \begin{cases}
   cprN(rLat0, 0)     & \text{if } (rLat0_{time} \geq rLat1_{time}) \\
   cprN(rLat1, 1)     & \text{else}
  \end{cases}

.. math::

  m = floor\left ( \frac{cprLon0 * (cprNL(lat)-1) - cprLon1 * cprNL(lat)}{131072} + 0.5  \right )

Before continuing compute the longitude, another fuction ``cprDLon()`` is introduction to convert the ``N(i)`` to number of degree: ``360.0 / N(i)``. longitude is then calculated:

.. math::

  lon =
  \begin{cases}
   (360.0 / N(i)) * ( Mod(m, ni) + cprLon0 / 131072)     & \text{if } (rLat0_{time} \geq rLat1_{time}) \\
   (360.0 / N(i)) * ( Mod(m, ni) + cprLon1 / 131072)     & \text{else}
  \end{cases}

So now we have both latitude and longitude of the aircraft:
::

  lat: 52.26578017412606 
  lon: 3.938912527901786


Calculate altitude
******************

Altitude of aircraft in the data frame is much easier to be computed. The bits in the altitude field (either odd or even frame) are as following:
::

  1100001 1 1000
          ^
         Q-bit

This Q-bit indicates whether the altitude can be decoded. If the value is zero, we will exit the calculation. Then the altitude value is computed from the rest of the bits. 

*Off the topic: really don't understand why someone wanted to put this bit in the middle...*

After removing Q-bit:
::

  N = 1100001 1000 => 1560 (in decimal)

The final altitude value will be:

.. math::

  alt = N * 25 - 1000 & \text { (ft.)}

In the example, the altitude at which aircraft is flying is:
::
  
  1560 * 25 - 1000 = 38000 ft.


The position
***************************************************************************
So finally, we have all three value (LAT/LON/ALT) of the aircraft position:
::

  LAT: 52.17578
  LON:  3.93891
  ALT: 38000 ft


Aircraft speed and heading
--------------------------

An aircraft velocity message has ``DF: 17``, ``TC: 19``.

For example, following message is received:
::

  8D40621D99454F9E0004A7715C19

  |    | ICAO24 |      DATA      |        |
  |----|--------|----------------|--------|
  | 8D | 40621D | 99454F9E0004A7 | 715C19 |

  | DF    | CA  | ICAO24 ADDRESS           | TC    | ......
  |-------|-----|--------------------------|-------|-------
  | 10001 | 101 | 010000000110001000011101 | 10011 | ......

We can confirm the DF=17 and TC=19. Good to decode the velocity. Next, let's extract the data frame:
::

  |  TC   | ST  | IC | IFR | VU  | S-EW | V-EW       | S-NS | V-NS       | V-rate sign source | TI | GHD sign   |
  |-------|-----|----|-----|-----|------|------------|------|------------|--------------------|----|------------|
  | 10011 | 001 | 0  | 1   | 000 | 1    | 0101001111 | 1    | 0011110000 | 000000000  0  1    | 00 | 1010011  1 |


There are many parameters in the the velocity message. From left to rights, the number of bits indicate the following contents:

+-------------+----------------------------------+
| No. of bits | Content                          |
+=============+==================================+
| 5           | Type code                        |
+-------------+----------------------------------+
| 3           | Subtype                          |
+-------------+----------------------------------+
| 1           | Intent change flag               |
+-------------+----------------------------------+
| 1           | IFR capability flag              |
+-------------+----------------------------------+
| 3           | Velocity uncertainty             |
+-------------+----------------------------------+
| 1           | East-West velocity sign          |
+-------------+----------------------------------+
| 10          | East-West velocity               |
+-------------+----------------------------------+
| 1           | North-South velocity sign        |
+-------------+----------------------------------+
| 10          | North-South velocity             |
+-------------+----------------------------------+
| 9           | Vertical rate                    |
+-------------+----------------------------------+
| 1           | Vertical rate sign               |
+-------------+----------------------------------+
| 1           | Vertical rate source             |
+-------------+----------------------------------+
| 2           | Turn indicator                   |
+-------------+----------------------------------+
| 7 + 1       | Geometric height difference from |
|             | barometric + sign                |
+-------------+----------------------------------+

*NOTE: If you are also refering an interenet document called "ADS-B for Dummies" by EuroControl, be very aware, the information table in that document is NOT correct !! The bits for velocities and sign were ordered wrong in that document.*

For calculating the speed and heading we need four values, East-West Velocity ``V(ew)``, East-West Velocity Sign ``S(ew)``, North-South Velocity ``V(ns)``, North-South Velocity Sign ``S(ns)``. And pay attention on the directions (signs) in the calculation.

.. math::

  V(we) =
  \begin{cases}
   -1 * V(ew)    & \text{if } (s(ew) = 1) \\
   V(ew)         & \text{if } (s(ew) = 0)
  \end{cases}

.. math::

  V(sn) =
  \begin{cases}
   -1 * V(ns)    & \text{if } (s(ns) = 1) \\
   V(ns)         & \text{if } (s(ns) = 0)
  \end{cases}

Speed (v) and heading (h) can be computed as following:

.. math::

  v = \sqrt{V_{we}^{2} + V_{sn}^{2}}

.. math::

  h = arctan(\frac{V_{we}}{V_{sn}}) * \frac{360}{2\pi}  \quad \text{(deg)}

In case of an negative value here, we will simply add 360 degrees.

.. math::

  h = h + 360  \quad (\text{if } h < 0)

So, now we have the speed and heading of our example:
::

  V(ew): 0101001111 -> 335
  S(ew): 1
  V(ns): 0011110000 -> 240
  S(ns): 1

  V(we) = -335
  V(sn) = -240

  v = 412.0983 (kn)
  h = 234.3815 (deg)
