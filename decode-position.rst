Decode Airborne Positions
=========================

Decoding the positions of the aircraft is a bit complicated. Naturally, we would assume to read latitude and longitude directly from the data frame. Unfortunately its not that simple...

In fact, two different types of the position messages (odd and even frames) are needed to find out the LAT and LON of the aircraft. The position is described in so called Compact Position Reporting (CPR) format, which is hard to understand, and not well documented.

The advantage of CPR is that it uses less bits to encode the position information. The dis-advantage is obviously the complexity of calculation.

An aircraft position message has ``DF: 17``, and ``TC: from 9 to 18``. 


Determine an odd and even frame
-------------------------------

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

  | DF    | CA  | ICAO24 ADDRESS           | DATA                                                                          | CRC                      |
  |                                        | TC    | *1 |*2 | Altitude     |   |*3 | CPR Latitude      | CPR Longitude     |                          |
  |-------|-----|--------------------------|-------|----|---|--------------------------------------------------------------|--------------------------|
  | 10001 | 101 | 010000000110001000011101 | 01011 | 00 | 0 | 110000111000 | 0 | 0 | 10110101101001000 | 01100100010101100 | 001010000110001110100111 |
  | 10001 | 101 | 010000000110001000011101 | 01011 | 00 | 0 | 110000111000 | 0 | 1 | 10010000110101110 | 01100010000010010 | 011010010010101011010110 |


- \*1: Surveilance Status 
- \*2: NIC Supplement-B (useful when determin NIC 2/3 and 8/9, combine with TC) 
- \*3: ODD/EVEN flag


In both message we can find: ``DF=17`` and ``TC=11``, with the same ICAO24 address ``40621D``. So those two frames are valid for decoding the positions of this aircraft.


At each frame, Bit-54 determine whether it is odd or even:
::

  0 -> Even frame
  1 -> Odd frame


Calculate latitude and longitude
--------------------------------

There are a few documents explain in detail the math behind the CPR. for example: `A document from Eurocontrol
<http://www.eurocontrol.int/eec/gallery/content/public/document/eec/report/1995/002_Aircraft_Position_Report_using_DGPS_Mode-S.pdf>`_.
Our foucus is on decoding, hence the reversing of those math equations.

Let's frist seperate the CPR latitude and longitude bits in both messages. And the steps after will guide you to calculate LAT/LON of the aircraft.
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


131072 is 2^17 since CPR latitude and longitude are encoded in 17 bits. The values represent the percentages.


Step 2: Calculate the Latitude Index j, using following equation
****************************************************************

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

If a relative latitude results are greater than 270, it means the aircraft is at southern hemisphere. Then a substraction of 360 is applied. 131072 is 2^17 since CPR latitude and longitude are encoded in 17 bits.

Here, we have:
::

  Lat_EVEN = 52.25720214843750
  Lat_ODD  = 52.26578017412606


Then, we need to check if `Lat_EVEN` and `Lat_ODD` are in the same latitude zone. If not, simply make an exit here; wait for new data, the run the computation again.

There are 60 latitude zones pre-computed. You may refer to the python source code to see how latitudes degrees are divided into different zones. We have a function `NL()` retrieving the ``NL`` value In our case, both value are in latitude zone `36`, good to continue.

The final Latitude is chosen by the time stamp of the frames, the newest one is used:

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

In order to ge the longitude, we need to first compute the longitude index ``m``, and ``ni`` with ``N()`` function, which also look into the latitude zone table

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


Step 5: So now we have the final coordinate of the aircraft
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

    # check if both are in the same latidude zone, exit if not
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

Altitude of aircraft in the data frame is much easier to be computed. The bits in the altitude field (either odd or even frame) are as following:
::

  1100001 1 1000
          ^
         Q-bit

This Q-bit (Bit 48) indicates whether the altitude can be decoded. If the value is zero, we will exit the calculation. If one, then the altitude value can be computed from the rest of the bits. 

*Off the topic: really don't understand why someone wanted to put this bit in the middle...*

After removing Q-bit:
::

  N = 1100001 1000 => 1560 (in decimal)

The final altitude value will be:

.. math::

  Alt = N * 25 - 1000 & \text { (ft.)}

In the example, the altitude at which aircraft is flying is:
::
  
  1560 * 25 - 1000 = 38000 ft.


The position
------------
So finally, we have all three value (LAT/LON/ALT) of the aircraft position:
::

  LAT: 52.25720 
  LAT:  3.91937
  ALT: 38000 ft
