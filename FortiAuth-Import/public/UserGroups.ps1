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
        $returnedData = Invoke-FortiAuthRestMethod -Resource "usergroups/$($Id)/" -Method Get
        $data = $returnedData.objects
        return $data
    }
    elseif ($Name)
    {
        $returnedData = Invoke-FortiAuthRestMethod -Resource "usergroups/" -Method Get
        $data = $returnedData.objects
        if ($returnedData.meta)
        {
            do
            {
                $returnedData = Invoke-FortiAuthRestMethod -Resource $returnedData.meta.next -Method Get
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
        [ValidateNotNullOrEmpty()]
        $GroupID,
        [ValidateNotNullOrEmpty()]
        $UserID
    )
    $UserList = (Get-UserGroup -Id $GroupID).Id

    # Create data object that will be output, and new user(s) to current list
    $Data = @{users = $UserList}
    $Data.users = $Data.users + $UserID
    $Data.users = $Data.users | ForEach-Object {
        "/api/v1/localusers/$($_)/"
    }

    $returnedData = Invoke-FortiAuthRestMethod -Resource "usergroups/$($GroupID)/" -Method Patch -Body $Data
    return $returnedData
}

Export-ModuleMember -Cmdlet Add-UserToGroup, Get-UserGroup