function get-adodeploymentgroups {
   Param(
      $ADOproject
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
   process {
      if($adoproject){$ADOprojectName = $adoproject}
      $uri = "https://dev.azure.com/$($ADOAccount)/$($ADOprojectName)/_apis/distributedtask/deploymentgroups?api-version=7.1-preview.1"
      $result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
   }
   end {
      return ($result.value)
   }   
}