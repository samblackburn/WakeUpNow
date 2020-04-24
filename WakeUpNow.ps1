$machineName = "DEV-SAM2.red-gate.com"

& $PSScriptRoot\.paket\paket.bootstrapper.exe
& $PSScriptRoot\.paket\paket.exe install

. $PSScriptRoot\Credentials.ps1

Write-Host "Enter your RG Domain creds.  The username should be your Redgate domain username without the domain."
Write-Warning "Note: The creds will be saved in the Windows Credential Store."
Write-Warning "Don't use this script unless you trust the security of your PC."
Write-Warning "If your home machine gets hacked, you should change your RG domain password immediately."

$domainCred = Request-RedGateDomainCredential
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($domainCred.Password))
$user = $domainCred.UserName
Write-Host "Connecting with username $user."

& "C:\Program Files (x86)\CheckPoint\Endpoint Connect\trac.exe" connect -u $user -p $password
if ($LastExitCode) { throw "VPN returned exit code $LastExitCode" }

& start "https://wol.red-gate.com/WakeUp?Name=$machineName"
$a = 1 

do {
    ping $machineName -n 1
} while ($LastExitCode)

& "$($env:windir)\system32\mstsc.exe" /v:"$machineName"