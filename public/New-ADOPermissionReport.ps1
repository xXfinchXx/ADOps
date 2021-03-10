function new-adopermissionreport {
    Param(
       [Parameter(Mandatory)][string]$reportname,
       [Parameter(Mandatory)][validateset("collection","project",'projectGit','ref','release','repo','tfvc')]$resourceType,
       [Parameter(Mandatory)][string]$resourceid,
       [Parameter(Mandatory)][string]$resourcename
    )
    begin{
      if (!($ADOpat)){
          Write-Warning "Looks like you haven't set your connection yet. Let me help you with that."
          $projectName= Read-Host -Prompt 'What is your Azure DevOps Project Name?'
          $vstsAccount= Read-host -Prompt 'What is your Azure DevOps Account Name?'
          $PAT = Read-Host -Prompt 'What is your Azure DevOps PAT (Personal Access Token)?'
          Set-ADOconnection -ADOAccount $vstsAccount -ADOprojectName $projectName -ADOpat $PAT
      }
      $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $ADOUser,$ADOpat)))
   }
   process{
        $date=Get-Date -Format yyyyMMddhhmm
        $json = [pscustomobject]@{
            descriptors=@() 
            reportname = "$($reportname)-$($date)"
            resources = @(
                @{
                    resourceId = $resourceid
                    resourceName = $resourcename
                    resourceType = $resourceType
                }
            )  
        }
        $body = $json | ConvertTo-Json
        $Create=Invoke-RestMethod -Method Post -Uri $uri -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Body $body
        $GETReport=$null
    }
    end{        
        while ($GETReport.reportStatus -notmatch "completedSuccessfully"){
            $GETReport= (invoke-restmethod -method Get -uri "https://dev.azure.com/${ADOAccount}/_apis/permissionsreport?api-version=6.0-preview.1" -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} ).value| Where {$_.reportname -Match $json.reportname}
        }
        $GETReport
        Write-Host "Permission Report is ready for download"   
    }
}        