# Copyright 2011 - Present RealDimensions Software, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function Get-ToolsLocation {
<#
.SYNOPSIS
Gets the top level location for tools/software installed outside of
package folders.

.DESCRIPTION
Creates or uses an environment variable that a user can control to
communicate with packages about where they would like software that is
not installed through native installers, but doesn't make much sense
to be kept in package folders. Most software coming in packages stays
with the package itself, but there are some things that seem to fall
out of this category, like things that have plugins that are installed
into the same directory as the tool. Having that all combined in the
same package directory could get tricky.

.NOTES
This is the successor to the poorly named `Get-BinRoot`. Available as
`Get-ToolsLocation` in 0.9.10+. If you need compatibility with pre
0.9.10, please use `Get-BinRoot`.

Sets an environment variable called `ChocolateyToolsLocation`. If the
older `ChocolateyBinRoot` is set, it uses the value from that and
removes the older variable.

.INPUTS
None

.OUTPUTS
None
#>

  $invocation = $MyInvocation
  Write-FunctionCallLogMessage -Invocation $invocation -Parameters $PSBoundParameters

  if ($invocation -ne $null -and $invocation.InvocationName -ne $null -and $invocation.InvocationName.ToLower() -eq 'get-binroot') {
    Write-Host "Get-BinRoot is going to be deprecated in v1 and removed in v2. It has been replaced with Get-ToolsLocation (starting with v0.9.10), however many packages no longer require a special separate directory since package folders no longer have versions on them. Some do though and should continue to use Get-ToolsLocation."
  }

  $toolsLocation = $env:ChocolateyToolsLocation

  if ($toolsLocation -eq $null) {
    $binRoot = $env:ChocolateyBinRoot
    $olderRoot = $env:chocolatey_bin_root

    if ($binRoot -eq $null -and $olderRoot -eq $null) {
      $toolsLocation = Join-Path $env:systemdrive 'tools'
    } else {
      if ($olderRoot -ne $null) {
        if ($binRoot -eq $null) {
          $binRoot = $olderRoot
        }
        Set-EnvironmentVariable -Name "chocolatey_bin_root" -Value '' -Scope User -ErrorAction SilentlyContinue
      }

      $toolsLocation = $binRoot
      Set-EnvironmentVariable -Name "ChocolateyBinRoot" -Value '' -Scope User -ErrorAction SilentlyContinue
    }
  }

  # Add a drive letter if one doesn't exist
  if (-not($toolsLocation -imatch "^\w:")) {
    $toolsLocation = Join-Path $env:systemdrive $toolsLocation
  }

  if (-not($env:ChocolateyToolsLocation -eq $toolsLocation)) {
    try {
      Set-EnvironmentVariable -Name "ChocolateyToolsLocation" -Value $toolsLocation -Scope User
    } catch {
      if (Test-ProcessAdminRights) {
        # sometimes User scope may not exist (such as with core)
        Set-EnvironmentVariable -Name "ChocolateyToolsLocation" -Value $toolsLocation -Scope Machine
      } else {
        throw $_.Exception
      }
    }
  }

  return $toolsLocation
}

Set-Alias Get-BinRoot Get-ToolsLocation -Force -Scope Global -Option AllScope

