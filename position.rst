Airborne Positions
==================

Decoding the positions of the aircraft is a bit complicated. Naturally, we
would expect to read latitude and longitude directly from the data frame.
Unfortunately, it's not that simple...

Two different types of the position messages (odd and even frames) are needed to
find out the LAT and LON of the aircraft. The position is described in the
Compact Position Reporting (CPR) format. There are not many easy to read
documents on CPR encoding and decoding, though.

The advantage of CPR is that it uses fewer bits to encode the position
information. The disadvantage is the complexity of decoding it.

An aircraft position message has ``DownlinkFormat: 17`` and ``TypeCode: from 9
to 18``.


Determine whether the frame is "odd" or "even"
-------------------------------

For example, the two following messages are received:
::

  8D40621D58C382D690C8AC2863A7
  8D40621D58C386435CC412692AD6

  |    | ICAO24 |      DATA      |        |
  |----|--------|----------------|--------|
  | 8D | 40621D | 58C382D690C8AC | 2863A7 |
  | 8D | 40621D | 58C386435CC412 | 692AD6 |



Convert both messages to binary strings:
::

  | DF    | CA  | ICAO24 ADDRESS           | DATA                                                                              | CRC                      |
  |                                        | TC    | SS | NICsb | ALT          | T | F | LAT-CPR           | LON-CPR           |                          |
  |-------|-----|--------------------------|-------|----|-------|--------------|---|---|-------------------|-------------------|--------------------------|
  | 10001 | 101 | 010000000110001000011101 | 01011 | 00 | 0     | 110000111000 | 0 | 0 | 10110101101001000 | 01100100010101100 | 001010000110001110100111 |
  | 10001 | 101 | 010000000110001000011101 | 01011 | 00 | 0     | 110000111000 | 0 | 1 | 10010000110101110 | 01100010000010010 | 011010010010101011010110 |



Message components:

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


In both messages we can find ``DF=17`` and ``TC=11``, with the same ICAO24
address ``40621D``. So, those two frames are valid for decoding the positions of
this aircraft.


For each frame, bit 54 determines whether it is an "odd" or "even" frame:
::

  0 -> Even frame
  1 -> Odd frame


Calculate latitude and longitude
--------------------------------

There are a few documents that explain in detail the math behind the CPR. For
example: `a document from Eurocontrol <http://www.eurocontrol.int/eec/gallery/co
ntent/public/document/eec/report/1995/002_Aircraft_Position_Report_using_DGPS_Mo
de-S.pdf>`_. Our focus is on decoding, hence the reversing of those math
equations.

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


Since CPR latitude and longitude are encoded in 17 bits, 131072 (2^17) is the maximum value. The
resulting values from the calculations represent the percentages of that maximum value.


Step 2: Calculate the latitude index j
****************************************************************

Use the following equation:

.. math::

  j = floor\left ( 59 * Lat_{CPR-E} - 60 * Lat_{CPR-O} + 0.5  \right )


::

  j = 8


Step 3: Calculate relative latitudes
************************************

First, two constants will be used:
::

  DLat_EVEN = 360.0 / 60
  DLat_ODD  = 360.0 / 59

Then we can use the following equations to compute the relative latitudes:

.. math::

  Lat_{E} = DLat_{E} * (mod(j, 60) + Lat_{CPR-E})

  \qquad Lat_{E} = Lat_{E} - 360  \quad \text{if } (Lat_{E} \geq 270)

  Lat_{O} = DLat_{O} * (mod(j, 59) + Lat_{CPR-O})

  \qquad Lat_{O} = Lat_{O} - 360  \quad \text{if } (Lat_{O} \geq 270)

If a relative latitude result is greater than 270, it means that the aircraft is in
the southern hemisphere. If this is the case, subtract 360 from the value.

Here, we have:
::

  Lat_EVEN = 52.25720214843750
  Lat_ODD  = 52.26578017412606


Then, we need to check if ``Lat_EVEN`` and ``Lat_ODD`` are in the same latitude
zone. If not, simply exit here, wait for new data, then run the
computation again.

There are 60 latitude zones pre-computed. You may refer to the Python source
code `here <https://github.com/junzis/py-adsb-decoder/blob/master/decoder.py>`_
to see how latitude degrees are divided into different zones. We have a
function ``NL()`` retrieving the ``NL`` value. In our case, both values are in
latitude zone 36, so we can continue.

