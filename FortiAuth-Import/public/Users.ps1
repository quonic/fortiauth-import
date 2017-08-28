Function Remove-TokenFromUser
{
    [CmdletBindings()]
    Param(
        [ValidateNotNullOrEmpty()]
        $ID
    )
    Set-User -ID $ID -TokenAuth $false -TokenSerial "" -TokenType ""
}

Function Get-User
{
    Param(
    )
    $returnedData = Invoke-FortiAuthRestMethod -Resource "localusers/" -Method Get

    $data = $returnedData.objects
    if ($returnedData.meta)
    {
        do
        {
            $returnedData = Invoke-FortiAuthRestMethod -Resource "localusers/$($returnedData.meta.next)" -Method Get
            $data = $data + $returnedData.objects
        }while ($returnedData.meta.next)

    }
    return $data
}

<#
.SYNOPSIS
Changes User information

.DESCRIPTION
Changes User Information, such as Token, Password, Last Name, Email, etc.

.PARAMETER ID
ID of user in the server's database, can be found with Get-User.

.PARAMETER TokenAuth
If true, then the user will be using a token.

.PARAMETER TokenSerial
The serial number of the token.

.PARAMETER TokenType
The type of token that will be used, accepts ftk, ftm, email, or sms.

.PARAMETER Passcode
The passcode or password for user authentication.

.PARAMETER Expire
The number of days till the account expires, used with Passcode/Password. Note: the api requires ISO-8601 formatted user expiration time in UTC, but this is taken care of.

.PARAMETER MobileNumber
Mobile number for sms resets.

.PARAMETER Email
Email of the user.

.PARAMETER Active
If set then the user account is active.

.PARAMETER FirstName
First Name of user.

.PARAMETER LastName
Last Name of user.

.PARAMETER Address
Address of user.

.PARAMETER City
City of user.

.PARAMETER State
State of user.

.PARAMETER Country
Country of user. Note: Must be a country code from ISO-3166 list, but this is in the Parrameter Set.

.PARAMETER Custom1
Custom1 of user.

.PARAMETER Custom2
Custom2 of user.

.PARAMETER Custom3
Custom3 of user.

.EXAMPLE
Set-User -ID '1' -TokenAuth -TokenSerial "abcdef123456789" -TokenType ftk -Active

