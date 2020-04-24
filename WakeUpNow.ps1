$machineName = "DEV-SAM2"

& $PSScriptRoot\.paket\paket.bootstrapper.exe
& $PSScriptRoot\.paket\paket.exe install

. $PSScriptRoot\Credentials.ps1
$domainCred = Request-RedGateDomainCredential
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($domainCred.Password))
$user = $domainCred.UserName
"Connecting with username $user"

& "C:\Program Files (x86)\CheckPoint\Endpoint Connect\trac.exe" connect -u $user -p $password
if ($LastExitCode) { throw "VPN returned exit code $LastExitCode" }


& start "https://wol.red-gate.com/WakeUp?Name=$machineName.red-gate.com"