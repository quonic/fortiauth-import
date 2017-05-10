# MongoDB "Mdbc" installer
# Check for Mdbc and install if older or not installed
$MdbcInstalled = Get-Module Mdbc* -ListAvailable
if($MdbcInstalled){
    $PSGallaryMdbc = Find-Module -Name Mdbc
    if($MdbcInstalled.Version -eq $PSGallaryMdbc.Version){
        Write-Output "Lastest Mdbc Installed"
    }else{
        Write-Output "Updating Mdbc for CurrentUser"
        Write-Output "Install-Module -Name Mdbc -Scope CurrentUser"
        Install-Module -Name Mdbc -Scope CurrentUser
    }
}else{
    $MdbcModulesList = Get-Module Mdbc* -ListAvailable
    $MdbcModulesToRemove = @()
    if($MdbcModulesList){
        Write-Output "Installing Mdbc for CurrentUser"
        Write-Output "Install-Module -Name Mdbc -Scope CurrentUser"
        Install-Module -Name Mdbc -Scope CurrentUser
    }
}

Import-Module -Name Mdbc



# https://github.com/nightroman/Mdbc
Connect-Mdbc -ConnectionString

$routes = @{
    "/api/v1/localusers/" = { return '{
        "meta": {
            "limit": 20,
            "next": null,
            "offset": 0,
            "previous": null,
            "total_count": 2
        },
        "objects": [
            {
                "address": "",
                "city": "",
                "country": "",
                "custom1": "",
                "custom2": "",
                "custom3": "",
                "email": "",
                "first_name": "",
                "id": 1,
                "last_name": "",
                "mobile_number": "",
                "phone_number": "",
                "resource_uri": "/api/v1/localusers/5/",
                "state": "",
                "token_auth": false,
                "token_serial": "",
                "token_type": null,
                "user_groups":[
                    "/api/v1/usergroups/1/",
                    "/api/v1/usergroups/2/"
                    ],
                    "username": "test_user2"
                },
            {
                "address": "",
                "city": "",
                "country": "",
                "custom1": "",
                "custom2": "",
                "custom3":"",
                "email": "",
                "first_name": "",
                "id": 2,
                "last_name": "",
                "mobile_number": "",
                "phone_number": "",
                "resource_uri": "/api/v1/localusers/4/",
                "state": "",
                "token_auth": true,
                "token_serial": "/api/v1/fortitokens/1/",
                "token_type": "ftk",
                "user_groups":["/api/v1/usergroups/1/"],
                "username": "test_user"
            }
            ]
        }' }
    "/api/v1/fortitokens/" = { return '{
        "meta": {
            "limit": 20, "next": null, "offset": 0, "previous": null, "total_count": 2
        },
        "objects": [
            {
                "resource_uri": "/api/v1/fortitokens/1/",
                "serial": "FTK0000000000000",
                "status": "available",
                "type": "ftk"
            },
            {
                "resource_uri": "/api/v1/fortitokens/2/",
                "serial": "FTK0000000000001",
                "status": "available",
                "type": "ftk"
            }
            ]
        }' }
    "/api/v1/usergroups/" = '{
        "meta": {
            "limit": 20,
            "next": null,
            "offset": 0,
            "previous": null,
            "total_count": 1
        },
        "objects": [
            {
                "id": 1,
                "name": "Group888",
                "resource_uri": "/api/v1/usergroups/1/",
                "users": ["/api/v1/localusers/4/"]
            },
            {
                "id": 2,
                "name": "Group999",
                "resource_uri": "/api/v1/usergroups/2/",
                "users": ["/api/v1/localusers/4/","/api/v1/localusers/5/"]
            }
            ]
        }'


}

$url = 'http://localhost:80/'
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
$listener.Start()

Write-Host "Listening at $url..."

while ($listener.IsListening)
{
    $context = $listener.GetContext()
    $requestUrl = $context.Request.Url
    $response = $context.Response

    Write-Host ''
    Write-Host "> $requestUrl"

    $localPath = $requestUrl.LocalPath
    $route = $routes.Get_Item($requestUrl.LocalPath)

    if ($route -eq $null)
    {
        $response.StatusCode = 404
    }
    else
    {
        $content = & $route
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
        $response.ContentType = "application/json"
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
    }
    
    $response.Close()

    $responseStatus = $response.StatusCode
    Write-Host "< $responseStatus"
}