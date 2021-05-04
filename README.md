The 1090 Megahertz Riddle
==========================

This is the working repository of the book "The 1090 Megahertz Riddle: A Guide to Decoding Mode S and ADS-B Signals".

Visit the web version of the book online at: [mode-s.org](http://mode-s.org)

The second edition of this book is published by TU Delft OPEN Publishing as an open access book, under [CC BY-NC-SA-4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) license. You can find the publisher’s version of the book at: https://doi.org/10.34641/mg.11

---

## Synopsis

In the last twenty years, aircraft surveillance has moved from controller-based interrogation to automatic broadcast. The Automatic Dependent Surveillance-Broadcast (ADS-B) is the most common method for aircraft to report their state information like identity, position, and speed. Like other Mode S communications, ADS-B makes use of the 1090 megahertz transponder to transmit data. The protocol for ADS-B is open, and low-cost receivers can easily be used to intercept its signals. Many recent air transportation studies have benefited from this open data source. However, the current literature does not offer a systematic exploration of Mode S and ADS-B data, nor does it offer an in-depth explanation of the decoding process.

This book tackles this missing area in the literature. It offers researchers, engineers, students, and enthusiasts a clear guide to understanding and making use of open ADS-B and Mode S data. The first part of this book presents the knowledge required to get started with decoding these signals. It includes background information on primary radar, secondary radar, Mode A/C, Mode S, and ADS-B, as well as the hardware and software setups necessary to gather radio signals. After that, the 17 core chapters of the book investigate the details of all types of ADS-B signals and commonly used Mode S signals. Throughout these chapters, examples and sample Python code are used extensively to explain and demonstrate the decoding process. Finally, the last chapter of the book offers a summary and a brief overview of research topics that go beyond the decoding of these signals.


## Cite this book

```
@book{sun1090mhz,
    author = {Sun, Junzi}, 
    title = {The 1090 Megahertz Riddle: A Guide to Decoding Mode S and ADS-B Signals},
    publisher = {TU Delft OPEN Publishing},
    year = 2021,
    edition = 2,
    isbn = {978-94-6366-402-8},
    doi = {10.34641/mg.11}
}
```


## Table of content

```
Chapter 1 Introduction
  Section 1.1 Background: The "death ray" that saves lives
  Section 1.2 The primary radar
  Section 1.3 The secondary radar
  Section 1.4 Mode S
  Section 1.5 ADS-B
  Section 1.6 Other Mode S services
  Section 1.7 Summary

Chapter 2 Quick Start: Hardware and Software to Receive Mode S Signals
  Section 2.1 Range
  Section 2.2 Antenna
  Section 2.3 Receiver
  Section 2.4 Software tools

Chapter 3 ADS-B Basics
  Section 3.1 Message structure
  Section 3.2 Capability
  Section 3.3 ICAO address
  Section 3.4 ADS-B message types
  Section 3.5 Example of ADS-B message structure
  Section 3.6 Availability and transmission rate
  Section 3.7 ADS-B versions

Chapter 4 Aircraft identification and category
  Section 4.1 Identification (call sign)
  Section 4.2 Wake vortex category
  Section 4.3 Decoding example

Chapter 5 Airborne position
  Section 5.1 An over-simplified example
  Section 5.2 Compact position reporting
  Section 5.3 Globally unambiguous position decoding
  Section 5.4 Locally unambiguous position decoding
  Section 5.5 Altitude decoding
  Section 5.6 Verification of decoded positions

Chapter 6 Surface position
  Section 6.1 Movement
  Section 6.2 Ground track
  Section 6.3 Position
  Section 6.4 Decoding example

Chapter 7 Airborne velocity
  Section 7.1 Vertical rate
  Section 7.2 GNSS and barometric altitudes difference
  Section 7.3 Sub-type 1 and 2: Ground speed decoding
  Section 7.4 Sub-type 3 and 4: Airspeed decoding

Chapter 8 Aircraft operation status
  Section 8.1 Version 0
  Section 8.2 Version 1
  Section 8.3 Version 2

Chapter 9 Uncertainties in ADS-B
  Section 9.1 Terminology
  Section 9.2 Version 0
  Section 9.3 Version 1
  Section 9.4 Version 2

Chapter 10 Error control in ADS-B
  Section 10.1 CRC error control
  Section 10.2 ADS-B parity

Chapter 11 Basics of Mode S services
  Section 11.1 Mode S message structures
  Section 11.2 Parity
  Section 11.3 ICAO address recovery
  Section 11.4 Two's complement coding

Chapter 12 All-call reply

Chapter 13 Surveillance replies
  Section 13.1 Message structure
  Section 13.2 Altitude code
  Section 13.3 Identity code

Chapter 14 Airborne collision avoidance system
  Section 14.1 Background
  Section 14.2 ACAS with Mode C transponders
  Section 14.3 ACAS with Mode S transponders
  Section 14.4 ACAS coordination interrogation
  Section 14.5 ACAS coordination reply

Chapter 15 Comm-B
  Section 15.1 Structure
  Section 15.2 BDS

Chapter 16 Mode S elementary surveillance
  Section 16.1 Data link capability report (BDS 1,0)
  Section 16.2 Common usage GICB capability report (BDS 1,7)
  Section 16.3 Aircraft identification (BDS 2,0)
  Section 16.4 ACAS active resolution advisory (BDS 3,0)

Chapter 17 Mode S enhanced surveillance
  Section 17.1 Selected vertical intention (BDS 4,0)
  Section 17.2 Track and turn report (BDS 5,0)
  Section 17.3 Heading and speed report (BDS 6,0)

Chapter 18 Mode S meteorological services
  Section 18.1 Meteorological routine air report (BDS 4,4)
  Section 18.2 Meteorological hazard report (BDS 4,5)

Chapter 19 Inferencing of BDS codes
  Section 19.1 BDS codes identification logics
  Section 19.2 Identification of BSD 5,0 and 6,0
  Section 19.3 Decoding examples

Chapter 20 Summary and beyond
  Section 20.1 Summary
  Section 20.2 Crowd-sourced networks
  Section 20.3 Additional data
  Section 20.4 Congestion
  Section 20.5 The Future of Mode S and ADS-B

```