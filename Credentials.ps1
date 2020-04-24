function LoadCredentialDll()
{
    Add-Type -Path "$PSScriptRoot\packages\CredentialManagement\lib\net35\CredentialManagement.dll"
}

# based on SQLDoc code in https://github.com/red-gate/SQLDoc/blob/ee88d2ae2b6b1611da70efa7e8343a81f83c6e1c/UI/Common/LatestSqlServerProvider.cs

# Tries to load a generic credential with target $name
function Get-SavedCredential {
    [CmdletBinding()]
    param($name)
    
    if (!$name) { throw '$name is required' }

    LoadCredentialDll
    
    Write-Verbose "Attempting to load credential $name"

    $cred = New-Object CredentialManagement.Credential
    $cred.Target = $name
    $success = $cred.Load()
    if ($success)
    {
        $username = $cred.Username
        $password = $cred.Password | ConvertTo-SecureString -asPlainText -Force
        return New-Object System.Management.Automation.PSCredential($username, $password)
    }
}

# Store a generic credential with the given name and details
function Store-SavedCredential {
    [CmdletBinding()]
    param($name, $username, $password)
    
    if (!$name -or !$username -or !$password) { throw '$name and $username and $password are required' }

    LoadCredentialDll
    
    Write-Verbose "Storing credential with name $name"
    $cred = New-Object CredentialManagement.Credential($username, $password, $name)
    $cred.PersistanceType = 'Enterprise'

    $success = $cred.Save()
    if (!$success)
    {
        Write-Error "cred.Delete() returned $success, throwing"
        throw new-object ComponentModel.Win32Exception([Runtime.InteropServices.Marshal]::GetLastWin32Error())
    }
}

# Remove a generic credential with the given name
function Remove-SavedCredential {
    [CmdletBinding()]
    param($name)
    
    if (!$name) { throw '$name is required' }

    LoadCredentialDll

    $cred = New-Object CredentialManagement.Credential
    $cred.Target = $name
    $exists = $cred.Load()
    if (!$exists)
    {
        Write-Warning "Could not load credential with name $name, skipping deletion"
        return
    }

    Write-Verbose "Removing credential with name $name"
    $success = $cred.Delete()
    if (!$success)
    {
        Write-Error "cred.Delete() returned $success, throwing"
        throw new-object ComponentModel.Win32Exception([Runtime.InteropServices.Marshal]::GetLastWin32Error())
    }
}

# Requests a credential from the user (but can also use cached credentials)
function Request-SavedCredential {
    [CmdletBinding()]
    param($name, $message, $username='')
    
    if (!$name -or !$message) { throw '$name and $message are required' }

    $existingCred = Get-SavedCredential $name
    if ($existingCred) { return $existingCred }

    Write-Verbose "Credential with name $name was not found, requesting from user"

    $newCred = Get-Credential -UserName $username -Message $message
    $password = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($newCred.Password))
    Store-SavedCredential $name $newCred.UserName $password

    return $newCred
}

# Request a RED-GATE domain credential and store it as 'RedGate.Release-DomainLogin'
function Request-RedGateDomainCredential {
    $credentialName = 'RedGate.Release-DomainLogin'

    while($domainCred -eq $null) {
        $domainCred = Request-SavedCredential $credentialName "Enter your RED-GATE domain credentials.`r`n(Without the RED-GATE\ prefix or @red-gate.com suffix)" $env:USERNAME
        if($domainCred.Username -match '[\\@]') {
            Write-Host "Sorry, your username cannot contain '\' or '@'. Can you try again?" -ForeGround Red
            Remove-SavedCredential $credentialName
            $domainCred = $null
        }
    }
    
    $domainCred
}

function Remove-SavedRedGateDomainCredential { Remove-SavedCredential 'RedGate.Release-DomainLogin' }