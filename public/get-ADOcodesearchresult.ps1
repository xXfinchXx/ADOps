#For a custom filter follow json contruction here:https://learn.microsoft.com/en-us/rest/api/azure/devops/search/code-search-results/fetch-code-search-results?view=azure-devops-rest-7.1&tabs=HTTP#examples

function get-ADOcodesearchresult {
    Param(
        $projectName,
        $repositoryName,
        $Branch,
        $texttofind,
        $advancedFilter

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
        $body=@{
            searchText= $texttofind
            '$top'= 1000
            filters=@{
                Project=@($projectName)
                Repository=@($repositoryName)
                Branch=@($Branch)
            }
        }
        $advancedFilter = $jsonbody
        
        $final =invoke-restmethod -method POST -uri "https://almsearch.dev.azure.com/${ADOAccount}/${projectName}/_apis/search/codesearchresults?api-version=7.1-preview.1" -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Body ($body|ConvertTo-Json)
    }
    end{
        $final
    }
}