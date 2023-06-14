function import-adorepo {
    Param(
        $projectName,
        $RepotoImportURL,
        $RepotoImportName
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
        $body = @"
        {
            "parameters": {
              "gitSource": {
                "url": "$($RepotoImportURL -replace 'volcorp@',"volcorp:$($ADOpat)@")"
              }
            }
          }
"@          
        $final =invoke-restmethod -method Post -uri "https://dev.azure.com/$($ADOAccount)/$($projectName)/_apis/git/repositories/$($RepotoImportName)/importRequests?api-version=7.0" -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Body $body
    }
    end{
        $final
    }
}#muhvnwhdqllb5d3g77ytkeirfguv4xixev3m53jxdxc5s3lyqvlq