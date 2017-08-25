Function Remove-TokenFromUser
{
    [CmdletBindings(SupportsShouldProcess = $true,
        ConfirmImpact = "Low")]
    Param(
        [ValidateNotNullOrEmpty()]
        $ID
    )
    if ($pscmdlet.ShouldContinue("Do the thing"))
    {
        # Do nothing
    }
    Set-User -ID $ID -TokenAuth $false -TokenSerial "" -TokenType ""
}

Function Get-User
{
    Param(
    )
    $returnedData = callREST -Resource "localusers/" -Method Get

    $data = $returnedData.objects
    if ($returnedData.meta)
    {
        do
        {
            $returnedData = callREST -Resource "localusers/$($returnedData.meta.next)" -Method Get
            $data = $data + $returnedData.objects
        }while ($returnedData.meta.next)

    }
    return $data
}

Function Set-User
{
    [CmdletBindings(SupportsShouldProcess = $true,
        ConfirmImpact = "Low")]
    Param(
        [ValidateNotNullOrEmpty()]
        $ID,
        [ValidateNotNullOrEmpty()]
        $TokenAuth,
        [ValidateNotNullOrEmpty()]
        $TokenSerial,
        [ValidateNotNullOrEmpty()]
        $TokenType
    )
    if ($pscmdlet.ShouldContinue("Do the thing"))
    {
        # Do nothing
    }
}

Function Register-User
{
    # This is know, but this is required per the API
    #[Syetem.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "PSAvoidUsingUserNameAndPassWordParams", "")]
    [CmdletBindings(SupportsShouldProcess = $true,
        ConfirmImpact = "Low")]
    Param(
        [string]$UserName,
        #[string]$Password,
        [string]$FirstName,
        [string]$LastName,
        [string]$UserGroups,
        [string]$TokenType = "ftk",
        [string]$TokenSerial,
        $UserList,
        $TokenList,
        $GroupList,
        $ConfirmPreference
    )

    if ($pscmdlet.ShouldContinue("Do the thing"))
    {
        # Do nothing
    }

    <#
        ?Call New-Token and add token to system?
        ?check if on other servers?
    #>
    $UserList | ForEach-Object {
        if ($TokenSerial -match $_.token_serial)
        {
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
    $UserList | ForEach-Object {
        if ($UserName -match $_.username)
        {
            # Remove-User -ID $_.id -Server $Server -Resource $Resource -Credentials $Credentials
            return @{UserFound = $true}
        }
    }
    # Sample Imput json data: {"username":"test_user3","password":"testpassword","email":"test_user3@example.com","mobile":"+44-1234567890"}
    $Body = @{
        username     = $UserName;
        #password="testpassword";
        first_name   = $FirstName;
        last_name    = $LastName;
        user_groups  = $UserGroups;
        token_type   = $TokenType;
        token_serial = $TokenSerial;
        ftk_only     = "false";
        token_auth   = "false";
    }
    if ($TokenSerial -or $TokenType -match "ftk")
    {
        $Body.ftk_only = "true"
        $Body.token_auth = "true"
    }

    $returnedData = callREST -Resource "usergroups/" -Method Post -Body $Body
    return $returnedData
}

Export-ModuleMember -Cmdlet ["Remove-TokenFromUser", "Get-Users", "Set-User", "New-User"]