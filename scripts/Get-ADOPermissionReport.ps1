set-adoconnection -ADOAccount -ADOprojectName -ADOpat
$repolist = get-adorepolist
$uri="https://dev.azure.com/${ADOAccount}/_apis/permissionsreport?api-version=6.0-preview.1"
$date = Get-Date -Format "yyyyMMddhhmm"
Foreach ($repo in $repolist){
 $json = [pscustomobject]@{
    descriptors=@() 
    reportname = "$($repo.name)-$($date)"
    resources = @(
        @{
            resourceId = $repo.id
            resourceName = $repo.name
            resourceType = 'repo'
        }
    )  
 }
 $body = $json | ConvertTo-Json
    $Create=Invoke-RestMethod -Method Post -Uri $uri -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Body $body
    $GETReport=$null
    while ($GETReport.reportStatus -notmatch "completedSuccessfully"){
        $GETReport= (invoke-restmethod -method Get -uri "https://dev.azure.com/${ADOAccount}/_apis/permissionsreport?api-version=6.0-preview.1" -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} ).value| Where {$_.reportname -Match $json.reportname}
    }
    $final =invoke-restmethod -method Get -uri "https://dev.azure.com/${ADOAccount}/_apis/permissionsreport/$($GetReport.id)/download?api-version=6.0-preview.1" -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
 }
 $Identities = ($final -replace 'ï»¿','') | ConvertFrom-Json
 $Report=[pscustomObject]@{
     Permissions=@(
         @{Path = "$($ADOProjectName)/$($Repo.name)"}
          @{Identities=@(
              foreach($i in $Identities){
                  [pscustomobject]@{
                      Identity=$i.displayname
                      AllowedPermissions=@(($i.Permissions| Where EffectivePermission -Match 'Allow').PermissionName)
                  }
              }
          )}        
     )
 }

 $Report | ConvertTo-Json -Depth 10 | Out-File C:\Temp\testfile.json
