============================================================
The 1090MHz Riddle
============================================================
------------------------------------------------------------
The book about decoding Mode-S and ADS-B data
------------------------------------------------------------

Preface
=======

Begun with a frustration on the lack of technical public information on ADS-B and Mode-S in the year of 2015, I created an live online document to recorded my understanding of ADS-B data. Previously, this was known as `"ADS-B Decoding Guide" <http://adsb-decode-guide.readthedocs.org/>`_ project. Together with the tutorial, we also developed its related python library, the `pyModeS <https://github.com/junzis/pyModeS>`_. With time, I received many feedbacks, compliments, and contributions from open-source community users.

From beginning of 2017, the interests of tapping into Enhanced Mode-S (EHS) data brought us a whole new chapter of Mode-S inference and decoding into the pyModeS. This also enriches the "ADS-B" guide. With the advance in this area, I am planning to compile a more comprehensive online book to cover both ADS-B and Mode-S decoding and related topic.

That's the starting of this new repository. I am also starting host the online book on my own server to allow more flexibility of editing and publishing. You can read the most up-to-date book on `mode-s.org <http://mode-s.org>`_.

Oh, it is still GNU GPL. It was great to see the pull request from different contributors previously. I am looking forward to seeing more comments and pulls from the community. Enjoy!

Table of content
----------------

.. toctree::
    :maxdepth: 2
    :numbered:

    adsb
    ehs


Related resources
-----------------

This guide document is shared on GitHub and ReadTheDoc. Please feel free to help us improving it.

Links to this guide document:

- (Rst source) https://github.com/junzis/the-1090mhz-riddle
- (Live book) http://mode-s.org


You can download the pyModeS tool from GitHub, which is a Python implementation of all (and more) message types described here:

- (GitHub) https://github.com/junzis/pyModeS



Original contributors
---------------------

- Junzi Sun, PhD Candidate, TuDelft
- Jacco Hoekstra, Prof.dr.ir, TuDelft
- Joost EllerBroek, Dr.ir, TuDelft
- Huy Vu, Master Student, TuDelft


Contact
-------
Since the start of the this project, I have received many questions by email. However, the best way to post your questions is using the **GitHub Issues**. This way, your questions and my answers can help others as well:

- Related with this book: https://github.com/junzis/the-1090mhz-riddle/issues
- Related with pyModeS: https://github.com/junzis/pyModes/issues


Anyhow, still feel free to drop me a messages at: **j.sun-1[at]tudelft.nl**


References
----------
Some good source of documents:

- RTCA: Minimum Operational Performance Standards for 1090 MHz Extended Squitter
- ICAO: Technical Provisions for Mode S Services and Extended Squitter
- `ICAO ADS-B Guide <http://www.icao.int/SAM/eDocuments/ADSB%20Guide%20Vs1.2%20English.pdf>`_
- `Dump1090 Project <https://github.com/antirez/dump1090>`_
- `A Very Simple ADSB Receiver, <http://www.lll.lu/~edward/edward/adsb/VerySimpleADSBreceiver.html>`_
