dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

Invoke-WebRequest https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi

wsl_update_x64.msi

wsl --set-default-version 2

Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile Ubuntu1804.appx -UseBasicParsing
Add-AppxPackage .\Ubuntu1804.appx

#Invoke-WebRequest -Uri https://aka.ms/wslubuntu2004 -OutFile Ubuntu2004.appx -UseBasicParsing
#Add-AppxPackage .\Ubuntu2004.appx

#https://aka.ms/wslubuntu2004
#https://aka.ms/wslubuntu2004arm
#https://aka.ms/wsl-ubuntu-1804-arm
#https://aka.ms/wsl-ubuntu-1604