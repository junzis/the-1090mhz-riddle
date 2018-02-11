Uncertainty and accuracy
------------------------------------

NIC, NAC, NUC, and SIL, those acronyms do sound confusing. They are categorical numbers for the integrity,  accuracy, or uncertainties of the position measurements.

- ``NUCp``: Navigation Uncertainty Category - Position

  - Values: 0 - 9
  - Version 0, 1, and 2

- ``NUCr``: Navigation Uncertainty Category - Velocity (Rate)

  - Values: 0 - 4
  - Version 0

- ``NIC``: Navigation Integrity Category

  - Values: 0 - 11
  - Version 1 and 2

- ``NACp``: Navigation Accuracy Category - Position

  - Values: 0 - 11
  - Version 1 and 2

- ``NACv``: Navigation Accuracy Category - Velocity

  - Values: 0 - 4
  - Version 1 and 2

- ``SIL``: Surveillance Integrity Level

  - Values: 0 - 3
  - Version 1 and 2

For each category name, specific values are given corresponding to the numerical indicators. The relation of the category names and value names are:

- ``NUCp``:

  - Horizontal Protection Limit (``HPL``)
  - 95% Containment Radius - Horizontal (``RCu``)
  - 95% Containment Radius - Vertical (``RCv``)

- ``NUCr``:

  - 95% Horizontal Velocity Error (``HVE``)
  - 95% Vertical Velocity Error (``VVE``)

- ``NIC``:

  - Horizontal Radius of Containment (``RCu``)
  - Vertical Protection Limit (``VPL``)
    - a.k.a. Integrity Containment Region

- ``NACp``:

  - 95% horizontal accuracy bounds, Estimated Position Uncertainty (``EPU``)

    - a.k.a. Horizontal Figure of Merit (``HFOM``)

  - 95% vertical accuracy bounds, Vertical Estimated Position Uncertainty (``VEPU``)

    - a.k.a. Vertical Figure of Merit (``VFOM``)

- ``NACv``:

  - 95% horizontal accuracy bounds for velocity, Horizontal Figure of Merit (``HFOMr``)
  - 95% vertical accuracy bounds for velocity, Vertical Figure of Merit (``VFOMr``)


- ``SIL``:

  - Probability of exceeding Horizontal Radius of Containment ``RCu`` (``PE_RCu``)
  - Probability of exceeding Vertical Integrity Containment Region ``VPL`` (``PE_VPL``)


Depending on the ADS-B versions, the bits to uncover these values maybe different. We are going to address the uncertainty measures by ADS-B versions.

  To understand about these versions, first take a look at the `ADS-B version chapter <version.html>`__.

Version 0
~~~~~~~~~

NUCp
****

In ADS-B ``Version 0``, the accuracy is expressed as **Navigation Uncertainty Category - position** (``NUCp``). It is directly related (one-to-one relationship) with ``Type Code``, as follows:

+------+---+------------------+------------------------------------------------+-------------------+
|      |   | Surface position | Airborne position                              | Airborne position |
|      |   |                  | (Barometric altitude)                          | (GNSS height)     |
+------+---+----+----+----+---+---+----+----+----+----+----+----+----+----+----+------+------+-----+
| TC   | 0 | 5  | 6  | 7  | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 |  20  |  21  | 22  |
+------+---+----+----+----+---+---+----+----+----+----+----+----+----+----+----+------+------+-----+
| NUCp | 0 | 9  | 8  | 7  | 6 | 9 | 8  | 7  | 6  | 5  | 4  | 3  | 2  | 1  | 0  |  9   |  8   | 0   |
+------+---+----+----+----+---+---+----+----+----+----+----+----+----+----+----+------+------+-----+

Higher number of NUCp represents a higher confidence of in the position measurement (hence, a lower uncertainty). Horizontal Protection Limit (``HPL``) and Radius of containment for horizontal (``RCu``) are used to quantify the uncertainty.

For surface position (``TC=5-8``):

+----+------+--------------------+---------------------+
| TC | NUCp | HPL                | RCu                 |
+====+======+====================+=====================+
| 5  |  9   | < 7.5 m            | < 3 m               |
+----+------+--------------------+---------------------+
| 6  |  8   | < 25 m             | < 10 m              |
+----+------+--------------------+---------------------+
| 7  |  7   | < 0.1 NM (185 m)   | < 0.05 NM (93 m)    |
+----+------+--------------------+---------------------+
| 8  |  6   | > 0.1 NM (185 m)   | > 0.05 NM (93 m)    |
+----+------+--------------------+---------------------+

