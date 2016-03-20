# winvimbuild

This is a Powershell script to download and install all prerequisites for building Vim on Windows 7 or later.

It additionally builds Vim and YouCompleteMe for 64 bit systems based on the master code branches for both. 

This is useful for when staging a new PC or a Virtual Machine when setting up a develoment environment in Windows.

I originally put this script together as I found it excessively difficult to get the YouCompleteMe AutoCompletion working correctly for Vim in Windows. The major issue installing these components separately is invalid 'bitness' and of the various components required. Having this install all components silently and build correctly in a script saves a lot of time.

The order of processing is:

- Download Prerequisites including:
    - .Net Framework 4.5.1
    - Python 2.7.9
    - Python 3.4.4
    - Visual Studio 2015 Community Edition
    - Windows 7 SDK
    - Git 2.7.4
    - Windows Vim Install

- Install Prerequisites

- Set Environment Variables for Build including:
    - Windows 7 SDK
    - Visual Studio 2015 Community Edition

- Run build for Vim using nmake

- Run build for YouCompleteMe using python and nmake


