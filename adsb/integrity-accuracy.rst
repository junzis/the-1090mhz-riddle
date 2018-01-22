Integrity and Accuracy
----------------------

NIC, NAC, NUC, and SIL, those acronyms do sound confusing. They are measurement
for the integrity,  accuracy, or uncertainties of the position measurement from
GPS unit.

- NIC - Navigation Integrity Category
- NUC - Navigation Uncertainty Category
- NAC - Navigation Accuracy Category
- SIL - Surveillance/Source Integrity Level


Two of those values are more interesting for us, ``NICp`` and ``NACv``,
represent the position integrity and velocity accuracy respectively.

Before dive into decoding and interpolation, let's introduce two parameters:

- ``Rc``: Horizontal Containment Radius Limit, interpolated from ``NICp`` number
- ``HFOM``: Horizontal Figure of Merit, interpolated from ``NACv`` number


NIC and Rc
~~~~~~~~~~~

Bring back the message from position decoding previously:

::

  MSG: 8D40621D58C382D690C8AC2863A7

  |    | ICAO24 |      DATA      |        |
  |----|--------|----------------|--------|
  | 8D | 40621D | 58C382D690C8AC | 2863A7 |



Convert both messages to binary strings:
::

  | DF    | CA  | ICAO24 ADDRESS           | DATA                                   ->
  |                                        | TC    | SS | SBnic | Altitude     | T  ->
  |-------|-----|--------------------------|-------|----|-------|--------------|--- ->
  | 10001 | 101 | 010000000110001000011101 | 01011 | 00 | 0     | 110000111000 | 0  ->

    ->  Data (cont.)                                   | CRC                      |
    -> | CPR-F | CPR Latitude      | CPR Longitude     |                          |
    -> |-------|-------------------|-------------------|--------------------------|
    -> | 0     | 10110101101001000 | 01100100010101100 | 001010000110001110100111 |


Not the \*2 field (``bit-40``), where we have the NIC Supplement-B (S[B]) in
combination with TC number, we are able to determine the NIC value.

The relation of TC, NIC, and Rc are as follow:

+----+-------+-----+-----------------------+
| TC | SBnic | NIC | Rc                    |
+====+=======+=====+=======================+
| 9  | 0     | 11  | < 7.5 m               |
+----+-------+-----+-----------------------+
| 10 | 0     | 10  | < 25 m                |
+----+-------+-----+-----------------------+
| 11 | 1     | 9   | < 74 m                |
+    +-------+-----+-----------------------+
|    | 0     | 8   | < 0.1 NM (185 m)      |
+----+-------+-----+-----------------------+
| 12 | 0     | 7   | < 0.2 NM (370 m)      |
+----+-------+-----+-----------------------+
| 13 | 1 *   | 6   | < 0.3 NM (556 m)      |
+    +-------+     +-----------------------+
|    | 0     |     | < 0.5 NM (925 m)      |
+    +-------+     +-----------------------+
|    | 1 **  |     | < 0.6 NM (1111 m)     |
+----+-------+-----+-----------------------+
| 14 | 0     | 5   | < 1.0 NM (1852 m)     |
+----+-------+-----+-----------------------+
| 15 | 0     | 4   | < 2 NM (3704 m)       |
+----+-------+-----+-----------------------+
| 16 | 1     | 3   | < 4 NM (7408 m)       |
+    +-------+-----+-----------------------+
|    | 0     | 2   | < 8 NM (14.8 km)      |
+----+-------+-----+-----------------------+
| 17 | 0     | 1   | < 20 NM (37.0 km)     |
+----+-------+-----+-----------------------+
| 18 | 0     | 0   | > 20 NM or Unknown    |
+----+-------+-----+-----------------------+

- \* NIC Supplement-A = 0
- \*\* NIC Supplement-A = 1

In our example:

::

  TC -> 11
  SBnic -> 0

  We have:
    NIC -> 8

So, what happened to the NIC Supplement-A and C? Those two bits are broadcast in
Aircraft Operational Status Message (TC=31, see Introduction page). For Surface
Position Message, you will need the combination of A and C to determine the NIC
number (note: Rc values are different from Airborne Position Messages). However,
with Supplement-B bit we are already  able to decode the NIC and Rc for airborne
positions.


NAC and HFOM
~~~~~~~~~~~~

NAC is reported in the Airborne Velocity Message.