For airborne position with barometric altitude (``TC=9-18``):

+------+------+--------------------+---------------------+
|  TC  | NUCp | HPL                | RCu                 |
+======+======+====================+=====================+
|  9   |  9   | < 7.5 m            | < 3 m               |
+------+------+--------------------+---------------------+
|  10  |  8   | < 25 m             | < 10 m              |
+------+------+--------------------+---------------------+
|  11  |  7   | < 0.1 NM (185 m)   | < 0.05 NM (93 m)    |
+------+------+--------------------+---------------------+
|  12  |  6   | < 0.2 NM (370 m)   | < 0.1 NM (185 m)    |
+------+------+--------------------+---------------------+
|  13  |  5   | < 0.5 NM (926 m)   | < 0.25 NM (463 m)   |
+------+------+--------------------+---------------------+
|  14  |  4   | < 1 NM (1852 m)    | < 0.5 NM (926 m)    |
+------+------+--------------------+---------------------+
|  15  |  3   | < 2 NM (3704 m)    | < 1 NM (1852 m)     |
+------+------+--------------------+---------------------+
|  16  |  2   | < 10 NM (18520 m)  | < 5 NM (9260 m)     |
+------+------+--------------------+---------------------+
|  17  |  1   | < 20 NM (37040 m)  | < 10 NM (18520 m)   |
+------+------+--------------------+---------------------+
|  18  |  0   | > 20 NM (37040 m)  | > 10 NM (18520 m)   |
+------+------+--------------------+---------------------+

In the case of  airborne position with GNSS height (``TC=20-22``), ``HPL`` and ``RCu`` are defined slight differently. In addition, Radius of containment for vertical position (``RCv``) is added:

+------+------+----------+---------+---------+
|  TC  | NUCp | HPL      | RCu     | RCv     |
+======+======+==========+=========+=========+
|  20  |  9   | < 7.5 m  | < 3 m   | < 4 m   |
+------+------+----------+---------+---------+
|  21  |  8   | < 25 m   | < 10 m  | < 15 m  |
+------+------+----------+---------+---------+
|  22  |  0   | > 25 m   | > 10 m  | > 15 m  |
+------+------+----------+---------+---------+

NUCv
****

The **Navigation Uncertainty Category - velocity** (``NUCv``) it is used to indicate the uncertainty of the horizontal and vertical speeds. Related bits are located at the airborne velocity message, ``TC=19``, message bit 43-45 (or payload bit 11-13). It defines the 95% of the error in horizontal and vertical speed.

+------+-------------+------------------------+
| NUCp | HVE (95%)   | VVE (95%)              |
+======+=============+========================+
|  0   | unknown     | unknown                |
+------+-------------+------------------------+
|  1   | < 10 m/s    | < 15.2 m/s (50 pfs)    |
+------+-------------+------------------------+
|  2   | < 3 m/s     | < 4.5 m/s (15 fps)     |
+------+-------------+------------------------+
|  3   | < 1 m/s     | < 1.5 m/s (5 fps)      |
+------+-------------+------------------------+
|  4   | < 0.3 m/s   | < 0.46 m/s (1.5 fps)   |
+------+-------------+------------------------+



Version 1
~~~~~~~~~

NIC
***

In ADS-B Version 1, **Navigation Integrity Category** (``NIC``) is introduced to provide more levels of uncertainty definitions. The ``NUCp`` value is still kept, but has been moved to the new "operation status messages" (``TC=31``).

As for ``NIC``, in ``Type Code``: ``7`` and ``11``, two ``NIC`` levels present in each code. In order to distinguish these two different levels, a **NIC Supplement Bit** (``NICs``) is introduced in "operation status messages" ``TC=31``  (message bit 76 or payload bit 44). The relation of TC, NIC, and Rc are list in following tables.

For surface position (``TC=5-8``)

