Function Get-Token
{
    Param(
        [string]
        $Token
    )
    $response = Invoke-FortiAuthRestMethod -Resource "fortitokens/" -Method Get -Options @{ limit = 1 }
    if ($response.meta.total_count -gt 10)
    {
        return Invoke-FortiAuthRestMethod -Resource "fortitokens/" -Method Get -Options @{ limit = $($response.meta.total_count) }
    }
    else
    {
        $response = Invoke-FortiAuthRestMethod -Resource "fortitokens/" -Method Get
        $data = $returnedData.objects
        if ($returnedData.meta)
        {
            do
            {
                $returnedData = Invoke-FortiAuthRestMethod -Resource $returnedData.meta.next -Method Get
                $data = $data + $returnedData.objects
            }while ($returnedData.meta.next)
        }
        return $data
    }
}

Export-ModuleMember -Cmdlet Get-Token