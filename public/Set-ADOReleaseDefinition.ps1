function set-adoreleasedefinition{
    param(
        [parameter(Mandatory)]$ReleaseDefinitionJSON
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
        $uri = "https://vsrm.dev.azure.com/$($ADOAccount)/$($ADOprojectName)/_apis/release/definitions?api-version=6.1-preview.4"
        $result = Invoke-RestMethod -Uri $uri -Method Put -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Body $releaseDefinitionJson
    }
    end {
        return ($result )
    } 
}