.NOTES
General notes
#>
Function Set-User
{
    #[CmdletBindings()]
    Param(
        [ValidateNotNullOrEmpty()]
        $ID,
        [Parameter(
            Mandatory = $True,
            ParameterSetName = "Token"
        )]
        [switch]
        $TokenAuth,
        [Parameter(
            Mandatory = $False,
            ParameterSetName = "Token"
        )]
        $TokenSerial,
        [Parameter(
            Mandatory = $True,
            ParameterSetName = "Token"
        )]
        [Parameter(
            Mandatory = $False,
            ParameterSetName = "SMS"
        )]
        [Parameter(
            Mandatory = $False,
            ParameterSetName = "Email"
        )]
        [ValidateSet("ftk", "ftm", "email", "sms")]
        $TokenType,
        [Parameter(
            Mandatory = $True,
            ParameterSetName = "Passcode"
        )]
        [Alias("Password")]
        $Passcode,
        [Parameter(
            Mandatory = $False,
            ParameterSetName = "Passcode"
        )]
        [int]
        $Expire = 60,
        [Parameter(
            Mandatory = $True,
            ParameterSetName = "SMS"
        )]
        [ValidateLength(4, 25)]
        [ValidatePattern("\+\d{1,6}\-\d{4,20}")]
        [string]
        $MobileNumber,
        [Parameter(
            Mandatory = $True,
            ParameterSetName = "Email"
        )]
        [string]
        $Email,
        [switch]
        $Active,
        [ValidateLength(0, 30)]
        [string]
        $FirstName,
        [ValidateLength(0, 30)]
        [string]
        $LastName,
        [ValidateLength(0, 80)]
        [string]
        $Address,
        [ValidateLength(0, 40)]
        [string]
        $City,
        [ValidateLength(0, 40)]
        [string]
        $State,
        [ValidateSet(
            'AX', 'AF', 'AL', 'DZ', 'AS', 'AD', 'AO', 'AI', 'AQ', 'AG', 'AR', 'AM', 'AW', 'AU', 'AT', 'AZ', 'BS', 'BH', 'BD', 'BB', 'BY', 'BE', 'BZ', 'BJ', 'BM', 'BT', 'BO',
            'BA', 'BW', 'BV', 'BR', 'IO', 'BN', 'BG', 'BF', 'BI', 'KH', 'CM', 'CA', 'CV', 'KY', 'CF', 'TD', 'CL', 'CN', 'CX', 'CC', 'CO', 'KM', 'CD', 'CG', 'CK', 'CR', 'CI',
            'HR', 'CU', 'CY', 'CZ', 'DK', 'DJ', 'DM', 'DO', 'EC', 'EG', 'SV', 'GQ', 'ER', 'EE', 'ET', 'FK', 'FO', 'FJ', 'FI', 'FR', 'GF', 'PF', 'TF', 'GA', 'GM', 'GE', 'DE',
            'GH', 'GI', 'GR', 'GL', 'GD', 'GP', 'GU', 'GT', 'GN', 'GW', 'GY', 'HT', 'HM', 'HN', 'HK', 'HU', 'IS', 'IN', 'ID', 'IR', 'IQ', 'IE', 'IL', 'IT', 'JM', 'JP', 'JO',
            'KZ', 'KE', 'KI', 'KP', 'KR', 'KW', 'KG', 'LA', 'LV', 'LB', 'LS', 'LR', 'LY', 'LI', 'LT', 'LU', 'MO', 'MK', 'MG', 'MW', 'MY', 'MV', 'ML', 'MT', 'MH', 'MQ', 'MR',
            'MU', 'YT', 'MX', 'FM', 'MD', 'MC', 'MN', 'MS', 'MA', 'MZ', 'MM', 'NA', 'NR', 'NP', 'NL', 'AN', 'NC', 'NZ', 'NI', 'NE', 'NG', 'NU', 'NF', 'MP', 'NO', 'OM', 'PK',
            'PW', 'PS', 'PA', 'PG', 'PY', 'PE', 'PH', 'PN', 'PL', 'PT', 'PR', 'QA', 'RE', 'RO', 'RU', 'RW', 'SH', 'KN', 'LC', 'PM', 'VC', 'WS', 'SM', 'ST', 'SA', 'SN', 'CS',
            'SC', 'SL', 'SG', 'SK', 'SI', 'SB', 'SO', 'ZA', 'GS', 'ES', 'LK', 'SD', 'SR', 'SJ', 'SZ', 'SE', 'CH', 'SY', 'TW', 'TJ', 'TZ', 'TH', 'TL', 'TG', 'TK', 'TO', 'TT',
            'TN', 'TR', 'TM', 'TC', 'TV', 'UG', 'UA', 'AE', 'GB', 'US', 'UM', 'UY', 'UZ', 'VU', 'VA', 'VE', 'VN', 'VG', 'VI', 'WF', 'EH', 'YE', 'ZM', 'ZW')]
        [string]
        $Country,
        [ValidateLength(0, 255)]
        [string]
        $Custom1,
        [ValidateLength(0, 255)]
        [string]
        $Custom2,
        [ValidateLength(0, 255)]
        [string]
        $Custom3
    )
    $Body = @{
        active = $Active
    }
    if ($TokenAuth)
    {
        if ($TokenType -like "ftk" -or $TokenType -like "ftm")
        {
            $Body.token_serial = $TokenSerial
            $Body.token_auth = $TokenAuth
            $Body.ftk_only = $True
        }
        elseif ($TokenType -like "sms")
        {
            $Body.mobile_number = $MobileNumber
        }
        elseif ($TokenType -like "email")
        {
            $Body.email = $Email
        }
        $Body.token_type = $TokenType
    }
    if ($Passcode)
    {
        $Body.password = $Passcode
        $Body.expires_at = (Get-Date).AddDays($Expire).ToUniversalTime() | Get-Date -format s
    }
    if ($FirstName) {$Body.first_name = $FirstName}
    if ($LastName) {$Body.last_name = $LastName}
    if ($Address) {$Body.address = $Address}
    if ($City) {$Body.city = $City}
    if ($State) {$Body.state = $State}
    if ($Country) {$Body.country = $Country}
    if ($Custom1) {$Body.custom1 = $Custom1}
    if ($Custom2) {$Body.custom2 = $Custom2}
    if ($Custom3) {$Body.custom3 = $Custom3}

    Invoke-FortiAuthRestMethod -Resource "localusers/$($ID)/" -Method Patch -Body $Body

}

Function Register-User
{
    [CmdletBindings()]
    Param(
        [string]$UserName,
        #[string]$Password,
        [string]$FirstName,
        [string]$LastName,
        [string]$UserGroups,
        [string]$TokenType = "ftk",
        [string]$TokenSerial
    )

    <#
        ?Call New-Token and add token to system?
        ?check if on other servers?
    #>
    $UserList = Get-User
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

    $returnedData = Invoke-FortiAuthRestMethod -Resource "usergroups/" -Method Post -Body $Body
    return $returnedData
}

Export-ModuleMember -Cmdlet ["Remove-TokenFromUser", "Get-Users", "Set-User", "New-User"]