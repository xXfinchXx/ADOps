param(
    [string]$ADOAccount = "",
    [string]$ADOprojectName = "",
    [string]$ADOpat = "",
    [string]$searchRepoName = '',#Ability to narrow to specific list or regex. Update Line 20 for list with -in
    [string]$RootPath = ''#Root path to where report folders/files go
)
#Set Creds as Global Vars to easily Reuse within this session
$Global:ADOAccount = $ADOAccount
$Global:ADOProjectName = $ADOprojectName
$Global:ADOUser = ''
$Global:ADOpat = $ADOpat
#Storing creds as Base64
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $ADOUser,$ADOpat)))
#URL to Get the List of Git Repos
$uri = "https://dev.azure.com/$($ADOAccount)/$($ADOprojectName)/_apis/git/repositories"
$result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
#Checking if SearchRepoName was set in the params
if ($searchRepoName){
    $repolist=$result.value | Where name -Match "$($SearchRepoName)" 
}else{
    $repolist = $result.value
}
#URL for Permission Report Creation
$uri="https://dev.azure.com/${ADOAccount}/_apis/permissionsreport?api-version=6.1-preview.1"
#Need a tag to differentiate between each report of the same repo
$date = Get-Date -Format "yyyyMMddhhmm"

Foreach ($repo in $repolist){
    Write-host "Currently Working on $($Repo.name)"
    #Create a Json object for create action and for reuse in script
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
    #creating report here and storing in var for less noise
    $Create=Invoke-RestMethod -Method Post -Uri $uri -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Body $body
    #set GetReport to null so that the while loop works
    $GETReport=$null
    #Checking to see if the report is ready or not
    Write-Host "Waiting for report to return status: completedSuccessfully"
    while ($GETReport.reportStatus -notmatch "completedSuccessfully"){
        Start-Sleep -Seconds 5
        $GETReport= (invoke-restmethod -method Get -uri "https://dev.azure.com/${ADOAccount}/_apis/permissionsreport?api-version=6.0-preview.1" -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} ).value| Where {$_.reportname -Match $json.reportname}
    }
    #Report is ready for Download at this point so the Var Final is storing that report
    Write-Host "Report is ready for download. Starting Download now."
    $final =invoke-restmethod -method Get -uri "https://dev.azure.com/${ADOAccount}/_apis/permissionsreport/$($GetReport.id)/download?api-version=6.0-preview.1" -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
    #remove characters that shouldn't be there
    $Identities = ($final -replace 'ï»¿','') | ConvertFrom-Json
    #making the report to look like the current output
    Write-host "Converting Report to correct format"
    $Report=[pscustomObject]@{
        Permissions=@(
            @{Path = "$($ADOProjectName)/$($Repo.name)"}
            @{Identities=@(
                foreach($i in $Identities){
                    [pscustomobject]@{
                        Identity=$i.displayname
                        AllowedPermissions=@(($i.Permissions| Where EffectivePermission -Match 'Allow').PermissionName)
                    }
                }) 
            }        
        )
    }
    #Test to see if path exists and creates if it doesn't
    if (!(Test-Path "$($RootPath)\$($repo.name)")){mkdir "$($RootPath)\$($repo.name)";Write-Host "Directory Created for $($repo.name)"}
    #Convert report back to Json and outputs to Location with folders
    Write-Host "Saving report for $($repo.name) at $($RootPath)\$($repo.name)\$($json.reportname).json"
    $Report | ConvertTo-Json -Depth 10 | Out-File "$($RootPath)\$($repo.name)\$($json.reportname).json"
}