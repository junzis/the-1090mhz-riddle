Airborne Positions
==================

An aircraft position message has ``DownlinkFormat: 17`` and ``TypeCode: from 9
to 18``.

Messages are composed as following:

+-----------+---------+---------+----------------------------------+
| MSG bits  | # bits  | Abbr    | Content                          |
+===========+=========+=========+==================================+
| 1-5       | 5       | DF      | Downlink format                  |
+-----------+---------+---------+----------------------------------+
| 33-37     | 5       | TC      | Type code                        |
+-----------+---------+---------+----------------------------------+
| 38-39     | 2       | SS      | Surveillance status              |
+-----------+---------+---------+----------------------------------+
| 40        | 1       | NICsb   | NIC supplement-B                 |
+-----------+---------+---------+----------------------------------+
| 41-52     | 12      | ALT     | Altitude                         |
+-----------+---------+---------+----------------------------------+
| 53        | 1       | T       | Time                             |
+-----------+---------+---------+----------------------------------+
| 54        | 1       | F       | CPR odd/even frame flag          |
+-----------+---------+---------+----------------------------------+
| 55-71     | 17      | LAT-CPR | Latitude in CPR format           |
+-----------+---------+---------+----------------------------------+
| 72-88     | 17      | LON-CPR | Longitude in CPR format          |
+-----------+---------+---------+----------------------------------+


Decoding the positions of the aircraft is a bit complicated. Naturally, we
would expect to read latitude and longitude directly from the data frame.
Unfortunately, it's not that simple...

Two different types of the position messages (odd and even frames) are needed
to find out the LAT and LON of the aircraft. The position is described in the
Compact Position Reporting (CPR) format. The advantage of CPR is that we can
use fewer bits to encode position with higher resolution. However this results
the complexity of decoding process.


First, "odd" or "even" message?
-------------------------------

For each frame, bit 54 determines whether it is an "odd" or "even" frame:
::

  0 -> Even frame
  1 -> Odd frame


For example, the two following messages are received:
::

  8D40621D58C382D690C8AC2863A7
  8D40621D58C386435CC412692AD6

  |    | ICAO24 |      DATA      |  CRC   |
  |----|--------|----------------|--------|
  | 8D | 40621D | 58C382D690C8AC | 2863A7 |
  | 8D | 40621D | 58C386435CC412 | 692AD6 |



Convert both messages to binary strings:
::

  | DF    | CA  | ICAO24 ADDRESS           | DATA                                    ->
  |=======|=====|==========================|========================================
  |                                        | TC    | SS | NICsb | ALT          | T | ->
  |-------|-----|--------------------------|-------|----|-------|--------------|---| ->
  | 10001 | 101 | 010000000110001000011101 | 01011 | 00 | 0     | 110000111000 | 0 | ->
  | 10001 | 101 | 010000000110001000011101 | 01011 | 00 | 0     | 110000111000 | 0 | ->


    ->  Data (cont.)                                | CRC                      |
    ->  ============================================|==========================|
    ->  | F | LAT-CPR           | LON-CPR           |                          |
    ->  |---|-------------------|-------------------|--------------------------|
    ->  | 0 | 10110101101001000 | 01100100010101100 | 001010000110001110100111 |
    ->  | 1 | 10010000110101110 | 01100010000010010 | 011010010010101011010110 |


In both messages we can find ``DF=17`` and ``TC=11``, with the same ICAO24
address ``40621D``. So, those two frames are valid for decoding the positions of
this aircraft.




CPR parameters and functions
----------------------------

First, we denotes some of the parameters and common functions used in the
decoding process here.

NZ
**

Number of geographic latitude zones between equator and a pole. It is set to
``NZ = 15`` for Mode-S CPR encoding

floor(x)
********

the floor function ``floor(x)`` defines as the greatest integer value k, such that
``k<=x``, for example:
::
    floor(5.6) = 5
    floor(-5.6) = -6

mod(x, y)
*********

the modulus function ``mod(x, y)`` return:

.. math::

  x - y \cdot floor(\frac{x}{y})

where ``y`` can not be zero


NL(lat)
*******

Denotes the "number of longitude zones" function, given the latitude angle
``lat``. The returned integer value is constrained within ``[1, 59]``,
calculated as:


.. math::

  \text{NL}(lat) = floor \left( \frac{2 \pi}{\arccos(1 - \frac{1-\cos(\frac{\pi}{2 \cdot \text{NZ}})}{\cos^2(\frac{\pi}{180} \cdot \text{lat})}) } \right)

For latitudes that are close to equator or poles, following value is returned:
::
  lat = 0     ->    NL = 59
  lat = +87   ->    NL = 2
  lat = -87   ->    NL = 2
  lat > +87   ->    NL = 1
  lat < -87   ->    NL = 1



Latitude/Longitude calculation
------------------------------

There are a few technical documents that explain in detail the math behind the
CPR. For example: `a document from Eurocontrol
<http://www.eurocontrol.int/eec/gallery/co ntent/public/document/eec/report/19
95/002_Aircraft_Position_Report_using_DGPS_Mo de-S.pdf>`_.

