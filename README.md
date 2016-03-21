# winvimbuild

## Overview:

This is a Powershell script to download and install all the prerequisites for and then build Vim and YouCompleteMe on Windows 7 or later.

It builds Vim and YouCompleteMe for 64 bit Windows systems based on the master code branches for both.

This is useful when staging a new PC or a Virtual Machine when setting up a development environment in Windows.

## Requirements:

The script must be run on Windows 7 or higher using Powershell 2.0+ with Administrator privileges.

## Processing Order:

- Download Prerequisites including:

    - .Net Framework 4.5.1
    - Python 2.7.9 (x86-64)
    - Python 3.4.4 (x86-64)
    - Visual Studio 2015 Community Edition
    - Windows 7 SDK
    - Git 2.7.4
    - Windows Vim Install

- Install Prerequisites

- Clone Repositories for:

    - Vim
    - YouCompleteMe

- Set Environment Variables for Build including:

    - Windows 7 SDK
    - Visual Studio 2015 Community Edition

- Run Builds including:

    - Vim
    - YouCompleteMe

## TODO:

- Install Vundle

- Install Node.js

- Set files and parameters for %USERPROFILE%\\.vimrc and %USERPROFILE%\\.tern-project
