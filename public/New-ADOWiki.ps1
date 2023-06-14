function new-adowiki{
    param(
        $ProjectName,
        $wikiName,
        $projectid,
        $repositoryid
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
        $uri = "https://dev.azure.com/$($ADOAccount)/$($ProjectName)/_apis/wiki/wikis?api-version=7.0"
        $body= @"
        {
            "version": {
              "version": "wikiMaster"
            },
            "type": "codeWiki",
            "name": "$($wikiName)",
            "projectId": "$($projectid)",
            "repositoryId": "$($repositoryId)",
            "mappedPath": "/"
        }
"@
        $result = Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -body $body
    }
    end{
        return $result
    }
}