+------+--------+-------+-----------------------+
|  TC  | NICs   |  NIC  | Rc                    |
+======+========+=======+=======================+
|  5   | 0      |  11   | < 7.5 m               |
+------+--------+-------+-----------------------+
|  6   | 0      |  10   | < 25 m                |
+------+--------+-------+-----------------------+
|  7   | 1      |  9    | < 75 m                |
|      +--------+-------+-----------------------+
|      | 0      |  8    | < 0.1 NM (185 m)      |
+------+--------+-------+-----------------------+
|  8   | 0      |  0    | > 0.1 NM or Unknown   |
+------+--------+-------+-----------------------+

For airborne position with barometric altitude (``TC=9-18``):

+----+--------+-----+--------------------+----------+
| TC | NICs   | NIC | Rc                 | VPL      |
+====+========+=====+====================+==========+
| 9  | 0      | 11  | < 7.5 m            | < 11 m   |
+----+--------+-----+--------------------+----------+
| 10 | 0      | 10  | < 25 m             | < 37.5 m |
+----+--------+-----+--------------------+----------+
| 11 | 1      | 9   | < 75 m             | < 112 m  |
|    +--------+-----+--------------------+----------+
|    | 0      | 8   | < 0.1 NM (185 m)   |          |
+----+--------+-----+--------------------+----------+
| 12 | 0      | 7   | < 0.2 NM (370 m)   |          |
+----+--------+-----+--------------------+----------+
| 13 | 0      | 6   | < 0.5 NM (926 m)   |          |
|    +--------+     +--------------------+----------+
|    | 1      |     | < 0.6 NM (1111 m)  |          |
+----+--------+-----+--------------------+----------+
| 14 | 0      | 5   | < 1.0 NM (1852 m)  |          |
+----+--------+-----+--------------------+----------+
| 15 | 0      | 4   | < 2 NM (3704 m)    |          |
+----+--------+-----+--------------------+----------+
| 16 | 1      | 3   | < 4 NM (7408 m)    |          |
|    +--------+-----+--------------------+----------+
|    | 0      | 2   | < 8 NM (14.8 km)   |          |
+----+--------+-----+--------------------+----------+
| 17 | 0      | 1   | < 20 NM (37.0 km)  |          |
+----+--------+-----+--------------------+----------+
| 18 | 0      | 0   | > 20 NM or Unknown |          |
+----+--------+-----+--------------------+----------+

In the case of  airborne position with GNSS height (``TC=20-22``), ``Rc`` is defined slight differently:

+------+------+----------+----------+
|  TC  | NIC  | Rc       | VPL      |
+======+======+==========+==========+
|  20  | 11   | < 7.5 m  | < 11 m   |
+------+------+----------+----------+
|  21  | 10   | < 25 m   | < 37.5 m |
+------+------+----------+----------+
|  22  | 0    | > 25 m   | > 112 m  |
+------+------+----------+----------+


NACp
****

In addition to ``NIC``, **Navigation Accuracy Category - Position** (``NACp``) is also introduced int ADS-B ``Version 1``. ``NACp`` can be found in:

- ``TC=29``, target state and status message, message bit 72-75 (or payload bit 40-43)
- ``TC=31``, operational status message, message bit 77-80 (or payload bit 45-48)


With ``NACp``, one can find out the 95% horizontal and vertical accuracy bounds (``EPU`` and ``VEPU``, or ``HFOM`` and ``VFOM``). ``NACp`` and ``NIC`` usually share the same value, and their values are closely related.

.. math::

  \mathrm{EPU} &\approx \mathrm{Rc} / 2.5   \qquad  \mathrm{NAC, NIC} \ge 9 \\
  \mathrm{EPU} &\approx \mathrm{Rc} / 2.0  \qquad  \mathrm{NAC, NIC} \lt 9

For ADS-B, ``NACp`` is also indicated in the operational status messages (``TC=31``). ``NACp`` and corresponding ``EPU``/``VEPU`` are:

+------+--------------------+-------------+
| NACp | HFU (HFOM)         | VEPU (VFOM) |
+======+====================+=============+
|  11  | < 3 m              | < 4 m       |
+------+--------------------+-------------+
|  10  | < 10 m             | < 15 m      |
+------+--------------------+-------------+
|  9   | < 30 m             | < 45 m      |
+------+--------------------+-------------+
|  8   | < 0.05 NM (93 m)   |             |
+------+--------------------+-------------+
|  7   | < 0.1 NM (185 m)   |             |
+------+--------------------+-------------+
|  6   | < 0.3 NM (556 m)   |             |
+------+--------------------+-------------+
|  5   | < 0.5 NM (926 m)   |             |
+------+--------------------+-------------+
|  4   | < 1.0 NM (1852 m)  |             |
+------+--------------------+-------------+
|  3   | < 2 NM (3704 m)    |             |
+------+--------------------+-------------+
|  2   | < 4 NM (7408 m)    |             |
+------+--------------------+-------------+
|  1   | < 10 NM (18520 km) |             |
+------+--------------------+-------------+
|  0   | > 10 NM or Unknown |             |
+------+--------------------+-------------+


