ADS-B Decoding Guide
====================

This is a small research project conducted by `Junzi Sun <http://junzisun.com>`_ at TuDelft. While we were trying to work with ADS-B data collected from our receiver, we notice that there are very few documents available which can explain the ADS-B data comprehensively. So, we created this guide, along with a decoder written in python (https://github.com/junzis/pyModeS). Have Fun!

Table of Content
----------------

The main focus of the guide is on reading different types of messages, understanding the information in the message, and decoding/computing aircraft status.

.. toctree::
   :maxdepth: 3

   self
   introduction
   identification
   position
   velocity
   nicnac
   tips
   modes-ehs


Documents, code, and data
-------------------------

This guide document is shared on GitHub and ReadTheDoc. Please feel free to help us improving it.

Links to this guide document:

* (GitHub) https://github.com/junzis/pyModeS
* (Document) http://adsb-decode-guide.readthedocs.org/


You can download from GitHub the python decoder, as well as some data samples we collected:

* https://github.com/junzis/py-adsb-decoder


Contact
-------
Feel free to drop me a messages at: **j.sun-1[at]tudelft.nl**


About us
--------

We are a group at TuDelft working on aircraft operations and controls.

* Junzi Sun, PhD Student     
* Jacco Hoekstra, Prof.dr.ir   
* Joost EllerBroek, Dr.ir     


References
----------

Some good source of documents:

* RTCA/EUROCAE: Minimum Operational Performance Standards for 1090 MHz Extended Squitter Automatic Dependent Surveillance – Broadcast (ADS-B) and Traffic Information Services – Broadcast (TIS-B)
* ICAO: Technical Provisions for Mode S Services and Extended Squitter
* `ICAO ADS-B Guide <http://www.icao.int/SAM/eDocuments/ADSB%20Guide%20Vs1.2%20English.pdf>`_
* `Dump1090 Project <https://github.com/antirez/dump1090>`_
* `A Very Simple ADSB Receiver, <http://www.lll.lu/~edward/edward/adsb/VerySimpleADSBreceiver.html>`_

