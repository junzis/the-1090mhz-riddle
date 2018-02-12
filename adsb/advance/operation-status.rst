Aircraft Operation Status
=========================

Operation status message is introduced since the ``Version 1`` of ADS-B. And there are also slightly differences in the structure of Aircraft Operation Messages between Version 1 and 2.

  To understand about these versions, first take a look at the `ADS-B version chapter <version.html>`__.

The operation status is transmitted with ``Type Code`` 31 (``TC=31``). The structure of the message (in ``Version 1``) is laid out as follows:

.. code-block:: text

  +----------------------------------------+------+------+------+
  | FIELD                                  | MSG  | MB   |N-BITS|
  +========================================+======+======+======+
  | Downlink Format = 17                   |  1   |      |  8   |
  |                                        |  8   |      |      |
  +----------------------------------------+------+------+------+
  | ICAO Address                           |  9   |      |  24  |
  |                                        |  32  |      |      |
  +----------------------------------------+------+------+------+
  | Type Code = 31                         |  33  |  1   |  5   |
  |                                        |  37  |  5   |      |
  +----------------------------------------+------+------+------+
  | Subtype Code                           |  38  |  6   |  3   |
  |                                        |      |      |      |
  |  - 0: airborne                         |      |      |      |
  |  - 1: surface                          |      |      |      |
  |  - 2-7: reserved                       |  40  |  8   |      |
  +-------------------+--------------------+------+------+------+
  |                   |                    |  41  |  9   | 16   |
  |  Airborne         |  Surface           |      |      |      |
  |  capacity class   |  capacity class    |      |      |      |
  |  codes            |  codes             |      |      |      |
  |                   |                    |  52  |  20  |      |
  |                   +--------------------+------+------+------+
  |                   |                    |  53  |  21  | (4)  |
  |                   |  Length/width      |      |      |      |
  |                   |  codes             |      |      |      |
  |                   |                    |  56  |  24  |      |
  +-------------------+--------------------+------+------+------+
  | Operational mode code                  |  57  |  25  |  16  |
  |                                        |      |      |      |
  |                                        |      |      |      |
  |                                        |  72  |  40  |      |
  +----------------------------------------+------+------+------+
  | ADS-B version number                   |  73  |  41  |  3   |
  |                                        |  75  |  43  |      |
  +----------------------------------------+------+------+------+
  | NIC supplement bit                     |  76  |  44  |  1   |
  +----------------------------------------+------+------+------+
  | NACp: Navigation accuracy category     |  77  |  45  |  4   |
  |        - position                      |  80  |  48  |      |
  +-------------------+--------------------+------+------+------+
  | BAQ = 0           | Reserved           |  81  |  49  |  2   |
  |                   |                    |  82  |  50  |      |
  +-------------------+--------------------+------+------+------+
  | SIL: Surveillance integrity level      |  83  |  51  |  2   |
  |                                        |  84  |  52  |      |
  +-------------------+--------------------+------+------+------+
  | NIC-BARO          | TRK/HDG            |  85  |  53  |  1   |
  +-------------------+--------------------+------+------+------+
  | HRD                                    |  86  |  54  |  1   |
  +----------------------------------------+------+------+------+
  | Reserved                               |  87  |  55  |  2   |
  |                                        |  88  |  56  |      |
  +----------------------------------------+------+------+------+


Acronyms:

- BAQ: Barometric Altitude Quality (always set to zero for airborne message ``subtype=1``)

- HRD: Horizontal Reference Direction

  - 0: True North
  - 1: Magnetic North


In ADS-B ``Version 2``, most part of the message remains the same, we will only address the second half of the message, where the changes have been made.

.. code-block:: text

  +----------------------------------------+------+------+------+
  | FIELD                                  | MSG  | MB   |N-BITS|
  +========================================+======+======+======+
  | Airborne          | Surface            |  57  |  25  |  16  |
  | operational       | operational        |      |      |      |
  | mode code         | mode code          |      |      |      |
  |                   |                    |  72  |  40  |      |
  +-------------------+--------------------+------+------+------+
  | ADS-B version number                   |  73  |  41  |  3   |
  |                                        |  75  |  43  |      |
  +----------------------------------------+------+------+------+
  | NIC supplement bit - A                 |  76  |  44  |  1   |
  +----------------------------------------+------+------+------+
  | NACp: Navigation accuracy category     |  77  |  45  |  4   |
  |       - position                       |      |      |      |
  |                                        |  80  |  48  |      |
  +-------------------+--------------------+------+------+------+
  | GVA               | Reserved           |  81  |  49  |  2   |
  |                   |                    |  82  |  50  |      |
  +-------------------+--------------------+------+------+------+
  | SIL: Surveillance integrity level      |  83  |  51  |  2   |
  |                                        |  84  |  52  |      |
  +-------------------+--------------------+------+------+------+
  | NIC-BARO          | TRK/HDG            |  85  |  53  |  1   |
  +-------------------+--------------------+------+------+------+
  | HRD                                    |  86  |  54  |  1   |
  +----------------------------------------+------+------+------+
  | SIL supplement bit                     |  87  |  55  |  1   |
  +----------------------------------------+------+------+------+
  | Reserved                               |  88  |  56  |  1   |
  +----------------------------------------+------+------+------+

Acronyms:

- GVA: Geometric Vertical Accuracy - GNSS position source, 95% vertical figure of merit (``VFOM``)

  - 0: unknown or > 150 meters
  - 1: < 150 meters
  - 2: < 45 meters
  - 3: reserved

- SIL, NIC, NAC are also related to measurement uncertainty or accuracy.

  - A lot or more details are given in `the uncertainty chapter <uncertainty.html>`__.
