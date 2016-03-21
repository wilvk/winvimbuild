param(  
    [bool]$DownloadPrerequisites=$true, 
    [bool]$InstallPrerequisites=$true, 
    [bool]$BuildVimAndYcm=$true 
)

function DownloadFile($url, $output)
{
    $start_time = Get-Date
    $wc = New-Object System.Net.WebClient

    Write-Output "Starting download of: $url to: $output"

    $wc.DownloadFile($url, $output)

    Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
}

function RunProcess($comment, $process, $argumentList)
{
    $start_time = Get-Date
    
    Write-Output $comment

    Start-Process -NoNewWindow -Wait -FilePath $process -ArgumentList $argumentList

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

$downloads = 
    ("https://download.microsoft.com/download/1/6/7/167F0D79-9317-48AE-AEDB-17120579F8E2/NDP451-KB2858728-x86-x64-AllOS-ENU.exe", "$dltemp\NDP451-KB2858728-x86-x64-AllOS-ENU.exe"),
    ("https://www.python.org/ftp/python/2.7.9/python-2.7.9.amd64.msi", "$dltemp\python-2.7.9.amd64.msi"),
    ("https://www.python.org/ftp/python/3.4.4/python-3.4.4.amd64.msi", "$dltemp\python-3.4.4.amd64.msi"),
    ("https://download.microsoft.com/download/0/B/C/0BC321A4-013F-479C-84E6-4A2F90B11269/vs_community.exe", "$dltemp\vs_community_ENU.exe"),
    ("https://download.microsoft.com/download/7/A/B/7ABD2203-C472-4036-8BA0-E505528CCCB7/winsdk_web.exe", "$dltemp\winsdk_web.exe"),
    ("https://github.com/git-for-windows/git/releases/download/v2.7.4.windows.1/Git-2.7.4-64-bit.exe", "$dltemp\Git-2.7.4-64-bit.exe"),
    ("ftp://ftp.vim.org/pub/vim/pc/gvim74.exe", "$dltemp\gvim74.exe")

$prereqProcesses = 
    ("Installing .Net Framework 4.5.1","$dltemp\NDP451-KB2858728-x86-x64-AllOS-ENU.exe",
        ('/q','/norestart')
    ),
    ("Installing Python 2.7.9","msiexec.exe",
        ('/a',"$dltemp\python-2.7.9.amd64.msi",'/quiet')
    ),
    ("Installing Python 3.4.4","msiexec.exe",
        ('/a',"$dltemp\python-3.4.4.amd64.msi",'/quiet')
    ),
    ("Installing Git 2.7.4","$DLTEMP\Git-2.7.4-64-bit.exe",
        ('/SILENT','/COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh')
    ),
    ("Installing VS2015 prerequisites","$dltemp\vs_community_ENU.exe",
        ('/Layout',"$vs2015InstLocation",'/silent')
    ),
    ("Installing VS2015 Deploy File","$vs2015InstLocation\vs_community.exe",
        ('/CreateAdminFile','$vs2015InstLocation\packages\AdminDeployment.xml','/silent')
    ),
    ("Installing VS2015 Silently","$vs2015InstLocation\vs_community.exe", 
        ("")
    ),
    ("Installing Windows 7 SDK","$dltemp\winsdk_web.exe",
        ('/features','+','/q')
    ),
    ("Installing Vim for Windows","$dltemp\gvim74.exe",
        ('/S')
    )  

$buildProcesses = 
    ("Cloning Git","git",
        ('https://github.com/vim/vim.git',"$vimbuildsrc")
    ),
    ("Cloning YouCompleteMe","git",
        ('https://github.com/Valloric/YouCompleteMe.git',"$env:USERPROFILE\.git\bundle\YouCompleteMe")
    ),
    ("Setting Windows SDK Environment Variables","$env:ProgramFiles\Microsoft SDKs\Windows\v7.0\bin\SetEnv.Cmd",
        ('/x64')
    ),
    ("Setting MSVC++ Environment Variables","$env:VS140COMNTOOLS..\..\VC\vcvarsall.bat",
        ('x86_amd64')
    ),
    ("Building Vim.exe","$env:VS140COMNTOOLS..\..\VC\bin\nmake.exe",
        ('-f','Make_mvc.mak','CPU=AMD64','GUI=no','OLE=yes','PYTHON=c:\python27','DYNAMIC_PYTHON=yes','PYTHON_VER=27','PYTHON3=c:\python34','DYNAMIC_PYTHON3=yes','PYTHON3_VER=34','%1','IME=yes','CSCOPE=yes')
    )

    
## Download Prerequisite Installs

if($DownloadPrerequisites -eq $true)
{
    ForEach($download in $downloads)
    {
        DownloadFile $download[0] $download[1]
    }
}

CD "$dltemp"

## Run Installs

if($InstallPrerequisites -eq $true)
{
    ForEach($prereqProcess in $prereqProcesses)
    {
        RunProcess $prereqProcess[0] $prereqProcess[1] $prereqProcess[2]
    }    
}

$env:PATH = "c:\program files\git\bin";$env:PATH

## Run Build

if($BuildVimAndYcm -eq $true)
{
    ForEach($buildProcess in $buildProcesses)
    {
        RunProcess $buildProcess[0] $buildProcess[1] $buildProcess[2]
    }
}

## Rename old Vim.exe and copy new Vim to Vim folder

Rename-Item "c:\program files (x86)\vim\vim74\vim.exe" -NewName "c:\program files (x86)\vim\vim74\vim.old.exe"

Copy-Item "$vimbuild\vim\src\vim.exe" -Destination "c:\program files (x86)\vim\vim74\vim.exe"

## Build YouCompleteMe

CD $ycmbuildsrc

Start-Process -NoNewWindow -Wait -FilePath "c:\python27\python.exe" -ArgumentList "$ycmbuildsrc\install.py",'--all' 

