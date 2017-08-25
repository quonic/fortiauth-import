Function Get-Token
{
    Param(
        [ValidateNotNullOrEmpty()]
        $Server,
        [ValidateNotNullOrEmpty()]
        $Resource,
        [SecureString]
        $Credentials
    )
    $response = callREST -Resource "fortitokens/" -Method Get -Options @{ limit = 1 }
    if ($response.meta.total_count -gt 10)
    {
        return callREST -Resource "fortitokens/" -Method Get -Options @{ limit = $($response.meta.total_count) }
    }
    else
    {
        $response = callREST -Resource "fortitokens/" -Method Get
        $data = $returnedData.objects
        if ($returnedData.meta)
        {
            do
            {
                $returnedData = callREST -Resource "fortitokens/$($returnedData.meta.next)" -Method Get
                $data = $data + $returnedData.objects
            }while ($returnedData.meta.next)
        }
        return $data
    }
}

Export-ModuleMember -Cmdlet "Get-Token"