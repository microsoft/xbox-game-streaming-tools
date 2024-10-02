<#
    .SYNOPSIS
    Creates a self signed certificate suitable for use in touch bundle development. Generates both a
    sideload.pfx and sideload.cer to use. The .pfx is intended to be used on the server while the .cer can be
    distributed and installed on clients.

    .NOTES
    Copyright (c) Microsoft Corporation. All rights reserved.

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
    to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
    and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: 
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>

using namespace System.Security.Cryptography.X509Certificates

param
(
    [Parameter(HelpMessage = "Host name of the machine the will host the touch bundle server.")]
    [string]$HostName = $Null,
 
    [Parameter(HelpMessage = "IPAddress of the machine that will host the touch bundle server. If blank, all ip addresses are added.")]
    [string]$IPAddress = $Null, 

    [Parameter(HelpMessage = "Path to store the generated certificate files in")]
    [string]$Out = $(Get-Location),

    [Parameter(HelpMessage = "Number of years until the certificate will expire")]
    [int]$YearsUntilExpiration = 1
)

# Calculate the IP and DNS names that the certificate should be valid for
$Subjects = @()

# Always allow connections back to localhost
$Subjects += "dns=localhost"

# If the hostname was not given, detect it
if (!$HostName) {
    $HostName = [System.Net.DNS]::GetHostName()
}

$Subjects += "dns=${HostName}"

# If the IP address is given explicitly, use that. Otherwise add all IP addresses the machine reports
if ($IPAddress) {
    $Subjects += "IPAddress=${IPAddress}"
}
else {
    Get-NetIPAddress |
    Where-Object { $_.IPv4Address } |
    ForEach-Object { $Subjects += "IPAddress=$($_.IPAddress)" }
}

$Extensions = @()

# Basic constraints - the subject may act as a CA
$Extensions += "2.5.29.19={text}cA=true&pathLength=2"

# Extended key usage - TLS web server authentication
$Extensions += "2.5.29.37={critical}{text}1.3.6.1.5.5.7.3.1"

# Subject alternate names for the host machine
$Extensions += "2.5.29.17={critical}{text}$($Subjects -join "&")"

# Generate and export a self signed certificate for use with touch bundle development
try {
    $Certificate = New-SelfSignedCertificate `
        -CertStoreLocation "Cert:\CurrentUser\My" `
        -FriendlyName "Touch Bundle Development" `
        -HashAlgorithm "SHA256" `
        -KeyLength 2048 `
        -NotAfter (Get-Date).AddYears($YearsUntilExpiration) `
        -NotBefore (Get-Date) `
        -Subject "CN=Touch Bundle Development" `
        -TextExtension $Extensions
 
    Write-Output "Generated touch bundle development certificate:"
    Write-Output "  Name:        $($Certificate.FriendlyName)"
    Write-Output "  Thumbprint:  $($Certificate.Thumbprint)"
    Write-Output "  Subjects:    $($Subjects -join "$([Environment]::NewLine)               ")"
    Write-Output "  Valid On:    $($Certificate.NotBefore)"
    Write-Output "  Valid Until: $($Certificate.NotAfter)"
 
    $Password = Read-Host "Enter Password to use on .pfx certificate" -AsSecureString
    Export-PfxCertificate -cert $Certificate -FilePath (Join-Path -Path $Out -ChildPath 'sideload.pfx') -Password $Password
    Export-Certificate -cert $Certificate -FilePath (Join-Path -Path $Out -ChildPath 'sideload.cer')
}
finally {
    # Erase the keys from the certificate store they were generated in
    try {
        if ($Certificate) {
            $CertStore = [X509Store]::New("MY", [StoreLocation]::CurrentUser)
            $CertStore.Open([OpenFlags]::ReadWrite + [OpenFlags]::OpenExistingOnly)
            $CertStore.Remove($Certificate)
            $CertStore.Close()
        }
    }
    finally {
        if ($CertStore) {
            $CertStore.Dispose()
        }
    }
}