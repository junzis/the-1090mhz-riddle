Airborne Velocity
=================

There are two different types of messages for velocities, determined by  3-bit
subtype in the message. With subtype 1 and 2, surface velocity  (ground speed)
is reported. And in subtype 3 and 4, aircraft airspeed are reported.

In real world, very few of the subtype 3 or 4 messages are reported. In our
setup, we only received **0.3%** of these message with regard to subtype 1
(subtype 2 seems never used).

An aircraft velocity message has ``DF: 17``, ``TC: 19``. and the subtype code
are represented in bits 38 to 40. Now, we can decode those messages.


Decoding message subtype 1 or 2
--------------------------------

Subtype 1 (subsonic) or 2 (supersonic), are broadcast when ground velocity
information are available. The aircraft velocity contains speed and heading
information. The speed and heading are also decomposed into North-South, and
East-West components.

Note: The following decoding only apply to Subtype 1 (subsonic).

For example, following message is received:

::

  Message: 8D485020994409940838175B284F

  |    | ICAO24 |      DATA      |  CRC   |
  |----|--------|----------------|--------|
  | 8D | 485020 | 99440994083817 | 5B284F |

  Convert into binary:

  | HEADER                                 |  DATA                      ->
  |-------|-----|--------------------------|-------|-----|----|-------- ->
  | DF    | CA  | ICAO24 ADDRESS           |  TC   | ST  | IC | RESV_A  ->
  |-------|-----|--------------------------|-------|-----|----|-------- ->
  | 10001 | 101 | 010010000101000000100000 | 10011 | 001 | 0  | 1       ->

   ->  DATA (cont.)                                                 ->
   -> |-----|------|------------|------|------------|-------|------ ->
   -> | NAC | S-EW | V-EW       | S-NS | V-NS       | VrSrc | S-Vr  ->
   -> |-----|------|------------|------|------------|-------|------ ->
   -> | 000 | 1    | 0000001001 | 1    | 0010100000 | 0     | 1     ->

   ->  DATA (cont.)                          | CRC                      |
   -> |-----------|--------|-------|---------|--------------------------|
   -> | Vr        | RESV_B | S-Dif | Dif     | CRC                      |
   -> |-----------|--------|-------|---------|--------------------------|
   -> | 000001110 | 00     | 0     | 0010111 | 010110110010100001001111 |



There are quite a few parameters in the the velocity message. From left to
rights, the number of bits indicate the following contents:

+-----------+---------+--------+----------------------------------+
| MSG Bits  | N bits  | Abbr   | Content                          |
+===========+=========+========+==================================+
| 33-37     | 5       | TC     | Type code                        |
+-----------+---------+--------+----------------------------------+
| 38-40     | 3       | ST     | Subtype                          |
+-----------+---------+--------+----------------------------------+
| 41        | 1       | IC     | Intent change flag               |
+-----------+---------+--------+----------------------------------+
| 42        | 1       | RESV_A | Reserved-A                       |
+-----------+---------+--------+----------------------------------+
| 43-45     | 3       | NAC    | Velocity uncertainty (NAC)       |
+-----------+---------+--------+----------------------------------+
| 46        | 1       | S-WE   | East-West velocity sign          |
+-----------+---------+--------+----------------------------------+
| 47-56     | 10      | V-WE   | East-West velocity               |
+-----------+---------+--------+----------------------------------+
| 57        | 1       | S-NS   | North-South velocity sign        |
+-----------+---------+--------+----------------------------------+
| 58-67     | 10      | V-NS   | North-South velocity             |
+-----------+---------+--------+----------------------------------+
| 68        | 1       | VrSrc  | Vertical rate source             |
+-----------+---------+--------+----------------------------------+
| 69        | 1       | S-Vr   | Vertical rate sign               |
+-----------+---------+--------+----------------------------------+
| 70-78     | 9       | Vr     | Vertical rate                    |
+-----------+---------+--------+----------------------------------+
| 79-80     | 2       | RESV_B | Reserved-B                       |
+-----------+---------+--------+----------------------------------+
| 81        | 1       | S-Dif  | Diff from baro alt, sign         |
+-----------+---------+--------+----------------------------------+
| 82-88     | 7       | Dif    | Diff from baro alt               |
+-----------+---------+--------+----------------------------------+

Horizontal Velocity
*******************

For calculating the horizontal speed and heading we need four values, East-West
Velocity ``V(ew)``, East-West Velocity Sign ``S(ew)``, North-South Velocity
``V(ns)``, North-South Velocity Sign ``S(ns)``. And pay attention on the
directions (signs) in the calculation.

::

  S-NS:
      1 -> flying North to South
      0 -> flying South to North
  S-EW:
      1 -> flying East to West
      0 -> flying West to East

In mathematical representation, the Speed (v) and heading (h) can be computed as
following:

.. math::

  V(we) =
  \begin{cases}
   -1 * [V(ew) - 1]    & \text{if } (s(ew) = 1) \\
   V(ew) - 1         & \text{if } (s(ew) = 0)
  \end{cases}

.. math::

  V(sn) =
  \begin{cases}
   -1 * [V(ns) - 1]    & \text{if } (s(ns) = 1) \\
   V(ns) - 1         & \text{if } (s(ns) = 0)
  \end{cases}

.. math::

  v = \sqrt{V_{we}^{2} + V_{sn}^{2}}

.. math::

  h = arctan(\frac{V_{we}}{V_{sn}}) * \frac{360}{2\pi}  \quad \text{(deg)}

In case of an negative value here, we will simply add 360 degrees.

.. math::

  h = h + 360  \quad (\text{if } h < 0)

So, now we have the speed and heading of our example:

