Airborne Positions
------------------

An aircraft airborne position message has ``Downlink Format: 17 or 18`` and ``Type Code: from 9 to 18``.

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


Two types of the position messages (odd and even frames) are broadcast alternately. There are two different ways to decode an airborne position base on these messages:

1. Unknown position, using both type of messages (aka. globally unambiguous position)
2. Knowing previous position, using only one message (aka. locally unambiguous position)


Note: The definition of functions ``NL(lat)``, ``floor(x)``, and ``mod(x,y)`` are described in CPR chapter


Globally unambiguous position (decoding with two messages)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


odd" or "even" message?
**************************

For each frame, bit 54 determines whether it is an "odd" or "even" frame: ::

  0 -> Even frame
  1 -> Odd frame


For example, the two following messages are received:

.. code-block:: text

  8D40621D58C382D690C8AC2863A7
  8D40621D58C386435CC412692AD6

  |    | ICAO24 |      DATA      |  CRC   |
  |----|--------|----------------|--------|
  | 8D | 40621D | 58C382D690C8AC | 2863A7 |
  | 8D | 40621D | 58C386435CC412 | 692AD6 |


  Data in binary:

  | DATA                                                                              |
  |===================================================================================|
  | TC    | SS | NICsb | ALT          | T | F | CPR-LAT           | CPR-LON           |
  |-------|----|-------|--------------|---|---|-------------------|-------------------|
  | 01011 | 00 | 0     | 110000111000 | 0 | 0 | 10110101101001000 | 01100100010101100 |
  | 01011 | 00 | 0     | 110000111000 | 0 | 1 | 10010000110101110 | 01100010000010010 |


In both messages we can find ``DF=17`` and ``TC=11``, with the same ICAO24 address ``40621D``. So, those two frames are valid for decoding the positions of this aircraft. Assume the first message is the newest message received.


The CPR representation of coordinates
****************************************
.. code-block:: text

  | F | CPR Latitude      | CPR Longitude     |
  |---|-------------------|-------------------|
  | 0 | 10110101101001000 | 01100100010101100 |  -> newest frame received
  | 1 | 10010000110101110 | 01100010000010010 |
  |---|-------------------|-------------------|

  In decimal:

  |---|-------------------|-------------------|
  | 0 | 93000             | 51372             |
  | 1 | 74158             | 50194             |
  |---|-------------------|-------------------|

  CPR_LAT_EVEN: 93000 / 131072 -> 0.7095
  CPR_LON_EVEN: 51372 / 131072 -> 0.3919
  CPR_LAT_ODD:  74158 / 131072 -> 0.5658
  CPR_LON_ODD:  50194 / 131072 -> 0.3829


Since CPR latitude and longitude are encoded in 17 bits, 131072 (2^17) is the maximum value.


Calculate the latitude index j
*********************************

Use the following equation:

.. math::

  j = floor \left( 59 \cdot \mathrm{Lat}_\mathrm{cprEven} - 60 \cdot \mathrm{Lat}_\mathrm{cprOdd} + \frac{1}{2}  \right)


::

  j = 8


Calculate latitude
*********************

First, two constants will be used:

.. math::

  \mathrm{dLat}_\mathrm{even} &= \frac{360}{4 \cdot NZ} = \frac{360}{60}

  \mathrm{dLat}_\mathrm{odd} &= \frac{360}{4 \cdot NZ - 1}  = \frac{360}{59}


Then we can use the following equations to compute the relative latitudes:

.. math::

  \mathrm{Lat}_\mathrm{even} &= \mathrm{dLat}_\mathrm{even} \cdot [mod(j, 60) + \mathrm{Lat}_\mathrm{cprEven}]

  \mathrm{Lat}_\mathrm{odd} &= \mathrm{dLat}_\mathrm{odd} \cdot [mod(j, 59) + \mathrm{Lat}_\mathrm{cprOdd}]

For southern hemisphere, values will fall from 270 to 360 degrees. we need to
make sure the latitude is within range ``[-90, +90]``:

.. math::

  \mathrm{Lat}_\mathrm{even} &= \mathrm{Lat}_\mathrm{even} - 360  \quad \text{if } (\mathrm{Lat}_\mathrm{even} \geq 270)

  \mathrm{Lat}_\mathrm{odd} &= \mathrm{Lat}_\mathrm{odd} - 360  \quad \text{if } (\mathrm{Lat}_\mathrm{odd} \geq 270)


Final latitude is chosen depending on the time stamp of the frames--the newest one is
used:

.. math::

  \mathrm{Lat} =
  \begin{cases}
   \mathrm{Lat}_\mathrm{even}     & \text{if } (T_\mathrm{even} \geq T_\mathrm{odd}) \\
   \mathrm{Lat}_\mathrm{odd}     & \text{else}
  \end{cases}

In the example:
::

  Lat_EVEN = 52.25720214843750
  Lat_ODD  = 52.26578017412606
  Lat = Lat_EVEN = 52.25720


Check the latitude zone consistency
**************************************

Compute ``NL(Lat_E)`` and ``NL(Lat_O)``. If not the same, two positions are located at different latitude zones. Computation of a global longitude is not
possible. exit the calculation and wait for new messages. If two values are the same, we proceed to longitude calculation.


Calculate longitude
**********************

If the even frame come latest ``T_EVEN > T_ODD``:

.. math::

  ni &= max \left( NL(\mathrm{Lat}_\mathrm{even}), 1 \right)

  \mathrm{dLon} &= \frac{360}{ni}

  m &= floor \left\{ Lon_\mathrm{cprEven} \cdot [NL(\mathrm{Lat}_\mathrm{even})-1] - Lon_\mathrm{cprOdd} \cdot NL(\mathrm{Lat}_\mathrm{even}) + \frac{1}{2}  \right\}

  \mathrm{Lon} &= \mathrm{dLon} \cdot \left( mod(m, ni) + Lon_\mathrm{cprEven} \right)


