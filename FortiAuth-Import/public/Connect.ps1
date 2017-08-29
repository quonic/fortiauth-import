
<#
.SYNOPSIS
Create a new session to connect with a Fortinet Authenticator appliance

.DESCRIPTION
Long description

.EXAMPLE
Connect-FortiAuth -Server 10.0.0.10 -UserName "root" -APIKey "asdfghjklqwertyuio"

.EXAMPLE
To bypass an invalid certificate where you aren't using an internal CA
Connect-FortiAuth -Server 10.0.0.10 -UserName "root" -APIKey "asdfghjklqwertyuio" -BypassSSLCheck

.EXAMPLE
Connect-FortiAuth -Server 10.0.0.10 -Crediential (Get-Crediential)

.NOTES
General notes
#>
function Connect-FortiAuth
{
    [CmdletBindings()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [ValidateScript( { (Test-Connection -ComputerName $_ -Count 1 -ErrorAction Ignore) } )]
        $Server,
        [Parameter(Mandatory = $false)]
        [Alias("User", "Account")]
        [string]
        $UserName,
        [Parameter(Mandatory = $false)]
        [Alias("Key", "Password")]
        [string]
        $APIKey,
        [switch]
        $BypassSSLCheck,
        [pscredential]
        $Crediential,
        # Stored Credential Path
        [string]
        $Path = "$($MyInvocation.MyCommand.Path)/Credential.xml"
    )

    begin
    {
    }

    process
    {
        $Script:FortiAuth.Server = $Server
        $Script:FortiAuth.StoredCredential = "$($MyInvocation.MyCommand.Path)/Credential.xml"
        $Script:FortiAuth.BypassSSLCheck = $BypassSSLCheck

        if ($Crediential)
        {
            # Are we getting credentials?
            $mycreds = $Crediential
            Export-Clixml -Path $Script:FortiAuth.StoredCredential -InputObject $mycreds
        }
        elseif ($Username -and $APIKey)
        {
            # Are we makeing our credentials from raw username and apikey?
            $secpasswd = ConvertTo-SecureString $APIKey -AsPlainText -Force
            $mycreds = New-Object System.Management.Automation.PSCredential ($Username, $secpasswd)
            Export-Clixml -Path $Script:FortiAuth.StoredCredential -InputObject $mycreds
        }
        else
        {
            # Are we using the stored credentails?
            if ($PSScriptRoot -and $(Test-Path -Path $Script:FortiAuth.StoredCredential))
            {
                # Found stored credentials so nothing to do!
                #$mycreds = Import-Clixml -Path $Script:FortiAuth.StoredCredential
            }
            else
            {
                # No credetials nor username/apikey specified so prompt for them
                $mycreds = Get-Credential -Message "Username and API Key as the Password"
                Export-Clixml -Path $Script:FortiAuth.StoredCredential -InputObject $mycreds
            }

        }

        # Do a test connection to see if everything works or not.
        $response = Invoke-FortiAuthRestMethod -Resource "/" -Method Get
        if ($response)
        {
            # All is good.
        }
    }

    end
    {
    }
}

Export-ModuleMember -Cmdlet Connect-FortiAuth