function clone-adobuild {
    param(
        $builddefinitionname,
        $builddefinitionid
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
        if ($builddefinitionname){
            $definitionToCloneId = (Get-ADOBuildDefinitions | Where name -Match $builddefinitionname).id
        }else{
            $definitionToCloneId = (Get-ADOBuild -builddefinitionid $builddefinitionid).id
        }    
        $URL="https://dev.azure.com/${adoaccount}/${adoprojectname}/_apis/build/definitions?definitionToCloneId=${definitionToCloneId}&api-version=6.0-preview.7"
        $final=Invoke-RestMethod -Uri $URL -Method Post -Body $Body -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}  
        
    }
    end{
        return $final
    } 
}