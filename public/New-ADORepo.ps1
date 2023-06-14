function new-adorepo{
    param(
        $ProjectName,
        $RepoName
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
        $uri = "https://dev.azure.com/$($ADOAccount)/$($ProjectName)/_apis/git/repositories?api-version=7.1-preview.1"
        $body= @"
        {
            "name": "$($RepoName)"
        }
"@
        $result = Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -body $body
    }
    end{
        return $result
    }
}