::

  V-EW: 0000001001 -> 9
  S-EW: 1
  V-NS: 0010100000 -> 160
  S-NS: 1

  V(we) = - (9 - 1) = -8
  V(sn) = - (160 - 1) = -159

  v = 159.20 (kn)
  h = 182.88 (deg)


Vertical Rate
*************

The direction of vertical movement of aircraft can be read from ``S(Vr)`` field,
in message bit-69:

::

  0 -> UP
  1 -> Down

The actual vertical rate ``Vr`` is the binary representation of the decimal
value in **feet/minute** (ft/min). In our example:

::

  Vr: 000001110 => 14
  S-Vr: 0 => Down / Descending

So we see a descending aircraft at 14 ft/min rate of descend.

The Vertical Rate Source (VrSrc) field determine whether if it is a measurement
in barometric pressure altitude or geometric altitude:

::

  0 ->  Baro-pressure altitude change rate 
  1 ->  Geometric altitude change rate 


Decoding message subtype 3 or 4
-------------------------------

Subtype 3 (subsonic) or 3 (supersonic), are broadcast when ground speed
information are NOT available, while airspeed is available. Subtype 3 or 4
messages are rare. As stated previously, we only received about 0.3% of those
messages from all the velocity reports. However, the information contains
airspeed of aircraft, which can be an interesting parameter in some
researches. The structure of the message is similar to previous one. Let's
take a close look at an example for decoding here.

Note: The following decoding only apply to Subtype 3 (subsonic).

::

  Message: 8DA05F219B06B6AF189400CBC33F

  |    | ICAO24 |      DATA      |  CRC   |
  |----|--------|----------------|--------|
  | 8D | A05F21 | 9B06B6AF189400 | CBC33F |

  Convert into binary:

  | HEADER                                 |  DATA                     
  |-------|-----|--------------------------|-------|-----|----|--------
  | DF    | CA  | ICAO24 ADDRESS           |  TC   | ST  | IC | RESV_A 
  |-------|-----|--------------------------|-------|-----|----|--------
  | 10001 | 101 | 101000000101111100100001 | 10011 | 011 | 0  | 0      

    ->   Data (cont.)                                                ->
    -> |-----|------|------------|------|------------|-------|------ ->
    -> | NAC | H-s  | Hdg        | AS-t | AS         | VrSrc | S-Vr  ->
    -> |-----|------|------------|------|------------|-------|------ ->
    -> | 000 | 1    | 1010110110 | 1    | 0101111000 | 1     | 1     ->

    ->   Data (cont.)                         | CRC                      |
    -> |-----------|--------|-------|---------|--------------------------|
    -> | Vr        | RESV_B | S-Dif | Dif     | CRC                      |
    -> |-----------|--------|-------|---------|--------------------------|
    -> | 000100101 | 00     | 0     | 0000000 | 110010111100001100111111 |

The detail bits representations are:

+-----------+---------+--------+----------------------------------+
| MSG Bits  | N bits  | Abbr   | Content                          |
+===========+=========+========+==================================+
| 33-37     | 5       | TC     | Type code                        |
+-----------+---------+--------+----------------------------------+
| 38-40     | 3       | ST     | Subtype                          |
+-----------+---------+--------+----------------------------------+
| 41        | 1       | IC     | Intent change flag               |
+-----------+---------+--------+----------------------------------+
| 42        | 1       | RESV_A | Reserved-A                       |
+-----------+---------+--------+----------------------------------+
| 43-45     | 3       | NAC    | Velocity uncertainty (NAC)       |
+-----------+---------+--------+----------------------------------+
| 46        | 1       | H-s    | Heading status                   |
+-----------+---------+--------+----------------------------------+
| 47-56     | 10      | Hdg    | Heading (proportion)             |
+-----------+---------+--------+----------------------------------+
| 57        | 1       | AS-t   | Airspeed Type                    |
+-----------+---------+--------+----------------------------------+
| 58-67     | 10      | AS     | Airspeed                         |
+-----------+---------+--------+----------------------------------+
| 68        | 1       | VrSrc  | Vertical rate source             |
+-----------+---------+--------+----------------------------------+
| 69        | 1       | S-Vr   | Vertical rate sign               |
+-----------+---------+--------+----------------------------------+
| 70-78     | 9       | Vr     | Vertical rate                    |
+-----------+---------+--------+----------------------------------+
| 79-80     | 2       | RESV_B | Reserved-B                       |
+-----------+---------+--------+----------------------------------+
| 81        | 1       | S-Dif  | Difference from baro alt, sign   |
+-----------+---------+--------+----------------------------------+
| 82-88     | 7       | Dif    | Difference from baro alt         |
+-----------+---------+--------+----------------------------------+

Heading
*******

``H-s`` makes the status of heading data:

::

  0 -> heading data not available
  1 -> heading data available

10-bits ``Hdg`` is the represent the proportion of the degrees of a full circle,
i.e. 360 degrees. (Note: 0000000000 - 1111111111 represents 0 - 1023 )

.. math::

  heading = Decimal(Hdg) / 1024 * 360^o

in our example  
::

  1010110110 -> 694
  heading = 694 / 1024 * 360 = 243.98 (degree)


Velocity (Airspeed)
*******************

To find out which type of the airspeed (TAS or IAS), first we need to look at
the ``AS-t`` field:

::

  0 -> Indicated Airspeed (IAS)
  1 -> True Airspeed (TAS)

And the the speed is simply a binary to decimal conversion of ``AS`` bits (in
knot). In our example:

::

  0101111000 -> 376 knot


Vertical Rate
*************

The vertical rate decoding remains the same as subtype 1 or 2 messages.