function get-adoreleasedefinition {
   Param(
      [Parameter(Mandatory)][string]$ReleaseDefinitionID,
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
   process{
      if ($ADOproject){$ADOprojectName = $ADOproject}
      $uri = "https://vsrm.dev.azure.com/$($ADOaccount)/$($ADOprojectname)/_apis/release/definitions/$($ReleaseDefinitionID)?api-version=7.1-preview.4"
      $result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
   }
   end{
      return ($result )
   }
}