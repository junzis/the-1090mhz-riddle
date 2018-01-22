EHS (Mode-S Enhanced Surveillance)
==================================

Let's hack into the EHS messaged too! more information on aircraft air speeds.


The Mode-S Enhanced Surveillance (EHS) provides air traffic controller more information that what is included in the ADS-B (a.k.a Mode-S Elementary Surveillance). It responds to ATC Secondary Surveillance Radar, and broadcast specific parameters non-independently. Hence it is only available in the area where ATC presents.

There are quite a few very interesting data contained within various types of the EHS messages. Such as: airspeeds (IAS, TAS, Mach), roll angles, track angles, track angle rates, selected altitude, magnetic heading, vertical rate, etc..

There are a few challenges to decode those information:
 - Which aircraft does one message come from?
 - What is the type of one message (a.k.a. which BDS code) most likely to be?
 - How confident is the information that has been decoded?

.. Example:
    40: A0001838CA380031440000F24177
    50: A00015B7801DBB3BE00CF7B8856D
    60: A0000294B409D117224C47609A81


This part of the book covers only a selected common type of EHS messages. For a complete Python implementation:
https://github.com/junzis/pyModeS/blob/master/pyModeS/ehs.py


.. toctree::
    :maxdepth: 1

    introduction
    bds20-identification
    bds40-intention
    bds50-track-n-turn
    bds60-airspeed
