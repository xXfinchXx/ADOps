function get-adoreleases{
    param(
        $releasedefinitionname,
        $ADOprojectName,
        $releaseid,
        $latest
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
        if ($latest){
            $top='$top'
            if (!($Releaseid)){$releaselist = get-adoreleasedefinitions -ADOprojectName $ADOprojectName | Where name -match $releasedefinitionname
                $uri="https://vsrm.dev.azure.com/$($ADOAccount)/$($ADOprojectName)/_apis/release/releases?definitionId=$($releaselist.id)&$top=$latest"}
                else{$uri="https://vsrm.dev.azure.com/$($ADOAccount)/$($ADOprojectName)/_apis/release/releases?definitionId=$($releaseid)&$top=$latest"}
        
        }else{
            $top='$top'
            Write-host "Showing the latest 10 releases"
            if (!($Releaseid)){$releaselist = get-adoreleasedefinitions -ADOprojectName $ADOprojectName | Where name -match $releasedefinitionname
            $uri="https://vsrm.dev.azure.com/$($ADOAccount)/$($ADOprojectName)/_apis/release/releases?definitionId=$($releaselist.id)&$top=10"}
            else{$uri="https://vsrm.dev.azure.com/$($ADOAccount)/$($ADOprojectName)/_apis/release/releases?definitionId=$($releaseid)&$top=10"}
        }    
        $result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
    }
    end{
        return $result.value
    }
}