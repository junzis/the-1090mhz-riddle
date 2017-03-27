Airborne Velocity
=================

There are two different types of messages for velocities, determined by  3-bit subtype in the message. With subtype 1 and 2, surface velocity  (ground speed) is reported. And in subtype 3 and 4, aircraft airspeed are reported.

Type 2 and 4 are for supersonic aircraft. So, before we have another commercial supersonic aircraft flying around, you won't see any of those types.

In real world, very few of subtype 3 messages are reported. In our setup, we only received **0.3%** of these message with regard to subtype 1.

An aircraft velocity message has ``DF: 17``, ``TC: 19``. and the subtype code are represented in bits 38 to 40. Now, we can decode those messages.


Subtype 1 (Ground Speed)
------------------------

Subtype 1 (subsonic, ground speed), are broadcast when ground velocity information are available. The aircraft velocity contains speed and heading information. The speed and heading are also decomposed into North-South, and East-West components.

For example, following message is received:

::

  Message: 8D485020994409940838175B284F

  |    | ICAO24 |      DATA      |  CRC   |
  |----|--------|----------------|--------|
  | 8D | 485020 | 99440994083817 | 5B284F |

  Convert DATA [99440994083817] into binary:

  |-------|-----|----|--------|-----|------|------------|------|------------|-------|------|-----------|--------|-------|---------|
  |  TC   | ST  | IC | RESV_A | NAC | S-EW | V-EW       | S-NS | V-NS       | VrSrc | S-Vr | Vr        | RESV_B | S_Dif | Dif     |
  |-------|-----|----|--------|-----|------|------------|------|------------|-------|------|-----------|--------|-------|---------|
  | 10011 | 001 | 0  | 1      | 000 | 1    | 0000001001 | 1    | 0010100000 | 0     | 1    | 000001110 | 00     | 0     | 0010111 |



There are quite a few parameters in the the velocity message. From left to rights, the number of bits indicate the following contents:

+-----------+-----------+------+--------+------------------------------+
| MSG Bits  | DATA Bits | Len  | Abbr   | Content                      |
+===========+===========+======+========+==============================+
| 33-37     | 1-5       | 5    | TC     | Type code                    |
+-----------+-----------+------+--------+------------------------------+
| 38-40     | 6-8       | 3    | ST     | Subtype                      |
+-----------+-----------+------+--------+------------------------------+
| 41        | 9         | 1    | IC     | Intent change flag           |
+-----------+-----------+------+--------+------------------------------+
| 42        | 10        | 1    | RESV_A | Reserved-A                   |
+-----------+-----------+------+--------+------------------------------+
| 43-45     | 11-13     | 3    | NAC    | Velocity uncertainty (NAC)   |
+-----------+-----------+------+--------+------------------------------+
| 46        | 14        | 1    | S_ew   | East-West velocity sign      |
+-----------+-----------+------+--------+------------------------------+
| 47-56     | 15-24     | 10   | V_ew   | East-West velocity           |
+-----------+-----------+------+--------+------------------------------+
| 57        | 25        | 1    | S_ns   | North-South velocity sign    |
+-----------+-----------+------+--------+------------------------------+
| 58-67     | 26-35     | 10   | V_ns   | North-South velocity         |
+-----------+-----------+------+--------+------------------------------+
| 68        | 36        | 1    | VrSrc  | Vertical rate source         |
+-----------+-----------+------+--------+------------------------------+
| 69        | 37        | 1    | S_vr   | Vertical rate sign           |
+-----------+-----------+------+--------+------------------------------+
| 70-78     | 38-46     | 9    | Vr     | Vertical rate                |
+-----------+-----------+------+--------+------------------------------+
| 79-80     | 47-48     | 2    | RESV_B | Reserved-B                   |
+-----------+-----------+------+--------+------------------------------+
| 81        | 49        | 1    | S_Dif  | Diff from baro alt, sign     |
+-----------+-----------+------+--------+------------------------------+
| 82-88     | 50-66     | 7    | Dif    | Diff from baro alt           |
+-----------+-----------+------+--------+------------------------------+

Horizontal Velocity
*******************

For calculating the horizontal speed and heading we need four values, East-West Velocity ``V_ew``, East-West Velocity Sign ``S_ew``, North-South Velocity ``V_ns``, North-South Velocity Sign ``S_ns``. And pay attention on the directions (signs) in the calculation.

::

  S_ns:
      1 -> flying North to South
      0 -> flying South to North
  S_ew:
      1 -> flying East to West
      0 -> flying West to East

The Speed (v) and heading (h) with unit `knot` and `degree` can be computed as follows:

.. math::

  V_{we} =
  \begin{cases}
   -1 \cdot (V_{ew} - 1)    & \text{if } s_{ew} = 1 \\
   V_{ew} - 1         & \text{if } s_{ew} = 0
  \end{cases}

.. math::

  V_{sn} =
  \begin{cases}
   -1 \cdot (V_{ns} - 1)    & \text{if } s_{ns} = 1 \\
   V_{ns} - 1         & \text{if } s_{ns} = 0
  \end{cases}

.. math::

  v = \sqrt{V_{we}^{2} + V_{sn}^{2}}

.. math::

  h = arctan \left( \frac{V_{we}}{V_{sn}} \right) \cdot \frac{360}{2\pi}  \quad \text{(deg)}

In case of an negative value here, we will simply add 360 degrees.

