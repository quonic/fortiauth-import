#Requires -Version 5
<#
.SYNOPSIS
  Import tokens from a csv file
.DESCRIPTION
  Import tokens from a csv file because I was tired of how crappy FortiNet can't write
  a half way decent import function into thier product.
.PARAMETER <Parameter_Name>
  <Brief description of parameter input required. Repeat this attribute if required>
.INPUTS
  <Inputs if any, otherwise state None>
.OUTPUTS
  <Outputs if any, otherwise state None>
.NOTES
  Version:        1.0
  Author:         Jim Caten
  Creation Date:  4/1/2017
  Status:         Imcomplete
  Purpose/Change: Initial script development
.EXAMPLE
  <Example explanation goes here>
  
  <Example goes here. Repeat this attribute for more than one example>
#>

[CmdletBinding()]
#region ---------------------------------------------------------[Script Parameters]------------------------------------------------------
Param (
    [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        #[ValidateScript({[system.uri]::IsWellFormedUriString($_,[System.UriKind]::Absolute)})]
        [ValidateScript({$_ -match [IPAddress]$_ })]
    $Address = "127.0.0.1",

    [Parameter(Mandatory=$false)]
    [SecureString]
    $Crediential,

    [Parameter(Mandatory=$false)]
    [Alias("User","Account")]
	[string]$Username,

    [Parameter(Mandatory=$false)]
    [Alias("Key","Password")]
	[string]$APIKey,

    [Parameter(
        Mandatory=$true,
        ValueFromPipeline=$true)]
    [ValidateScript({Test-Path $_})]
    [Alias("Csv")]
    [string]
    $File
)
#endregion

#region ------------------------------------------------------------[EventIDs]------------------------------------------------------------
<#
  EventID 0: Info, Starting
  EventID 1: Warn, Something happened unexpectedly, but it is being handled. <Details of what is happening>
  EventID 2: Error, Something happened unexpectedly, and can't be handled. <Details of what is happening>
  EventID 4: Fatal, Something happened and exiting. <Details of what is happening>

  EventID 100: Fatal, Failed to get tokens
  EventID 101: Fatal, Failed to connect to server
  EventID 101: Info, Completed Sucessfully
  EventID 102: Fatal, Failed to get tokens
#>
#endregion

#region ---------------------------------------------------------[Initialisations]--------------------------------------------------------
$ErrorActionPreference = 'SilentlyContinue'

# Trust all certs as we don't use an internal CA
# Remove this if you do use an internal CA or are using an external CA
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
#endregion

#region ----------------------------------------------------------[Declarations]----------------------------------------------------------
$ScriptName = "Import-Token"
$StoredCredential = "$PSScriptRoot/Credential.xml"
#endregion

#region --------------------------------------------------[Event Log Write-Log Function]--------------------------------------------------

Function Write-Log {
<#
.SYNOPSIS
    Standard Event Log entry writer
.DESCRIPTION
    Writes an entry to the local system's Event Log in a predictable and dependable way
.PARAMETER Level
    Sets the what type of entry this is.
.PARAMETER Message
    The information that you wish to convey in the Event Log
.PARAMETER EventID
    The Event ID of this log entry
.INPUTS
    None
.OUTPUTS
    None
.NOTES
    Version:        1.0
    Author:         Jim Caten
    Creation Date:  3/16/2017
    Purpose/Change: Initial Event Log Writer
.EXAMPLE
    Write-Log -Level Info -Message "Did task" -EventID 0
.EXAMPLE
    Write-Log -EntryType Info -Message "Did task" -EventID 0
#>
    Param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Message,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateCount(0,65535)]
    [int]
    $EventID,
    [Parameter(Mandatory=$false)]
    [ValidateSet("Error", "Warn", "Info", "Fatal", "Debug", "Verbose")]
    [Alias("EntryType")]
    [string]
    $Level = "Info",
    [Parameter(Mandatory=$false)]
    [ValidateSet("EventLog", "Console", "LogFile")]
    [string]
    $Method = "EventLog",
    [Parameter(Mandatory=$false)]
    [string]
    $File
    )

    $Message = "{0}: {1}" -f $Level, $Message
    
    switch($Method){
        'EventLog' {
            switch($Level) {
                'Error'   { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType FailureAudit -EventId $EventID -Message $Message }
                'Warn'    { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType Warning -EventId $EventID -Message $Message }
                'Info'    { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType Information -EventId $EventID -Message $Message }
                'Fatal'   { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType Error -EventId $EventID -Message $Message }
                'Debug'   { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType Information -EventId $EventID -Message $Message }
                'Verbose' { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType SuccessAudit -EventId $EventID -Message $Message }
            }
        }
        'Console' {
            switch($Level) {
                'Error'   { Write-Error -Message "$Message" -ErrorId $EventID }
                'Warn'    { Write-Warning "Warning $EventID : $Message"}
                'Info'    { Write-Information "Warning $EventID : $Message" -ForegroundColor White}
                'Fatal'   { Write-Error -Message "$Message" -ErrorId $EventID}
                'Debug'   { Write-Debug -Message "$EventID : $Message"}
                'Verbose' { Write-Verbose "Warning $EventID : $Message"}
            }
        }
        'LogFile' {
            switch($Level) {
                'Error'   { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType FailureAudit -EventId $EventID -Message $Message }
                'Warn'    { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType Warning -EventId $EventID -Message $Message }
                'Info'    { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType Information -EventId $EventID -Message $Message }
                'Fatal'   { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType Error -EventId $EventID -Message $Message }
                'Debug'   { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType Information -EventId $EventID -Message $Message }
                'Verbose' { Write-EventLog -LogName "Application" -Source $ScriptName -EntryType SuccessAudit -EventId $EventID -Message $Message }
            }
        }
    }
}
#endregion