Let's first separate the CPR latitude and longitude bits in both messages.
The steps after will guide you to calculate the LAT/LON of the aircraft. 

::

  | F | CPR Latitude      | CPR Longitude     |
  |---|-------------------|-------------------|
  | 0 | 10110101101001000 | 01100100010101100 |  -> newest frame received
  | 1 | 10010000110101110 | 01100010000010010 |


Step 1: Convert the binary string to decimal value
**************************************************
::

  LAT_CPR_EVEN: 93000 / 131072 -> 0.7095
  LON_CPR_EVEN: 51372 / 131072 -> 0.3919
  LAT_CPR_ODD:  74158 / 131072 -> 0.5658
  LON_CPR_ODD:  50194 / 131072 -> 0.3829


Since CPR latitude and longitude are encoded in 17 bits, 131072 (2^17) is the
maximum value. The resulting values from the calculations represent the
percentages of that maximum value.


Step 2: Calculate the latitude index j
****************************************************************

Use the following equation:

.. math::

  j = floor\left ( 59 \cdot Lat_{cprE} - 60 \cdot Lat_{cprO} + \frac{1}{2}  \right )


::

  j = 8


Step 3: Latitude
****************

First, two constants will be used:

.. math::

  DLat_{E} &= \frac{360}{4 \times NZ} = \frac{360}{60}

  DLat_{O} &= \frac{360}{4 \times NZ - 1}  = \frac{360}{59}


Then we can use the following equations to compute the relative latitudes:

.. math::

  Lat_{E} &= DLat_{E} * (mod(j, 60) + Lat_{cprE})

  Lat_{O} &= DLat_{O} * (mod(j, 59) + Lat_{cprO})

For southern hemisphere, values will fall from 270 to 360 degrees. we need to
make sure the latitude is within range ``[-90, +90]``:

.. math::

  Lat_{E} &= Lat_{E} - 360  \quad \text{if } (Lat_{E} \geq 270)
  
  Lat_{O} &= Lat_{O} - 360  \quad \text{if } (Lat_{O} \geq 270)


Final latitude is chosen depending on the time stamp of the frames--the newest one is
used:

.. math::

  Lat =
  \begin{cases}
   Lat_{E}     & \text{if } (T_{E} \geq T_{O}) \\
   Lat_{O}     & \text{else}
  \end{cases}

In the example:
::

  Lat_EVEN = 52.25720214843750
  Lat_ODD  = 52.26578017412606
  Lat = Lat_EVEN = 52.25720


Step 4: Check
*************

Compute ``NL(Lat_E)`` and ``NL(Lat_O)``. If not the same, two positions are
located at different latitude zones. Computation of a global longitude is not
possible. exit the calculation and wait for new messages.

If two values are the same, we proceed to longitude calculation.


Step 5: Longitude
***************************

If the even frame come latest ``T_EVEN > T_ODD``:

.. math::

  ni &= max \left( NL(Lat_{E}), 1 \right)

  DLon &= \frac{360}{ni}

  m &= floor\left ( Lon_{cprE} \cdot [NL(Lat_{E})-1] - Lon_{cprO} \cdot NL(Lat_{E}) + \frac{1}{2}  \right )

  Lon &= DLon \cdot \left( mod(m, ni) + Lon_{cprE} \right)


In case where the odd frame come latest ``T_EVEN < T_ODD``:

.. math::

  ni &= max \left( NL(Lat_{O})-1, 1 \right)

  DLon &= \frac{360}{ni}

  m &= floor\left ( Lon_{cprE} \cdot [NL(Lat_{O})-1] - Lon_{cprO} \cdot NL(Lat_{O}) + \frac{1}{2}  \right )

  Lon &= DLon \cdot \left( mod(m, ni) + Lon_{cprO} \right)


if the result is larger than 180 degrees:

.. math::

  Lon = Lon - 360  \quad \text{if } (Lon \geq 180)



In the example:
::

  Lon:  3.91937


Here is a Python implemented: https://github.com/junzis/pyModeS/blob/faf4313/pyModeS/adsb.py#L166



Altitude Calculation
--------------------

The altitude of the aircraft is much easier to compute from the data frame. The bits
in the altitude field (either odd or even frame) are as following:
::

  1100001 1 1000
          ^
         Q-bit

This Q-bit (bit 48) indicates whether the altitude is encoded in multiples of
25 or 100 ft (0: 100 ft, 1: 25 ft).

For Q = 1, we can calculate the altitude as following:

First, remove the Q-bit
::

  N = 1100001 1000 => 1560 (in decimal)

The final altitude value will be:

.. math::

  Alt = N * 25 - 1000 \text { (ft.)}

In this example, the altitude at which aircraft is flying is:
::
  
  1560 * 25 - 1000 = 38000 ft.

Note that the altitude has the accuracy of +/- 25 ft when the Q-bit is 1, and the
value can represent altitude from -1000 to +50175 ft.



The final position
------------------
Finally, we have all three components (latitude/longitude/altitude) of the aircraft position:
::

  LAT: 52.25720 (degrees N)
  LON:  3.91937 (degrees E)
  ALT:    38000 ft