In case where the odd frame come latest ``T_EVEN < T_ODD``:

.. math::

  ni &= max \left( NL(\mathrm{Lat}_\mathrm{odd})-1, 1 \right)

  \mathrm{dLon} &= \frac{360}{ni}

  m &= floor \left\{ Lon_\mathrm{cprEven} \cdot [NL(\mathrm{Lat}_\mathrm{odd})-1] - Lon_\mathrm{cprOdd} \cdot NL(\mathrm{Lat}_\mathrm{odd}) + \frac{1}{2}  \right\}

  \mathrm{Lon} &= \mathrm{dLon} \cdot \left( mod(m, ni) + Lon_\mathrm{cprOdd} \right)


if the result is larger than 180 degrees:

.. math::

  \mathrm{Lon} = \mathrm{Lon} - 360  \quad \text{if } (\mathrm{Lon} \geq 180)



In the example:
::

  Lon:  3.91937


Here is a Python implemented: https://github.com/junzis/pyModeS/blob/faf4313/pyModeS/adsb.py#L166



Calculate altitude
******************

The altitude of the aircraft is much easier to compute from the data frame. The bits in the altitude field (either odd or even frame) are as following:
::

  1100001 1 1000
          ^
         Q-bit

This Q-bit (bit 48) indicates whether the altitude is encoded in multiples of 25 or 100 ft (0: 100 ft, 1: 25 ft).

For Q = 1, we can calculate the altitude as following:

First, remove the Q-bit
::

  N = 1100001 1000 => 1560 (in decimal)

The final altitude value will be:

.. math::

  Alt = N \cdot 25 - 1000 \quad \text{(ft.)}

In this example, the altitude at which aircraft is flying is:
::

  1560 * 25 - 1000 = 38000 ft.

Note that the altitude has the accuracy of +/- 25 ft when the Q-bit is 1, and the value can represent altitude from -1000 to +50175 ft.



The final position
******************

Finally, we have all three components (latitude/longitude/altitude) of the aircraft position:
::

  LAT: 52.25720 (degrees N)
  LON:  3.91937 (degrees E)
  ALT:    38000 ft


Locally unambiguous position (decoding with one message)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This method gives the possibility of decoding aircraft using only one message knowing a reference position. This method compute the latitude index (j) and longitude index (m) based on such reference, and can be used with either type of the messages.


The reference position
**************************
The reference position should be close to the actual position (eg. position of aircraft previously decoded, or the location of ADS-B antenna), and must be **within 180 NM** range.


Calculate dLat
**************

.. math::

  dLat =
  \begin{cases}
   \frac{360}{4 \cdot NZ} = \frac{360}{60}          & \text{if even message}  \\
   \frac{360}{4 \cdot NZ - 1}  = \frac{360}{59}     & \text{if odd message}
  \end{cases}



Calculate the latitude index j
*********************************

.. math::

  j = floor \left (\frac{\mathrm{Lat}_{ref}}{dLat} \right) + floor \left( \frac{mod(\mathrm{Lat}_{ref}, dLat)}{dLat}  - \mathrm{Lat}_\mathrm{cpr}  + \frac{1}{2} \right)



Calculate latitude
*********************

.. math::

  \mathrm{Lat} = dLat \cdot (j + \mathrm{Lat}_\mathrm{cpr})



Calculate dLon
**************

.. math::

  \mathrm{dLon} =
  \begin{cases}
   \frac{360}{NL(Lat)}    & \text{if } NL(Lat) > 0  \\
   360                    & \text{if } NL(Lat) = 0
  \end{cases}


Calculate longitude index m
****************************

.. math::

  m = floor \left( \frac{Lon_{ref}}{\mathrm{dLon}} \right) + floor \left( \frac{mod(Lon_{ref}, \mathrm{dLon})}{\mathrm{dLon}}  - Lon_\mathrm{cpr}  + \frac{1}{2}  \right)


Calculate longitude
*********************

.. math::

  Lon = \mathrm{dLon} \cdot (m + Lon_\mathrm{cpr})


Example
*******

For the same example message:

.. code-block:: text

  8D40621D58C382D690C8AC2863A7

  Reference position:
    LAT: 52.258
    LON:  3.918



The structure of message is:

.. code-block:: text

  8D40621D58C382D690C8AC2863A7

  |    | ICAO24 |      DATA      |  CRC   |
  |----|--------|----------------|--------|
  | 8D | 40621D | 58C382D690C8AC | 2863A7 |


  Data in binary:

  | DATA                                                                              |
  |===================================================================================|
  | TC    | SS | NICsb | ALT          | T | F | CPR-LAT           | CPR-LON           |
  |-------|----|-------|--------------|---|---|-------------------|-------------------|
  | 01011 | 00 | 0     | 110000111000 | 0 | 0 | 10110101101001000 | 01100100010101100 |


  CPR representation:

  | F | CPR Latitude      | CPR Longitude     |
  |---|-------------------|-------------------|
  | 0 | 10110101101001000 | 01100100010101100 |
  |---|-------------------|-------------------|

  In decimal:

  |---|-------------------|-------------------|
  | 0 | 93000             | 51372             |
  |---|-------------------|-------------------|

  CPR_LAT: 93000 / 131072 -> 0.7095
  CPR_LON: 51372 / 131072 -> 0.3919


Run the calculation, the same result will be decoded:
::

  d_lat:  6
  j:      8
  lat:    52.25720
  m:      0
  d_lon:  10
  lon:    3.91937
