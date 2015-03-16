Introduction
============

Hardware
--------

[TODO: add an introduction of the hardware used for the project here]


Mode S
------

Mode S is the signal carrying the ADS-B data from aircrafts. Modulation and demodulation of Mode S signal is out of scope of this guide. From our antenna and  A/D converter, we are able to receive the encoded messages to a Linux agent. Our focuses are from this point on; working with those data.

If you are interested in dig deeper on the Mode S signal, a good starting point is to have a look at this Wikipedia page, and follow the references:

https://en.wikipedia.org/wiki/Secondary_surveillance_radar#Mode_S


ADS-B
--------

After we read the data block the of the Mode S frame, you will see something like the following:


	[sample HEX and BIN message here]


We are specifically looking for the ADS-B message by checking its Downlink Format (DF). The characteristic of this message is:

* Length: 120 bits
* DF: Bit 1 to 5
	* for ADS-B, we need DF = 10001 (BIN), or 17 (DECIMAL)

Once those conditions matched we may use this message frame to decode the information we needed. Next we need to look into the Capability (CA), and Type Code (TC) of the message to determine what data is contained in the message.

* CA: Bit 6 to 8 (3 bits)
	* You can obtain the aircraft category by: CA - 1
* TC: Bit 33 to 37 (5 bits)
	* This code will help determine what's in the message

You may notice we skipped Bit 9 to 32 here. Those 24 bits are the unique ICAO24 address of the aircraft. Hence it is also quite useful for ID aircrafts in our program.

Following table listed the key bits we are looking here:

+----------+----------+----------+------------------------+
| Bit from | Bit to   | Abbr.    | Name                   |
+==========+==========+==========+========================+
| 1        | 5        | DF       | Downlink Format        |
+----------+----------+----------+------------------------+
| 6        | 8        | CA       | Message Subtype        |
+----------+----------+----------+------------------------+
| 9        | 32       | ICAO24   | ICAO aircraft address  |
+----------+----------+----------+------------------------+
| 33       | 37       | TC       | Type Code              |
+----------+----------+----------+------------------------+


Here is a quick look-up table of which information you can expect in a message frame:

+-----+--------+----------+---------------------------------+
| DF  | CA     | TC       | Content                         |
+=====+========+==========+=================================+
| 17  | ANY    | 1 to 4   | Aircraft identification         |
+-----+--------+----------+---------------------------------+
| 17  | ANY    | 9 to 18  | Aircraft position               |
+-----+--------+----------+---------------------------------+
| 17  | 1 or 2 | 19       | Aircraft velocities and heading |
+-----+--------+----------+---------------------------------+
| 17  | 3 or 4 | 19       | Aircraft heading                |
+-----+--------+----------+---------------------------------+


Within different type of the messages, the configuration of the bits are also different. In the Decoding chapter, we will explain in detail how to read and calculate information from all those types of messages.