function get-adorelease{
    param(
        $releasedefinitionname,
        $Releaseid
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
        if (!($releaseid)){
            $releaseinfo = Get-ADOreleases -releaseDefinitionname $releasedefinitionname
            Get-ADOReleases | select ID,name,description
            $release = Read-host -Prompt "Which one of the above releases would you like to see? Please Enter ID from Left Column"
            $Releaseid = ($releaseinfo | Where id -match $Release).id
        }
        $uri = "https://vsrm.dev.azure.com/$($ADOAccount)/$($ADOprojectName)/_apis/release/releases/$($releaseid)?api-version=6.1-preview.8"
        $result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
    }
    end{
        return $result
    }
}