# SIG # Begin signature block
# MIIcrQYJKoZIhvcNAQcCoIIcnjCCHJoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDzlUfiGnDk+CWn
# iQKQCzwRjRa7CaQd6rbAemIAGT1K5qCCF7cwggUwMIIEGKADAgECAhAECRgbX9W7
# ZnVTQ7VvlVAIMA0GCSqGSIb3DQEBCwUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNV
# BAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0xMzEwMjIxMjAwMDBa
# Fw0yODEwMjIxMjAwMDBaMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lD
# ZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQD407Mcfw4Rr2d3B9MLMUkZz9D7RZmxOttE9X/l
# qJ3bMtdx6nadBS63j/qSQ8Cl+YnUNxnXtqrwnIal2CWsDnkoOn7p0WfTxvspJ8fT
# eyOU5JEjlpB3gvmhhCNmElQzUHSxKCa7JGnCwlLyFGeKiUXULaGj6YgsIJWuHEqH
# CN8M9eJNYBi+qsSyrnAxZjNxPqxwoqvOf+l8y5Kh5TsxHM/q8grkV7tKtel05iv+
# bMt+dDk2DZDv5LVOpKnqagqrhPOsZ061xPeM0SAlI+sIZD5SlsHyDxL0xY4PwaLo
# LFH3c7y9hbFig3NBggfkOItqcyDQD2RzPJ6fpjOp/RnfJZPRAgMBAAGjggHNMIIB
# yTASBgNVHRMBAf8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAK
# BggrBgEFBQcDAzB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9v
# Y3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHow
# eDA6oDigNoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJl
# ZElEUm9vdENBLmNybDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDBPBgNVHSAESDBGMDgGCmCGSAGG/WwA
# AgQwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAK
# BghghkgBhv1sAzAdBgNVHQ4EFgQUWsS5eyoKo6XqcQPAYPkt9mV1DlgwHwYDVR0j
# BBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQELBQADggEBAD7s
# DVoks/Mi0RXILHwlKXaoHV0cLToaxO8wYdd+C2D9wz0PxK+L/e8q3yBVN7Dh9tGS
# dQ9RtG6ljlriXiSBThCk7j9xjmMOE0ut119EefM2FAaK95xGTlz/kLEbBw6RFfu6
# r7VRwo0kriTGxycqoSkoGjpxKAI8LpGjwCUR4pwUR6F6aGivm6dcIFzZcbEMj7uo
# +MUSaJ/PQMtARKUT8OZkDCUIQjKyNookAv4vcn4c10lFluhZHen6dGRrsutmQ9qz
# sIzV6Q3d9gEgzpkxYz0IGhizgZtPxpMQBvwHgfqL2vmCSfdibqFT+hKUGIUukpHq
# aGxEMrJmoecYpJpkUe8wggVAMIIEKKADAgECAhAHdGbtomdvOuySF9IwU3EQMA0G
# CSqGSIb3DQEBCwUAMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJ
# bmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0
# IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EwHhcNMTYwMzI0MDAwMDAw
# WhcNMTcwMzI4MTIwMDAwWjB9MQswCQYDVQQGEwJVUzEPMA0GA1UECBMGS2Fuc2Fz
# MQ8wDQYDVQQHEwZUb3Bla2ExJTAjBgNVBAoTHFJlYWxEaW1lbnNpb25zIFNvZnR3
# YXJlLCBMTEMxJTAjBgNVBAMTHFJlYWxEaW1lbnNpb25zIFNvZnR3YXJlLCBMTEMw
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC52YS2WKUpBtdkDyJ3G0Qm
# 42v+W+yqr7DediVzIeCjHpKNkmmxO8+lS+nniFDjoFGO1JG/G3ZywVRFlM1LKHeP
# M1eON6wT0H1gvhxpMzyuC/SRW9wvMtTlvHnjdTLW06Oe9tvGkQkTM8rbzwRDIZ9o
# ddT8BxHSOmGelrAN9CwKf60ziw8jKLZnuAuZwSgkX5K7wvOs8viqydlnt7z3Wyim
# L+wjue85Mpa7jyjIfnUqssN1qz4nce+e89CxTD2AbWjGwnfTcTgmj3EUSJRQgDRk
# J+O/sVzS/V76xajLoPvI4ZlAsMpeK3ptLYqviU3ZaNUzLQWFjuWqc3fhjbWDFF51
# AgMBAAGjggHFMIIBwTAfBgNVHSMEGDAWgBRaxLl7KgqjpepxA8Bg+S32ZXUOWDAd
# BgNVHQ4EFgQUT0GgvxvwrOqMjXQ8yw7QDagIVJ4wDgYDVR0PAQH/BAQDAgeAMBMG
# A1UdJQQMMAoGCCsGAQUFBwMDMHcGA1UdHwRwMG4wNaAzoDGGL2h0dHA6Ly9jcmwz
# LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEuY3JsMDWgM6Axhi9odHRw
# Oi8vY3JsNC5kaWdpY2VydC5jb20vc2hhMi1hc3N1cmVkLWNzLWcxLmNybDBMBgNV
# HSAERTBDMDcGCWCGSAGG/WwDATAqMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5k
# aWdpY2VydC5jb20vQ1BTMAgGBmeBDAEEATCBhAYIKwYBBQUHAQEEeDB2MCQGCCsG
# AQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wTgYIKwYBBQUHMAKGQmh0
# dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFNIQTJBc3N1cmVkSURD
# b2RlU2lnbmluZ0NBLmNydDAMBgNVHRMBAf8EAjAAMA0GCSqGSIb3DQEBCwUAA4IB
# AQAD6K2ldfDx7hOZxW6smYkiV4lxXY4bewxGv/gh2hjWgLiQ/sornz2fHDni/kOf
# qhn8/3KvYd4V33QqMqjm/qsRpwjj9NC/Q2BGuTg0ax3e/Z9ZIvcYB4xx8CRbGKse
# R9lixgMAJZMCWyGzAC/E3XX+BX3B6y8N5zBIKRY1M7xub+LM7zW9LGMhX3e56J7G
# UF7zIzQ7ZkaJzfxFbVvEz2/KNoNGiCmA7Y0biMXpX9730Dbg4Z+B4SUe4k4WPLS/
# 3goAq8lVMFtoqShvyvrmYtj2gFjQmH3BzSCSRZrAFbWYDCga57Fq7A4xrF2i67kG
# oljzeP+/35wuoOlrggn2EuJ1MIIGajCCBVKgAwIBAgIQAwGaAjr/WLFr1tXq5hfw
# ZjANBgkqhkiG9w0BAQUFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNl
# cnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdp
# Q2VydCBBc3N1cmVkIElEIENBLTEwHhcNMTQxMDIyMDAwMDAwWhcNMjQxMDIyMDAw
# MDAwWjBHMQswCQYDVQQGEwJVUzERMA8GA1UEChMIRGlnaUNlcnQxJTAjBgNVBAMT
# HERpZ2lDZXJ0IFRpbWVzdGFtcCBSZXNwb25kZXIwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQCjZF38fLPggjXg4PbGKuZJdTvMbuBTqZ8fZFnmfGt/a4yd
# VfiS457VWmNbAklQ2YPOb2bu3cuF6V+l+dSHdIhEOxnJ5fWRn8YUOawk6qhLLJGJ
# zF4o9GS2ULf1ErNzlgpno75hn67z/RJ4dQ6mWxT9RSOOhkRVfRiGBYxVh3lIRvfK
# Do2n3k5f4qi2LVkCYYhhchhoubh87ubnNC8xd4EwH7s2AY3vJ+P3mvBMMWSN4+v6
# GYeofs/sjAw2W3rBerh4x8kGLkYQyI3oBGDbvHN0+k7Y/qpA8bLOcEaD6dpAoVk6
# 2RUJV5lWMJPzyWHM0AjMa+xiQpGsAsDvpPCJEY93AgMBAAGjggM1MIIDMTAOBgNV
# HQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcD
# CDCCAb8GA1UdIASCAbYwggGyMIIBoQYJYIZIAYb9bAcBMIIBkjAoBggrBgEFBQcC
# ARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzCCAWQGCCsGAQUFBwICMIIB
# Vh6CAVIAQQBuAHkAIAB1AHMAZQAgAG8AZgAgAHQAaABpAHMAIABDAGUAcgB0AGkA
# ZgBpAGMAYQB0AGUAIABjAG8AbgBzAHQAaQB0AHUAdABlAHMAIABhAGMAYwBlAHAA
# dABhAG4AYwBlACAAbwBmACAAdABoAGUAIABEAGkAZwBpAEMAZQByAHQAIABDAFAA
# LwBDAFAAUwAgAGEAbgBkACAAdABoAGUAIABSAGUAbAB5AGkAbgBnACAAUABhAHIA
# dAB5ACAAQQBnAHIAZQBlAG0AZQBuAHQAIAB3AGgAaQBjAGgAIABsAGkAbQBpAHQA
# IABsAGkAYQBiAGkAbABpAHQAeQAgAGEAbgBkACAAYQByAGUAIABpAG4AYwBvAHIA
# cABvAHIAYQB0AGUAZAAgAGgAZQByAGUAaQBuACAAYgB5ACAAcgBlAGYAZQByAGUA
# bgBjAGUALjALBglghkgBhv1sAxUwHwYDVR0jBBgwFoAUFQASKxOYspkH7R7for5X
# DStnAs0wHQYDVR0OBBYEFGFaTSS2STKdSip5GoNL9B6Jwcp9MH0GA1UdHwR2MHQw
# OKA2oDSGMmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJ
# RENBLTEuY3JsMDigNqA0hjJodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNl
# cnRBc3N1cmVkSURDQS0xLmNybDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGG
# GGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2Nh
# Y2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEQ0EtMS5jcnQwDQYJ
# KoZIhvcNAQEFBQADggEBAJ0lfhszTbImgVybhs4jIA+Ah+WI//+x1GosMe06Fxlx
# F82pG7xaFjkAneNshORaQPveBgGMN/qbsZ0kfv4gpFetW7easGAm6mlXIV00Lx9x
# sIOUGQVrNZAQoHuXx/Y/5+IRQaa9YtnwJz04HShvOlIJ8OxwYtNiS7Dgc6aSwNOO
# Mdgv420XEwbu5AO2FKvzj0OncZ0h3RTKFV2SQdr5D4HRmXQNJsQOfxu19aDxxncG
# KBXp2JPlVRbwuwqrHNtcSCdmyKOLChzlldquxC5ZoGHd2vNtomHpigtt7BIYvfdV
# VEADkitrwlHCCkivsNRu4PQUCjob4489yq9qjXvc2EQwggbNMIIFtaADAgECAhAG
# /fkDlgOt6gAK6z8nu7obMA0GCSqGSIb3DQEBBQUAMGUxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# JDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0wNjExMTAw
# MDAwMDBaFw0yMTExMTAwMDAwMDBaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxE
# aWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMT
# GERpZ2lDZXJ0IEFzc3VyZWQgSUQgQ0EtMTCCASIwDQYJKoZIhvcNAQEBBQADggEP
# ADCCAQoCggEBAOiCLZn5ysJClaWAc0Bw0p5WVFypxNJBBo/JM/xNRZFcgZ/tLJz4
# FlnfnrUkFcKYubR3SdyJxArar8tea+2tsHEx6886QAxGTZPsi3o2CAOrDDT+GEmC
# /sfHMUiAfB6iD5IOUMnGh+s2P9gww/+m9/uizW9zI/6sVgWQ8DIhFonGcIj5BZd9
# o8dD3QLoOz3tsUGj7T++25VIxO4es/K8DCuZ0MZdEkKB4YNugnM/JksUkK5ZZgrE
# jb7SzgaurYRvSISbT0C58Uzyr5j79s5AXVz2qPEvr+yJIvJrGGWxwXOt1/HYzx4K
# dFxCuGh+t9V3CidWfA9ipD8yFGCV/QcEogkCAwEAAaOCA3owggN2MA4GA1UdDwEB
# /wQEAwIBhjA7BgNVHSUENDAyBggrBgEFBQcDAQYIKwYBBQUHAwIGCCsGAQUFBwMD
# BggrBgEFBQcDBAYIKwYBBQUHAwgwggHSBgNVHSAEggHJMIIBxTCCAbQGCmCGSAGG
# /WwAAQQwggGkMDoGCCsGAQUFBwIBFi5odHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9z
# c2wtY3BzLXJlcG9zaXRvcnkuaHRtMIIBZAYIKwYBBQUHAgIwggFWHoIBUgBBAG4A
# eQAgAHUAcwBlACAAbwBmACAAdABoAGkAcwAgAEMAZQByAHQAaQBmAGkAYwBhAHQA
# ZQAgAGMAbwBuAHMAdABpAHQAdQB0AGUAcwAgAGEAYwBjAGUAcAB0AGEAbgBjAGUA
# IABvAGYAIAB0AGgAZQAgAEQAaQBnAGkAQwBlAHIAdAAgAEMAUAAvAEMAUABTACAA
# YQBuAGQAIAB0AGgAZQAgAFIAZQBsAHkAaQBuAGcAIABQAGEAcgB0AHkAIABBAGcA
# cgBlAGUAbQBlAG4AdAAgAHcAaABpAGMAaAAgAGwAaQBtAGkAdAAgAGwAaQBhAGIA
# aQBsAGkAdAB5ACAAYQBuAGQAIABhAHIAZQAgAGkAbgBjAG8AcgBwAG8AcgBhAHQA
# ZQBkACAAaABlAHIAZQBpAG4AIABiAHkAIAByAGUAZgBlAHIAZQBuAGMAZQAuMAsG
# CWCGSAGG/WwDFTASBgNVHRMBAf8ECDAGAQH/AgEAMHkGCCsGAQUFBwEBBG0wazAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAC
# hjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURS
# b290Q0EuY3J0MIGBBgNVHR8EejB4MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2Vy
# dC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMDqgOKA2hjRodHRwOi8v
# Y3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMB0G
# A1UdDgQWBBQVABIrE5iymQftHt+ivlcNK2cCzTAfBgNVHSMEGDAWgBRF66Kv9JLL
# gjEtUYunpyGd823IDzANBgkqhkiG9w0BAQUFAAOCAQEARlA+ybcoJKc4HbZbKa9S
# z1LpMUerVlx71Q0LQbPv7HUfdDjyslxhopyVw1Dkgrkj0bo6hnKtOHisdV0XFzRy
# R4WUVtHruzaEd8wkpfMEGVWp5+Pnq2LN+4stkMLA0rWUvV5PsQXSDj0aqRRbpoYx
# YqioM+SbOafE9c4deHaUJXPkKqvPnHZL7V/CSxbkS3BMAIke/MV5vEwSV/5f4R68
# Al2o/vsHOE8Nxl2RuQ9nRc3Wg+3nkg2NsWmMT/tZ4CMP0qquAHzunEIOz5HXJ7cW
# 7g/DvXwKoO4sCFWFIrjrGBpN/CohrUkxg0eVd3HcsRtLSxwQnHcUwZ1PL1qVCCkQ
# JjGCBEwwggRIAgEBMIGGMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lD
# ZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0ECEAd0Zu2iZ2867JIX
# 0jBTcRAwDQYJYIZIAWUDBAIBBQCggYQwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKA
# ADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYK
# KwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg/0wnr+gv9Nrh5mxYEoi2/ZADXL3D
# a/rE9Eqz010fWhgwDQYJKoZIhvcNAQEBBQAEggEAll7hRspM/DWcfBHhxjRtJUMa
# 5rd51NrK80AWUhX9oAOY2Yr7/eSRUO6wz96PpLZGH+cONcT34Ma2M/EsPqDUQ7Rx
# vYXTgMJz3biK2lz4IZfTmnkATeoFNSS6ftqGFVrZcQ+tKP6GUOqredUWkbpyD4ec
# fNnzlj4Qe6b3e9WELuzrnoIbB7fxE+/i9z/T2U6bZ6HFXbmuoF9jdv00/DRyJhxL
# 2aX3oRDrUkoHrb/l3Aa7YAMwjbrnLNQ1wlcWJSbnpZfudiV5kKG+CXAxCWWSC8tf
# UPOB3PmpKKgLHggiPYcT4IXA11+22FG+ja9u1xFpQ+zWdMOi6849F1mL9N+KBaGC
# Ag8wggILBgkqhkiG9w0BCQYxggH8MIIB+AIBATB2MGIxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# ITAfBgNVBAMTGERpZ2lDZXJ0IEFzc3VyZWQgSUQgQ0EtMQIQAwGaAjr/WLFr1tXq
# 5hfwZjAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkq
# hkiG9w0BCQUxDxcNMTYxMDA3MDY1ODE5WjAjBgkqhkiG9w0BCQQxFgQUHgZJ5xM+
# JvfFf5aCMk9cORdGWCgwDQYJKoZIhvcNAQEBBQAEggEAL/waREBGq+OZ7UDJkUiK
# +EEGowmird7/XvOfu1RVvAQdqMG3zNYXqvW9FgS8rUhsjb1h6Qdsw5/aw/J9ZrdX
# c/1PutsgvMFYhwrNb5v0xdrOtqsFa8fEr5lcG3/XgYrEgsUVRoe9qoD8p84b//s8
# 0ryzkf20acJ8cCgPxI/tyelb7UCj3WtzHdXl0+OQ6SA5Q5hliMJG76G9TLhtNwJ5
# Y6GWwuLLTgKl0GY0KU+1w7d3z0lmNhqlJstyobSpdVLcYYuz7bi1qVnLB73WfibT
# Pl/9vruvXcmyeg6Asy8aSLO5z4/KRTaHluZQw2bSFyXGGuxqPpPX3sjSNXtfIfFj
# Eg==
# SIG # End signature block