The final latitude is chosen depending on the time stamp of the frames--the newest one is
used:

.. math::

  Lat =
  \begin{cases}
   Lat_{E}     & \text{if } (T_{0} \geq T_{1}) \\
   Lat_{O}     & \text{else}
  \end{cases}

In our case:
::

  Lat = Lat_EVEN = 52.25720214843750


Step 4: Calculate longitude
***************************

In order to get the longitude, we need to first compute the longitude index
``m``, and ``ni`` with ``N()`` function, which also looks into the latitude zone
table.

.. math::

  ni =
  \begin{cases}
   N(Lat_{E}, 0)     & \text{if } (T_{0} \geq T_{1}) \\
   N(Lat_{O}, 1)     & \text{else}
  \end{cases}

  m =
  \begin{cases}
   floor\left [ Lon_{CPR-E} * (NL(Lat_{E})-1) - Lon_{CPR-O} * NL(Lat_{E}) + 0.5  \right ]     & \text{if } (T_{0} \geq T_{1}) \\
   floor\left [ Lon_{CPR-E} * (NL(Lat_{O})-1) - Lon_{CPR-O} * NL(Lat_{O}) + 0.5  \right ]     & \text{else}
  \end{cases}


Longitude is then calculated:

.. math::

  Lon =
  \begin{cases}
   \frac{360.0}{ni} * ( Mod(m, ni) + Lon_{CPR-E} )  & \text{if } (T_{0} \geq T_{1}) \\
   \frac{360.0}{ni} * ( Mod(m, ni) + Lon_{CPR-O} ) & \text{else}
  \end{cases}

  Lon = Lon - 360  \quad \text{if } (Lon \geq 180)


Step 5: Combine the coordinates to get the position of the aircraft
***********************************************************


::

  Lat: 52.25720 
  Lon:  3.91937

Following is the calculation implemented in Python:

.. code-block:: python

  def cpr2position(cprlat0, cprlat1, cprlon0, cprlon1, t0, t1):
    cprlat_even = cprlat0 / 131072.0
    cprlat_odd  = cprlat1 / 131072.0
    cprlon_even = cprlon0 / 131072.0
    cprlon_odd  = cprlon0 / 131072.0

    air_d_lat_even = 360.0 / 60 
    air_d_lat_odd = 360.0 / 59 

    # compute latitude index 'j'
    j = int(59 * cprlat_even - 60 * cprlat_odd + 0.5)

    lat_even = float(air_d_lat_even * (j % 60 + cprlat_even))
    lat_odd  = float(air_d_lat_odd  * (j % 59 + cprlat_odd))

    if lat_even >= 270:
      lat_even = lat_even - 360
    
    if lat_odd >= 270:
      lat_odd = lat_odd - 360

    # check if both are in the same latitude zone, exit if not
    if cprNL(lat_even) != cprNL(lat_odd):
      return None

    # compute ni, longitude index m, and longitude
    if (t0 > t1):
      ni = cprN(lat_even, 0)
      m = math.floor( cprlon_even * (cprNL(lat_even)-1) - cprlon_odd * cprNL(lat_even) + 0.5 ) 
      lon = (360.0 / ni) * (m % ni + cprlon_even)
      lat = lat_even
    else:
      ni = cprN(lat_odd, 1)
      m = math.floor( cprlon_even * (cprNL(lat_odd)-1) - cprlon_odd * cprNL(lat_odd) + 0.5 ) 
      lon = (360.0 / ni) * (m % ni + cprlon_odd)
      lat = lat_odd

    if lon > 180:
      lon = lon - 360

    return [lat, lon]


Calculate altitude
------------------

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

  Alt = N * 25 - 1000 & \text { (ft.)}

In this example, the altitude at which aircraft is flying is:
::
  
  1560 * 25 - 1000 = 38000 ft.

Note that the altitude has the accuracy of +/- 25 ft when the Q-bit is 1, and the
value can represent altitude from -1000 to +50175 ft.

The position
------------
Finally, we have all three components (latitude/longitude/altitude) of the aircraft position:
::

  LAT: 52.25720 (degrees N)
  LON:  3.91937 (degrees E)
  ALT:    38000 ft
