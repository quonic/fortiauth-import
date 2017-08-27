function Invoke-FortiAuthRestMethod
{
    #[CmdletBinding()]
    Param(
        [Parameter(Position = 0, Mandatory)]
        [string]
        $Resource,
        [ValidateSet("Get", "Post", "Delete")] # TODO: Add more at a later date
        [string]
        $Method,
        [hashtable]
        $Options,
        [hashtable]
        $Body
    )
    if ($null -ne $Script:FortiAuth)
    {
        # Check if we even have a ticket
        Write-Error "Please connect using Connect-FortiAuth."
        return $false
    }
    # Code from other project that might be useful at a later date.
    #     It's used to get a new session ticket.
    # if ((Get-Date).Ticks -le $Script:FortiAuth.Expire)
    # {
    #     Connect-PveServer -Server $Script:FortiAuth.Server
    # }

    # Bypass ssl checking or servers without a public cert or internal CA cert
    if ($Script:FortiAuth.BypassSSLCheck)
    {
        $CertificatePolicy = GetCertificatePolicy
        SetCertificatePolicy -Func (GetTrustAllCertsPolicy)
    }

    # Setup Headers and cookie for splatting
    switch ($Method)
    {
        Get { $splat = PrepareGetRequest }
        Post { $splat = PreparePostRequest($Body) }
        Delete { $splat = PrepareGetRequest }
        Patch { $splat = PreparePatchRequest($Body)}
        Default { $splat = PrepareGetRequest }
    }

    $Query = "?"
    If ($Options)
    {
        $Options.keys | ForEach-Object {
            $Query = $Query + "$_=$($Options[$_])&"
        }
        $Query = $Query.TrimEnd("&")
    }
    else
    {
        $Query = ""
    }

    $Uri = "https://$($Script:FortiAuth.Server)/api/v1$($Resource)"

    $response = Invoke-RestMethod -Uri "$($Uri)$($Query)" -Credential $(Import-Clixml -Path $Script:FortiAuth.StoredCredential) @splat -ErrorVariable $e
    if ($e)
    {
        return $false
    }


    if ($Script:FortiAuth.BypassSSLCheck)
    {
        # restore original cert policy
        SetCertificatePolicy -Func $CertificatePolicy
    }

    return $response.data
}

function PreparePatchRequest ($Body)
{
    $request = New-Object -TypeName PSCustomObject -Property @{
        Method      = "Patch"
        Headers     = @{"Accept" = "application/json"}
        Body        = $Body
        ContentType = "application/json"
    }
    return $request
}
function PreparePostRequest($Body)
{
    $request = New-Object -TypeName PSCustomObject -Property @{
        Method      = "Post"
        Headers     = @{"Accept" = "application/json"}
        Body        = $Body
        ContentType = "application/json"
    }
    return $request
}

function PrepareGetRequest()
{
    $request = @{
        Method      = "Get"
        Headers     = @{"Accept" = "application/json"}
        ContentType = "application/json"
    }
    return $request
}

function PrepareDeleteRequest()
{
    # $cookie = New-Object System.Net.Cookie -Property @{
    #     Name   = "AuthCookie"
    #     Path   = "/"
    #     Domain = $Script:FortiAuth.Server
    #     Value  = $Script:FortiAuth.Ticket
    # }
    # $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    # $session.cookies.add($cookie)
    $request = New-Object -TypeName PSCustomObject -Property @{
        Method      = "Delete"
        #Headers    = @{CSRFPreventionToken = $Script:FortiAuth.CSRFPreventionToken}
        Headers     = @{"Accept" = "application/json"}
        #WebSession = $session
        ContentType = "application/json"
    }
    return $request
}