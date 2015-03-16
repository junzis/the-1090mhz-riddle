Complete Guide on Decoding ADS-B Messages
=========================================

This is a small research project conducted by Junzi Sun, Jacco Hoekstra and Joost EllerBroek, at TuDelft. While we are trying to experimenting with ADS-B data collected from our receiver, we found out that there were not many documents explaining in detail the entire cycle of decoding the ADS-B message. We created this guide for everyone who have the same questions, along with a Python library code which is free to use.


Content
----------

We will only touch briefly the hardware setup and configuration to capture ADS-B signal. The main focus will be from the raw binary/hexadecimal message into useful position, velocity, and other information of the aircraft.

1. Introduction: Mode S, Hardware setup, ADS-B, and the messages
2. Decoding messages
	* Aircraft identification
	* Airborne and Surface positions
		* Understanding the CPR (Compact Position Reporting) format
		* Calculating Lat/Lon from CPR form frames
	* Airborne velocity
3. Summary and Codes


Doc, code, and data
-------------------

This guide document is shared on GitHub and ReadTheDoc. Please feel free to help us improving it.

Links to this guide document:

	[Insert GitHub link here]
	[Insert ReadTheDoc link here]


You can download the python codes related with this document, as well as example data message from the following GitHub repository:

	[Insert GitHub link here]



About us
-----------

Junzi Sun, PhD Student
Jacco Heokstra, Prof.
Joost EllerBroek, Assoc. Prof.

Department of Control and Operation, Aerospace Engineering Faculty, TuDelft



References
-------------

A few great sources were used during the creation of the guide and software:

* `ICAO ADS-B Guide <http://www.icao.int/SAM/eDocuments/ADSB%20Guide%20Vs1.2%20English.pdf>`_
* 	`Dump1090 Project <https://github.com/antirez/dump1090>`_
*  `A Very Simple ADSB Receiver, by Edward John Cardew <http://www.lll.lu/~edward/edward/adsb/VerySimpleADSBreceiver.html>`_
* ADS-B for Dummies, by EuroControl



Pages
=====

.. toctree::
   :maxdepth: 2

   intro
   decode
