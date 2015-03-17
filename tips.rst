Tips on ADS-B
=============

If you have to write every line of code from scratch, reading and decoding ADS-B messages can be difficult at some point. Here we have some tips for those who might encounter the same challenges as we had.


The message structure
---------------------

All the ADSB messages have a similar structure. Total of 112 bits, started 5 bits of Downlink Format, followed by 3 bits of the Message Type, then 24 bits of unique 24 bits of ICAO address, after that, is the 56 bits of data frame, and finished by 24 bits of parity check.

Type Code (bit 33 to 37) in located in inside, at the beginning of the data frame.

For computing the desired aircraft status, we need to have the right type of the data frame. The type is determined by Downlink Format and Type Code. 

Then you can go ahead and decode each message different into correct values.



The CPR positions
-----------------

The most crazy part is to compute the lat/lon from the Compact Position Reporting format data. Remember that we need to have two data frame (one odd, and one even) to calculate one position. Keep timestamps of those data frames, as at one point you will need to know the newest frame to have a better position calculation.

Withing the calculation process, an lookup table of so called Latitude Zone is used. check out our code too see how the earth latitudes are divided into 60 zones, of which are not equally distributed.



Aircraft Identification
-----------------------

After the aircraft ID (aka. Callsign) is decoded, there are sometimes spaces in the Callsign. Each time you decode on Callsign, you may want to strip the spaces before using it in your program. Sometimes a tailing space in a string can cause unexceptionable behaviors.



More than just ADS-B data
-------------------------

Usually the ADS-B data are presented live through a stream from a server (receiver). In order to have a good robust program, you will also need to do some low level networking programming to make sure the date are correctly received. Python - of course - has a great Socket library that can be used easily.


What now?
=========

Our research goes far beyond the decoding the ADS-B messages. The goal of this research of Junzi is to collect large amount of aircraft data from ADS-B signals, and then using data mining methods to understand, improve, and maybe even create aircraft performance models.

If you are interested, or you have any question regarding the decoding process, please feel free to contact Junzi Sun (j.sun-1[at]tudelft.nl)

