function get-adobuild {
    Param(
       [Parameter(Mandatory)][string]$buildDefID,
       $latest,
       $ADOprojectName
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
      if (!($latest)){
         $top='$top'
         $uri = "https://dev.azure.com/$($ADOaccount)/$($ADOprojectName)/_apis/build/builds?definitions=$($BuildDefID)&$top=10"
      }else{
         $top='$top'
         $uri = "https://dev.azure.com/$($ADOaccount)/$($ADOprojectName)/_apis/build/builds?definitions=$($BuildDefID)&$top=$($latest)"
      }       
      $result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
   }
   end {
      return ($result.value | Select @{l='DefinitionName';e={$_.definition.name}}, @{l='DefinitionID';e={$_.definition.id}},buildNumber,id,status,result,reason,sourcebranch,sourceversion,queuetime,starttime,finishtime)
   }
}   