.. math::

  h = h + 360  \quad (\text{if } h < 0)

So, now we have the speed and heading of our example:

::

  V-EW: 0000001001 -> 9
  S-EW: 1
  V-NS: 0010100000 -> 160
  S-NS: 1

  V_{we} = - (9 - 1) = -8
  V_{sn} = - (160 - 1) = -159

  v = 159.20 (kt)
  h = 2.88 (deg)


Vertical Rate
*************

The direction of vertical movement of aircraft can be read from ``S_vr`` field, in message bit-69:

::

  0 -> UP
  1 -> Down

The actual vertical rate ``Vr`` is the value of bits 70-78, minus 1, and then multiplied by 64 in **feet/minute** (ft/min). In our example:

::

  Vr-bits: 000001110 = 14
  Vr: (14 - 1) x 64 => 832 fpm
  S-Vr: 0 => Down / Descending


So we see a descending aircraft at 832 ft/min rate of descend.

The Vertical Rate Source (VrSrc) field determine whether if it is a measurement in barometric pressure altitude or geometric altitude:

::

  0 ->  Baro-pressure altitude change rate
  1 ->  Geometric altitude change rate


Subtype 3 (Airspeed)
-------------------------

Subtype 3 (subsonic, aripseed), are broadcast when ground speed information are NOT available, while airspeed is available. The structure of the message is similar to previous one. Let's take a close look at an example for decoding here.

::

  Message: 8DA05F219B06B6AF189400CBC33F

  |    | ICAO24 |      DATA      |  CRC   |
  |----|--------|----------------|--------|
  | 8D | A05F21 | 9B06B6AF189400 | CBC33F |

  Convert DATA [9B06B6AF189400] into binary:

  |-------|-----|----|--------|-----|------|------------|------|------------|-------|------|-----------|--------|-------|---------|
  |  TC   | ST  | IC | RESV_A | NAC | S_hdg| Hdg        | AS-t | AS         | VrSrc | S-Vr | Vr        | RESV_B | S_Dif | Dif     |
  |-------|-----|----|--------|-----|------|------------|------|------------|-------|------|-----------|--------|-------|---------|
  | 10011 | 011 | 0  | 0      | 000 | 1    | 1010110110 | 1    | 0101111000 | 1     | 1    | 000100101 | 00     | 0     | 0000000 |

The detail bits representations are:

+-----------+-----------+------+--------+----------------------------------+
| MSG Bits  | DATA Bits | Len  | Abbr   | Content                          |
+===========+===========+======+========+==================================+
| 33-37     | 1-5       | 5    | TC     | Type code                        |
+-----------+-----------+------+--------+----------------------------------+
| 38-40     | 6-8       | 3    | ST     | Subtype                          |
+-----------+-----------+------+--------+----------------------------------+
| 41        | 9         | 1    | IC     | Intent change flag               |
+-----------+-----------+------+--------+----------------------------------+
| 42        | 10        | 1    | RESV_A | Reserved-A                       |
+-----------+-----------+------+--------+----------------------------------+
| 43-45     | 11-13     | 3    | NAC    | Velocity uncertainty (NAC)       |
+-----------+-----------+------+--------+----------------------------------+
| 46        | 14        | 1    | S_hdg  | Heading status                   |
+-----------+-----------+------+--------+----------------------------------+
| 47-56     | 15-24     | 10   | Hdg    | Heading (proportion)             |
+-----------+-----------+------+--------+----------------------------------+
| 57        | 25        | 1    | AS-t   | Airspeed Type                    |
+-----------+-----------+------+--------+----------------------------------+
| 58-67     | 26-35     | 10   | AS     | Airspeed                         |
+-----------+-----------+------+--------+----------------------------------+
| 68        | 36        | 1    | VrSrc  | Vertical rate source             |
+-----------+-----------+------+--------+----------------------------------+
| 69        | 37        | 1    | S_vr   | Vertical rate sign               |
+-----------+-----------+------+--------+----------------------------------+
| 70-78     | 38-46     | 9    | Vr     | Vertical rate                    |
+-----------+-----------+------+--------+----------------------------------+
| 79-80     | 47-48     | 2    | RESV_B | Reserved-B                       |
+-----------+-----------+------+--------+----------------------------------+
| 81        | 49        | 1    | S_Dif  | Difference from baro alt, sign   |
+-----------+-----------+------+--------+----------------------------------+
| 82-88     | 50-66     | 7    | Dif    | Difference from baro alt         |
+-----------+-----------+------+--------+----------------------------------+

Heading
*******

``S_hdg makes the status of heading data:

::

  0 -> heading data not available
  1 -> heading data available

10-bits ``Hdg`` is the represent the proportion of the degrees of a full circle, i.e. 360 degrees. (Note: 0000000000 - 1111111111 represents 0 - 1023 )

.. math::

  heading = Decimal(Hdg) / 1024 * 360^o

in our example
::

  1010110110 -> 694
  heading = 694 / 1024 * 360 = 243.98 (degree)


Velocity (Airspeed)
*******************

To find out which type of the airspeed (TAS or IAS), first we need to look at the ``AS-t`` field:

::

  0 -> Indicated Airspeed (IAS)
  1 -> True Airspeed (TAS)

And the the speed is simply a binary to decimal conversion of ``AS`` bits (in knot). In our example:

::

  0101111000 -> 376 knot


Vertical Rate
*************

The vertical rate decoding remains the same as subtype 1.
