# WakeUpNow
PowerShell scripts to do the morning dance:
 - VPN into work
 - Wake up your dev machine via wol.red-gate.com
 - Remote into your dev machine

# Usage
```
.\WakeUpNow.ps1
```
You will be prompted for information the first time you run the script:
 - Your machine name (often dev-firstname.red-gate.com)
 - Your Redgate domain username (usually firstname.lastname)
 - Your Redgate domain password

# Stored information
The script caches the following information:
 - Your machine name, in a .gitignored file called machine.txt
 - Your domain creds, in the Windows Credential Store

# Disclaimers
 - You should only use this script if you trust your home machine
 - You should change your password if your machine gets hacked
