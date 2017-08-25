Function Get-UserGroup
{
    Param(
        [ValidateNotNullOrEmpty()]
        $Name,
        [ValidateNotNullOrEmpty()]
        $Id
    )
    if ($Id)
    {
        $returnedData = callREST -Resource "usergroups/$($Id)/" -Method Get
        $data = $returnedData.objects
        return $data
    }
    elseif ($Name)
    {
        $returnedData = callREST -Resource "usergroups/" -Method Get
        $data = $returnedData.objects
        if ($returnedData.meta)
        {
            do
            {
                $returnedData = callREST -Resource "usergroups/$($returnedData.meta.next)" -Method Get
                $data = $data + $returnedData.objects
            }while ($returnedData.meta.next)

        }
        $data | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.Name
                Id   = $_.idtype
            }
        }
        return $data
    }
    else
    {
        Write-Log -Message "Group $Name$Id not found" -EventID 100 -Level Error -Method $Script:FortiAuth.LogMethod
        return $false
    }

}

Function Add-UserToGroup
{
    Param(
        [int]
        $GroupID,
        [int[]]
        $UserID,
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,
        [ValidateNotNullOrEmpty()]
        $Resource,
        [SecureString]
        $Credentials
    )
    $UserList = Get-UserGroup -Id $GroupID -Server $Server -Resource $Resource -Credentials $Credentials
    $UserList += $UserID


    $Script:rtn = "{'users':["
    #$Users = $UserList | ForEach-Object {
    $UserList | ForEach-Object {
        $Script:rtn += "'/api/v1/localusers/$($_)/',"
    }
    $Script:rtn = $Script:rtn.TrimEnd(1)
    $Script:rtn += "]}"

    $returnedData = callREST -Resource "usergroups/$($GroupID)/" -Method Patch -Body $Script:rtn
    $Script:rtn = $null
    return $returnedData
}

Export-ModuleMember -Cmdlet ["Add-UserToGroup", "Get-UserGroup"]