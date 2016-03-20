# winvimbuild

This is a Powershell script to download and install all prerequisites for building Vim on Windows 7 or later.

It additionally builds Vim and YouCompleteMe for 64 bit systems based on the master code branches for both. 

This is useful for when staging a new PC or a Virtual Machine when setting up a develoment envionment in Windows.

I originally put this script together as I found it excessively difficult to get AutoComplete working correcly for Vim in Windows.

Order of processing:

- Download Prerequisites
- Install Prerequisites
- Set Environment Variables for build
- Run build for Vim
- Run build for YouCompleteMe


