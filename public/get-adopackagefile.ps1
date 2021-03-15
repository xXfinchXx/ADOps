function get-adopackagefile {
    Param(
        [Parameter(Mandatory)][string]$feedid,
        [Parameter(Mandatory)][string]$packagename,
        [Parameter(Mandatory)][string]$packageversion,
        [Parameter(Mandatory)][string]$SaveTo
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
        invoke-restmethod -method Get -uri "https://dev.azure.com/${ADOAccount}/_apis/packaging/Feeds/$($feedid)/nuget/packages/$($packagename)/versions/$($packageversion)/content" -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -OutFile $SaveTo
    }
    end{
        Write-host "Saved Package ($($PackageName)) with version ($($Packageversion)) to $($SaveTo)"
    }
}