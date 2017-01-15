﻿# This file should be identical for all python3* packages

$packageName = 'python3'
$url = 'https://www.python.org/ftp/python/3.5.1/python-3.5.1.exe'
$url64 = 'https://www.python.org/ftp/python/3.5.1/python-3.5.1-amd64.exe'
$version = '3.5.1'
$fileType = 'exe'
$partialInstallArgs = '/quiet InstallAllUsers=1'

$installPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

$installArgs = $($partialInstallArgs + ' TargetDir="' + $installPath + '"')

# If the package is only intended for the 32-bit version, only pass
# the 32-bit version to the install package function.
if ($packageName -match 32) {
  Install-ChocolateyPackage $packageName $fileType $installArgs $url
} else {
  Install-ChocolateyPackage $packageName $fileType $installArgs $url $url64
}

# Generate .ignore files for unwanted .exe files
$exesLeftToPathInclude = @('python.exe', 'pythonw.exe', 'pip.exe', 'easy_install.exe');
Get-ChildItem -Path $destinationFolder -Recurse | Where {

  $_.Extension -eq '.exe'} | % {
  # Exclude .exe files that should en up in PATH
    if (!($exesLeftToPathInclude -contains $_.Name)) {
      New-Item $($_.FullName + '.ignore') -Force -ItemType file
    }
# Suppress output of New-Item
} | Out-Null
