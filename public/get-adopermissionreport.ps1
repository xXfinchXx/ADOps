function get-adopermissionreport {
    Param(
       [Parameter(Mandatory)][string]$reportid
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
        $final =invoke-restmethod -method Get -uri "https://dev.azure.com/${ADOAccount}/_apis/permissionsreport/$($Reportid)/download?api-version=6.0-preview.1" -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
    }
    end{
        $final=($final -replace 'ï»¿','')
        $answer=Read-Host 'Output is raw JSON format. Would you like to Convert it now?(Y|N)'
        if ($answer -match 'y'){
            $final | ConvertFrom-Json -Depth 10
        }else{
            $final
        }
    }
}    