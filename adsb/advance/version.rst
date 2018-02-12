ADS-B versions
--------------

In this advanced chapter, we are going to looking into different versions and evolution of the ADS-B.

Since the beginning of ADS-B, there have been three different versions (to my knowledge) implemented. The major reason for these update is to enable more information (types of data) in ADS-B. Documentations on these versions and differences are quite far from user friendly. They are always presented in a very scattered fashion. Even the official ``ICAO_9871`` document is confusing to read. I am going to try my best to put the pieces together in this chapter.

There are three versions implemented so far, starting from Version 0, then  Version 1 around 2008 and Version 2 around 2012. Major changes in Version 1 and Version 2 are listed as follows:

From ``Version 0`` to ``Version 1``:

- Added ``Type Code`` 28, 19, and 31 messages

  - ``TC=28``: Aircraft status - Emergency/priority status and ACAS RA Broadcast
  - ``TC=29``: Target state and status
  - ``TC=31``: Operational status

- Introduced the "Navigation integrity category (``NIC``)" and "Surveillance integrity level (``SIL``)" in addition to the "Navigation accuracy category (``NAC``)" from the ``Version 0``

  - Type Code and an NIC Supplement bit (``NICs``) is used to define the NIC
  - NIC Supplement bit included in ``TC=31`` messages

- The ADS-B version number is now indicated in operation status message ``TC=31``

From ``Version 1`` to ``Version 2``:

- Re-defined the structure and content of ``TC=28``, ``TC=29``, and ``TC=31`` messages.
- Introduced two additional NIC Supplement Bit
- ``NICa`` is defined in operational status messages (``TC=31``)
- ``NICb`` is defined in airborne position messages (``TC=9-18``)
- ``NICc`` is defined in operational status messages (``TC=31``)
- Introduced an additional "Horizontal Containment Radius (``Rc``)" within ``NIC=6`` / ``TC=13``


Identify the ADS-B Version
~~~~~~~~~~~~~~~~~~~~~~~~~~

There are two steps to check the ADS-B version, this is due to the fact that ADS-B ``Version 0`` is not included in any message.

1. Step 1: Check whether an aircraft is broadcasting ADS-B messages with ``TC=31`` at all. If no message is ever reported, it is safe to assume that the version is ``Version 0``

2. Step 2: If messages with ``TC=31`` are received, check the version numbers located in the 41-43 bit of the payload (or 73-75 bit of the message).

After identifying the right ADS-B version for an aircraft (which doesn't change often), one can decode related ``TC=28``, ``TC=29``, and ``TC=31`` messages accordingly.