NACv
****

The **Navigation Accuracy Category - Velocity** (``NACv``) is introduced in ``Version 1`` to replace the ``NUCv`` from ``Version 0``. The bits are located at the same location and have the same definitions of values. It can be found in airborne velocity message, ``TC=19``, message bit 43-45 (or payload bit 11-13). It defines the 95% of the error in horizontal and vertical speed.

+------+-------------+------------------------+
| NAVc | HFOMr (95%) | VFOMr (95%)            |
+======+=============+========================+
|  0   | unknown     | unknown                |
+------+-------------+------------------------+
|  1   | < 10 m/s    | < 15.2 m/s (50 pfs)    |
+------+-------------+------------------------+
|  2   | < 3 m/s     | < 4.5 m/s (15 fps)     |
+------+-------------+------------------------+
|  3   | < 1 m/s     | < 1.5 m/s (5 fps)      |
+------+-------------+------------------------+
|  4   | < 0.3 m/s   | < 0.46 m/s (1.5 fps)   |
+------+-------------+------------------------+


SIL
***

On the other hand, **Surveillance Integrity Level** (``SIL``) is introduced in ``Version 1`` to indicate the probability of measurement exceeding the containment radius horizontally (``PE_RCu``) and vertically (``PE_VPL``).

``SIL`` value can be found in two different locations:

- ``TC=29``, target state and status message, message bit 77-78 (or payload bit 45-46)
- ``TC=31``, operational status message, message bit 83-84 (or payload bit 51-52)

The definitions are as follows:

+-----+--------------------+--------------------+
| SIL | PE_RCu             | PE_VPL             |
+=====+====================+====================+
| 0   | unknown            | unknown            |
+-----+--------------------+--------------------+
| 1   | < 1 x 10 :sup:`-3` | < 1 x 10 :sup:`-3` |
+-----+--------------------+--------------------+
| 2   | < 1 x 10 :sup:`-5` | < 1 x 10 :sup:`-5` |
+-----+--------------------+--------------------+
| 3   | < 1 x 10 :sup:`-7` | < 2 x 10 :sup:`-7` |
+-----+--------------------+--------------------+

The unit for ``PE_RCu`` and ``PE_VPL`` is  per hour or per sample.



Version 2
~~~~~~~~~

NIC
***

In ADS-B ``Version 2``, levels of accuracies are further divided by two addition ``NIC`` supplement bits. In ``Version 2``, we call them NIC Supplement Bit A (``NICa``),  NIC Supplement Bit B (``NICb``), and  NIC Supplement Bit C (``NICc``).

- ``NICa`` is in the same location as in ADS-B ``Version 1``, which is located in the operational status message ``TC=31`` (message bit 76 or payload bit 44).
- ``NICb`` is located in the airborne position message (``TC=9-18``, message bit 40 or payload bit 8), where the "single antenna flag" was located in previous ADS-B versions.
- ``NICc`` is also located in the operational status message ``TC=31`` (message bit 52 or payload bit 20).

Gather the NIC supplement bits, together with the ``Type Code``, accuracies are defined.


For surface possible message (``TC=5-8``), using ``TC``, ``NICa``, and ``NICc``:

+------+------+------+-------+-----------------------+
|  TC  | NICa | NICc |  NIC  | Rc                    |
+======+======+======+=======+=======================+
|  5   | 0    | 0    |  11   | < 7.5 m               |
+------+------+------+-------+-----------------------+
|  6   | 0    | 0    |  10   | < 25 m                |
+------+------+------+-------+-----------------------+
|  7   | 1    | 0    |  9    | < 75 m                |
|      +------+------+-------+-----------------------+
|      | 0    | 0    |  8    | < 0.1 NM (185 m)      |
+------+------+------+-------+-----------------------+
|  8   | 1    | 1    |  7    | < 0.2 NM (370 m)      |
|      +------+------+-------+-----------------------+
|      | 1    | 0    |  6    | < 0.3 NM (556 m)      |
|      +------+------+       +-----------------------+
|      | 0    | 1    |       | < 0.6 NM (1111 m)     |
|      +------+------+-------+-----------------------+
|      | 0    | 0    |  0    | > 0.6 NM or Unknown   |
+------+------+------+-------+-----------------------+


