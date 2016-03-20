param([bool]$DownloadPrerequisites=$true, [bool]$InstallPrerequisites=$true)

function DownloadFile($url, $output)
{
    $start_time = Get-Date
    $wc = New-Object System.Net.WebClient

    Write-Output "Starting download of: $url to: $output"

    $wc.DownloadFile($url, $output)

    Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
}

$vimbuild = "c:\vimbuild"
$vimbuildsrc = "$vimbuild\src"
$dltemp = "$vimbuild\downloads"
$vs2015InstLocation = "$dltemp\vs2015communityinstall"

$ycmbuildsrc = "$env:USERPROFILE\.git\bundle\YouCompleteMe"

New-Item $vimbuild -type directory -ErrorAction SilentlyContinue
New-Item $dltemp -type directory -ErrorAction SilentlyContinue
New-Item $ycmbuildsrc -type directory -ErrorAction SilentlyContinue
New-Item $vs2015InstLocation -type directory -ErrorAction SilentlyContinue

## Download Prerequisite Installs

if($downloadPrerequisites -eq $true)
{
    # .Net 4.5.1 Framework

    DownloadFile "https://download.microsoft.com/download/1/6/7/167F0D79-9317-48AE-AEDB-17120579F8E2/NDP451-KB2858728-x86-x64-AllOS-ENU.exe" "$dltemp\NDP451-KB2858728-x86-x64-AllOS-ENU.exe"

    # Python installs

    DownloadFile "https://www.python.org/ftp/python/2.7.9/python-2.7.9.amd64.msi" "$dltemp\python-2.7.9.amd64.msi"
    DownloadFile "https://www.python.org/ftp/python/3.4.4/python-3.4.4.amd64.msi" "$dltemp\python-3.4.4.amd64.msi"

    # Visual Studio 2015 Community

    DownloadFile "https://download.microsoft.com/download/0/B/C/0BC321A4-013F-479C-84E6-4A2F90B11269/vs_community.exe" "$dltemp\vs_community_ENU.exe"

    # Windows 7 SDK

    DownloadFile "https://download.microsoft.com/download/7/A/B/7ABD2203-C472-4036-8BA0-E505528CCCB7/winsdk_web.exe" "$dltemp\winsdk_web.exe"

    # Git

    DownloadFile "https://github.com/git-for-windows/git/releases/download/v2.7.4.windows.1/Git-2.7.4-64-bit.exe" "$dltemp\Git-2.7.4-64-bit.exe"

    # Vim install

    DownloadFile "ftp://ftp.vim.org/pub/vim/pc/gvim74.exe" "$dltemp\gvim74.exe"
}

CD "$dltemp"

## Run Installs

if($installPrerequisites -eq $true)
{
    # .Net 4.5.1 Framework:

    Start-Process -NoNewWindow -Wait -FilePath "$dltemp\NDP451-KB2858728-x86-x64-AllOS-ENU.exe" -ArgumentList '/q','/norestart'

    #Python:

    Start-Process -NoNewWindow -Wait -FilePath "msiexec.exe" -ArgumentList '/a',"$dltemp\python-2.7.9.amd64.msi",'/quiet'
    Start-Process -NoNewWindow -Wait -FilePath "msiexec.exe" -ArgumentList '/a',"$dltemp\python-3.4.4.amd64.msi",'/quiet'

    ## Git:

        # Install Git

    Start-Process -NoNewWindow -Wait -FilePath "$DLTEMP\Git-2.7.4-64-bit.exe" -ArgumentList '/SILENT','/COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh'

        # Set Git path variable

    $env:PATH = "c:\program files\git\bin";$env:PATH


    ## Visual Studio:

        # Download VS2015 prerequisites via Installer

    Start-Process -NoNewWindow -Wait -FilePath "$dltemp\vs_community_ENU.exe" -ArgumentList '/Layout',"$vs2015InstLocation",'/silent'

        # Create Admin deploy file

    Start-Process -NoNewWindow -Wait -FilePath "$vs2015InstLocation\vs_community_ENU.exe" -ArgumentList '/CreateAdminFile','$vs2015InstLocation\packages\AdminDeployment.xml','/silent'

        # Run VS2015 install

    Start-Process -NoNewWindow -Wait -FilePath "$vs2015InstLocation\vs_community_ENU.exe"

    # Windows SDK:

    Start-Process -NoNewWindow -Wait -FilePath "$dltemp\winsdk_web.exe" -ArgumentList '/features','+','/q'

    # Windows Vim:

    Start-Process -NoNewWindow -Wait -FilePath "$dltemp\gvim74.exe" -ArgumentList '/S'

}


## Clone Repositories

# Vim

Start-Process -NoNewWindow -Wait -FilePath "git" -ArgumentList 'https://github.com/vim/vim.git',"$vimbuildsrc"

# YouCompleteMe

Start-Process -NoNewWindow -Wait -FilePath "git" -ArgumentList 'https://github.com/Valloric/YouCompleteMe.git',"$env:USERPROFILE\.git\bundle\YouCompleteMe"


## Call environment-set scripts

Start-Process -NoNewWindow -Wait -FilePath "$env:VS140COMNTOOLSvsvars32.bat" -ArgumentList 'x86_amd64'
Start-Process -NoNewWindow -Wait -FilePath "$env:ProgramFiles\Microsoft SDKs\Windows\v7.0\bin\SetEnv.Cmd" -ArgumentList '/x64'

$vcdir = "$env:VS140COMNTOOLS..\..\VC\"

Start-Process -NoNewWindow -Wait -FilePath "$vcdir\vcvarsall.bat" -ArgumentList 'x86_amd64'


## Build Vim

Start-Process -NoNewWindow -Wait -FilePath "$vcdir\bin\nmake.exe" -ArgumentList '-f','Make_mvc.mak CPU=AMD64 GUI=no OLE=yes PYTHON=c:\python27 DYNAMIC_PYTHON=yes PYTHON_VER=27 PYTHON3=c:\python34 DYNAMIC_PYTHON3=yes PYTHON3_VER=34  %1 IME=yes CSCOPE=yes'

## Rename old Vim.exe and copy built Vim to Vim path

Rename-Item "c:\program files (x86)\vim\vim74\vim.exe" -NewName "c:\program files (x86)\vim\vim74\vim.old.exe"

Copy-Item "$vimbuild\vim\src\vim.exe" -Destination "c:\program files (x86)\vim\vim74\vim.exe"


## Build YouCompleteMe

CD $ycmbuildsrc

Start-Process -NoNewWindow -Wait -FilePath "c:\python27\python.exe" -ArgumentList "$ycmbuildsrc\install.py",'--all' 
