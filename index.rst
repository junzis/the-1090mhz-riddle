A Guide on Decoding ADS-B Messages
==================================

This is a small research project conducted by Junzi Sun, Jacco Hoekstra and Joost EllerBroek, at TuDelft. While we were trying to work with ADS-B data collected from our receiver, we notice that there are very few documents available which can explain the ADS-B data comprehensively. 

So, we created this guide, along with a decoder written in python.


Content
----------

The main focus of the guide is on reading different types of messages, understanding the information in the message, and decoding/computing aircraft status.

.. toctree::
   :maxdepth: 3

   introduction
   decoding
   tips


Documents, code, and data
-------------------------

This guide document is shared on GitHub and ReadTheDoc. Please feel free to help us improving it.

Links to this guide document:

* (GitHub) https://github.com/junzis/adsb-decode-guide
* (Document) http://adsb-decode-guide.readthedocs.org/


You can download from GitHub the python decoder, as well as some data samples we collected:

* https://github.com/junzis/py-adsb-decoder



About us
--------

We are a group at TuDelft working on aircraft operations and controls.

* Junzi Sun, PhD Student     
* Jacco Heokstra, Prof.     
* Joost EllerBroek, Assoc. Prof.     





References
----------

A few great sources were used during the creation of the guide and software:

* `ICAO ADS-B Guide <http://www.icao.int/SAM/eDocuments/ADSB%20Guide%20Vs1.2%20English.pdf>`_
* `Dump1090 Project <https://github.com/antirez/dump1090>`_
* `A Very Simple ADSB Receiver, by Edward John Cardew <http://www.lll.lu/~edward/edward/adsb/VerySimpleADSBreceiver.html>`_
* ADS-B for Dummies, by EuroControl