For airborne possible message (``TC=9-18``), using ``TC``, ``NICa``, and ``NICc``:

+----+------+------+-----+-----------------------+
| TC | NICa | NICb | NIC | Rc                    |
+====+======+======+=====+=======================+
| 9  | 0    | 0    | 11  | < 7.5 m               |
+----+------+------+-----+-----------------------+
| 10 | 0    | 0    | 10  | < 25 m                |
+----+------+------+-----+-----------------------+
| 11 | 1    | 1    | 9   | < 75 m                |
|    +------+------+-----+-----------------------+
|    | 0    | 0    | 8   | < 0.1 NM (185 m)      |
+----+------+------+-----+-----------------------+
| 12 | 0    | 0    | 7   | < 0.2 NM (370 m)      |
+----+------+------+-----+-----------------------+
| 13 | 0    | 1    | 6   | < 0.3 NM (556 m)      |
|    +------+------+     +-----------------------+
|    | 0    | 0    |     | < 0.5 NM (926 m)      |
|    +------+------+     +-----------------------+
|    | 1    | 1    |     | < 0.6 NM (1111 m)     |
+----+------+------+-----+-----------------------+
| 14 | 0    | 0    | 5   | < 1.0 NM (1852 m)     |
+----+------+------+-----+-----------------------+
| 15 | 0    | 0    | 4   | < 2 NM (3704 m)       |
+----+------+------+-----+-----------------------+
| 16 | 1    | 1    | 3   | < 4 NM (7408 m)       |
|    +------+------+-----+-----------------------+
|    | 0    | 0    | 2   | < 8 NM (14.8 km)      |
+----+------+------+-----+-----------------------+
| 17 | 0    | 0    | 1   | < 20 NM (37.0 km)     |
+----+------+------+-----+-----------------------+
| 18 | 0    | 0    | 0   | > 20 NM or Unknown    |
+----+------+------+-----+-----------------------+

In the case of  airborne position with GNSS height (``TC=20-22``), the table remains the same as previous version.

+------+------+----------+
|  TC  | NIC  | Rc       |
+======+======+==========+
|  20  | 11   | < 7.5 m  |
+------+------+----------+
|  21  | 10   | < 25 m   |
+------+------+----------+
|  22  | 0    | > 25 m   |
+------+------+----------+

NACp
****

NACp in ``Version 2`` remains the same as in ``Version 1``.


NACv
****

NACv in ``Version 2`` remains the same as in ``Version 1``.


SIL
***

In ``Version 2``, an additional **SIL supplement bit** (``SILs``) is introduced to distinguish if the value is based on per flight hour or per sample.

The same as in ``Version 1``, ``SIL`` value can be found in two different locations:

- ``TC=29``, target state and status message, message bit 77-78 (or payload bit 45-46)
- ``TC=31``, operational status message, message bit 83-84 (or payload bit 51-52)

``SILs`` bit can also be found at two different locations:

- ``TC=29``, target state and status message, message bit 40 (or payload bit 8)
- ``TC=31``, operational status message, message bit 87 (or payload bit 55)
- ``SILs=0``: probability is "per hour" based
- ``SILs=1``: probability is "per sample" based

The same values from ``Version 1`` are kept:

+-----+--------------------+--------------------+
| SIL | PE_RCu             | PE_VPL             |
+=====+====================+====================+
| 0   | unknown            | unknown            |
+-----+--------------------+--------------------+
| 1   | < 1 x 10 :sup:`-3` | < 1 x 10 :sup:`-3` |
+-----+--------------------+--------------------+
| 2   | < 1 x 10 :sup:`-5` | < 1 x 10 :sup:`-5` |
+-----+--------------------+--------------------+
| 3   | < 1 x 10 :sup:`-7` | < 2 x 10 :sup:`-7` |
+-----+--------------------+--------------------+