#region -----------------------------------------------------------[Functions]------------------------------------------------------------

Function Get-Token {
    Param($Server,$Resource,$Credentials)
    $returnedData = Invoke-RestMethod -Method Get -Uri "$Resource/fortitokens/" -Credential $Credentials -Headers @{"Accept"="application/json"} -ErrorVariable $e
    if($e){
        Write-Log -Message "Exitting, error in getting tokens from $Server : $e" -EventID 102 -Level Fatal -Method Console
        Exit
    }
    $data = $returnedData.objects
    if($returnedData.meta){
        do{
            $returnedData = Invoke-RestMethod -Method Get -Uri "$($Server)$($returnedData.meta.next)" -Credential $Credentials -Headers @{"Accept"="application/json"} -ErrorVariable $e
            if($e){
                Write-Log -Message "Exitting, error in getting tokens from $Server : $e" -EventID 102 -Level Fatal -Method Console
                Exit
            }

            $data = $data + $returnedData.objects
        }while($returnedData.meta.next)
    
    }
    Write-Output $data
}

Function Remove-TokenFromUser {
    Param($ID,$Server,$Resource,$Credentials)
    Set-User -ID $ID -Server $Server -Resource $Resource -Credentials $Credentials -TokenAuth $false -TokenSerial "" -TokenType ""
}

Function Get-Users {
    Param($Server,$Resource,$Credentials,[switch]$Test)
    if(-not $Test){
        $returnedData = Invoke-RestMethod -Method Get -Uri "$Resource/localusers/" -Credential $Credentials -Headers @{"Accept"="application/json"} -ErrorVariable $e
        if($e){
            Write-Log -Message "Exitting, error in getting users from $Server : $e" -EventID 100 -Level Fatal -Method Console
            Exit
        }
        $data = $returnedData.objects
        if($returnedData.meta){
            do{
                $returnedData = Invoke-RestMethod -Method Get -Uri "$($Server)$($returnedData.meta.next)" -Credential $Credentials -Headers @{"Accept"="application/json"} -ErrorVariable $e
                if($e){
                    Write-Log -Message "Exitting, error in getting users from $Server : $e" -EventID 100 -Level Fatal -Method Console
                    Exit
                }

                $data = $data + $returnedData.objects
            }while($returnedData.meta.next)
        
        }
    }else{
        $data = ConvertFrom-Json -InputObject '{"meta": {"limit": 20, "next": null, "offset": 0, "previous": null, "total_count": 2}, "objects": [{"address": "", "city": "", "country": "", "custom1": "", "custom2": "","custom3": "", "email": "", "first_name": "", "id": 5, "last_name": "", "mobile_number": "", "phone_number": "", "resource_uri": "/api/v1/localusers/5/", "state": "","token_auth": false, "token_serial": "", "token_type": null, "user_groups":["/api/v1/usergroups/9/", "/api/v1/usergroups/8/"], "username": "test_user2"},{"address": "", "city": "", "country": "", "custom1": "", "custom2": "", "custom3":"", "email": "", "first_name": "", "id": 4, "last_name": "", "mobile_number": "","phone_number": "", "resource_uri": "/api/v1/localusers/4/", "state": "", "token_auth": false, "token_serial": "", "token_type": null, "user_groups":["/api/v1/usergroups/8/"], "username": "test_user"}]}'
        $data = $data.objects
    }
    Write-Output $data
}

Function Set-User {
    Param($ID,$Server,$Resource,$Credentials, $TokenAuth, $TokenSerial, $TokenType)
}

