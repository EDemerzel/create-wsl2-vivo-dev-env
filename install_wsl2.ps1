#!/usr/bin/env pwsh

# Check if the script is running on Windows
if ($PSVersionTable.Platform -ne 'Win32NT') {
    Write-Host "This script can only be run on Windows."
    exit 1
}

# Check if the script is running with administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an administrator."
    exit 1
}

# Check if WSL is already enabled
if ((Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq 'Enabled') {
    Write-Host "WSL is already enabled."
} else {
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
}

# Check if VirtualMachinePlatform is already enabled
if ((Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State -eq 'Enabled') {
    Write-Host "VirtualMachinePlatform is already enabled."
} else {
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
}

# Download and install the WSL2 update
try {
    Invoke-WebRequest -Uri https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile "wsl_update_x64.msi"
    Start-Process -FilePath "wsl_update_x64.msi" -Wait
} catch {
    Write-Host "Failed to download or install the WSL2 update."
    exit 1
}

# Set WSL2 as the default version
wsl --set-default-version 2

# Provide a menu to select the Ubuntu version
$ubuntuVersions = @{
    '1' = @{
        'url' = 'https://aka.ms/wsl-ubuntu-1804';
        'extension' = '.appx';
    }
    '2' = @{
        'url' = 'https://aka.ms/wslubuntu2004';
        'extension' = '.AppxBundle';
    }
    '3' = @{
        'url' = 'https://aka.ms/wslubuntu2204';
        'extension' = '.AppxBundle';
    }
}

$ubuntuUrl = $ubuntuVersions[$selection]['url']
$fileExtension = $ubuntuVersions[$selection]['extension']
$fileName = "$PWD\Ubuntu$selection$fileExtension"

# Download the selected Ubuntu version
try {
    Invoke-WebRequest -Uri $ubuntuUrl -OutFile $fileName -UseBasicParsing
} catch {
    Write-Host "Failed to download Ubuntu."
    exit 1
}

# Install the downloaded Ubuntu version
try {
    Add-AppxPackage $fileName
} catch {
    Write-Host "Failed to install Ubuntu."
    exit 1
}

# WSL UBUNTU URLS
# https://aka.ms/wslubuntu2204
# https://aka.ms/wslubuntu2004
# https://aka.ms/wslubuntu2004arm
# https://aka.ms/wsl-ubuntu-1804        (RECOMMENDED FOR USE WITH VIVO Developer Setup Script)
# https://aka.ms/wsl-ubuntu-1804-arm
# https://aka.ms/wsl-ubuntu-1604

# BELOW ARE THE DIRECT DOWNLOAD LINKS AS OF 2023-12-19
# https://wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2204-221101.AppxBundle
# https://wslstorestorage.blob.core.windows.net/wslblob/CanonicalGroupLimited.UbuntuonWindows_2004.2021.825.0.AppxBundle
# https://wsldownload.azureedge.net/Ubuntu_2004.2020.424.0_ARM64.appx
# https://wslstorestorage.blob.core.windows.net/wslblob/Ubuntu_1804.2019.522.0_x64.appx
# https://wsldownload.azureedge.net/Ubuntu_1804.2018.726.0_ARM.appx
# https://wsldownload.azureedge.net/Ubuntu_1604.2019.523.0_x64.appx
