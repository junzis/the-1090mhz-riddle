Decode Airborne Velocity
========================

Aircraft velocity are composed by speed and heading information.

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

We can confirm the DF=17 and TC=19. Good to decode the velocity. Next, let's extract the DATA frame part:
::

  HEX: 99454F9E0004A7

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
