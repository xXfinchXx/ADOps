function list-adobuildartifacts {
    Param(
       [Parameter(Mandatory)][string]$buildID
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
      $uri = "https://dev.azure.com/$($ADOAccount)/$($ADOprojectName)/_apis/build/builds/$($BuildID)/artifacts"
      $result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
   }
   end{ 
      return ($result.value | Select name,id,@{l='Type';e={$_.resource.type}},@{l='data';e={$_.resource.data}},@{l='localpath';e={$_.resource.properties.localpath}},@{l='url';e={$_.resource.url}},@{l='downloadURL';e={$_.resource.downloadURL}})
   }
}