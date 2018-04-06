EHS (Mode-S Enhanced Surveillance)
==================================

Let's hack into the EHS messaged too! More information on aircraft air speeds.


The Mode-S Enhanced Surveillance (EHS) provides to Air Traffic Control (ATC) more information than what is included in the Mode-S Elementary Surveillance (ELS).

There are quite a few very interesting data contained within various types of the EHS messages. Such as: airspeeds (IAS, TAS, Mach), roll angles, track angles, track angle rates, selected altitude, magnetic heading, vertical rate, etc.

There are a few challenges to decode this information:
 - Which aircraft does one message come from?
 - What is the type of one message (aka which BDS code) most likely to be?
 - How reliable is the information that has been decoded?

.. Example:
    40: A0001838CA380031440000F24177
    50: A00015B7801DBB3BE00CF7B8856D
    60: A0000294B409D117224C47609A81


This part of the book covers only a selected common types of EHS messages. For a complete Python implementation:
https://github.com/junzis/pyModeS/blob/master/pyModeS/ehs.py


--------------------------------

**Chapter structure:**

.. toctree::
    :maxdepth: 2

    ehs/introduction
    ehs/bds20-identification
    ehs/bds40-intention
    ehs/bds50-track-n-turn
    ehs/bds60-airspeed