Function New-User {
    Param(
        [string]$UserName,
        [string]$Password,
        [string]$FirstName,
        [string]$LastName,
        [string]$UserGroups,
        [string]$TokenType="ftk",
        [string]$TokenSerial,
        [string]$Server,
        [string]$Resource,
        [securestring]$Credentials,
        $UserList,
        $TokenList,
        $GroupList
        )

    <#
        ?Call New-Token and add token to system?
        ?check if on other servers?
    #>
    $TokenFound = $false
    $UserList | ForEach-Object {
        if($TokenSerial -match $_.token_serial){
            $TokenFound = $true
            # Remove/Unassign token
            Remove-TokenFromUser $_.id -Server $Server -Resource $Resource -Credentials $Credentials
            # There shouldn't ever be one token assigned to more than one user
            break
        }
    }

    <#
        ?call set-user and change what is different?
        ?Remove user to make way for new user?
    #>
    $UserFound = $false
    $UserList | ForEach-Object {
        if($UserName -match $_.username){
            $UserFound = $true
            # Remove-User -ID $_.id -Server $Server -Resource $Resource -Credentials $Credentials
            break
        }
    }
    # Sample Imput json data: {"username":"test_user3","password":"testpassword","email":"test_user3@example.com","mobile":"+44-1234567890"}
    $Body = {
        username=$UserName;
        #password="testpassword";
        first_name=$FirstName;
        last_name=$LastName;
        user_groups=$UserGroups;
        token_type=$TokenType;
        token_serial=$TokenSerial;
        ftk_only="false";
        token_auth="false";
    }
    if($TokenSerial -or $TokenType -match "ftk"){
        $Body.ftk_only = "true"
        $Body.token_auth = "true"
    }

    $returnedData = Invoke-RestMethod -Method Post -Body $Body -Uri "$Resource/usergroups/" -Credential $Credentials -Headers @{"Accept"="application/json"} -ErrorVariable $e
    if($e){
        Write-Log -Message "Exitting, error in getting usergroups from $Server : $e" -EventID 100 -Level Fatal -Method Console
        Exit
    }
}

Function Get-UserGroups {
    Param($Server,$Resource,$Credentials)
    $returnedData = Invoke-RestMethod -Method Get -Uri "$Resource/usergroups/" -Credential $Credentials -Headers @{"Accept"="application/json"} -ErrorVariable $e
    if($e){
        Write-Log -Message "Exitting, error in getting usergroups from $Server : $e" -EventID 100 -Level Fatal -Method Console
        Exit
    }
    $data = $returnedData.objects
    if($returnedData.meta){
        do{
            $returnedData = Invoke-RestMethod -Method Get -Uri "$($Server)$($returnedData.meta.next)" -Credential $Credentials -Headers @{"Accept"="application/json"} -ErrorVariable $e
            if($e){
                Write-Log -Message "Exitting, error in getting usergroups from $Server : $e" -EventID 100 -Level Fatal -Method Console
                Exit
            }

            $data = $data + $returnedData.objects
        }while($returnedData.meta.next)
    
    }
    Write-Output $data
}

Function Add-UserToGroup {
    Param($GroupID,$UserID,$Server,$Resource,$Credentials)
}

#endregion

#region -----------------------------------------------------------[Execution]------------------------------------------------------------

Begin {
    #initalizing variables and setting up things to be run, such as importing data or connecting to databases
    Write-Log -Message "Started..." -EventID 0
	$resource = "/api/v1/"
	if($Crediential){
		$mycreds = $Crediential
        Export-Clixml -Path $StoredCredential -InputObject $mycreds
	}elseif($Username -and $APIKey){
		$secpasswd = ConvertTo-SecureString $APIKey -AsPlainText -Force
		$mycreds = New-Object System.Management.Automation.PSCredential ($Username, $secpasswd)
        Export-Clixml -Path $StoredCredential -InputObject $mycreds
	}else{
        if($PSScriptRoot -and $(Test-Path -Path $StoredCredential)){
            $mycreds = Import-Clixml -Path $StoredCredential
        }else{
            $mycreds = Get-Credential -Message "Username and API Key as the APIKey"
            Export-Clixml -Path $StoredCredential -InputObject $mycreds
        }
		
	}
    
    # Server URI building
    $Server = "https://$Address"
    # Import data from $File
    $ImportData = Import-Csv -Path $File

}
Process {

    try{
        # Test if we can connect to the server
        Invoke-RestMethod -Method Get -Uri "$($Server)$($resource)" -Credential $mycreds -Headers @{"Accept"="application/json"}
    }catch{
        Write-Error -Exception "Server Not Found" -Message "Can not connect to server" -Category ConnectionError -ErrorId 101
        Exit
    }
    # Get all tokens from server
    $Tokens = Get-Tokens -Server $Server -Resource $resource -Credentials $mycreds
    # Get all users from server
    $Users = Get-Users -Server $Server -Resource $resource -Credentials $mycreds
    # Get all user groups from server
    $Groups = Get-UserGroups -Server $Server -Resource $resource -Credentials $mycreds
    # Unassign token from user
    Remove-TokenFromUser -ID $ID -Server $Server -Resource $Resource -Credentials $Credentials
}
End {
    #clean up any variables, closing connection to databases, or exporting data
    If ($?) {
        Write-Log -Message 'Completed Successfully.' -EventID 101
    }
}
#endregion
