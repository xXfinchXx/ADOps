function deploy-adorelease{
    param(
        $releaseDefinitionName,
        $releaseId
    )
    begin{
        if (!($ADOpat)){
            Write-Warning "Looks like you haven't set your connection yet. Let me help you with that."
            $projectName = Read-Host -Prompt 'What is your Azure DevOps Project Name?'
            $vstsAccount = Read-Host -Prompt 'What is your Azure DevOps Account Name?'
            $PAT = Read-Host -Prompt 'What is your Azure DevOps PAT (Personal Access Token)?'
            Set-ADOconnection -ADOAccount $vstsAccount -ADOprojectName $projectName -ADOpat $PAT
        }
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $ADOUser, $ADOpat)))
    }
    process{
        if (!($releaseId)){
            $releaseInfo = Get-ADOreleases -releaseDefinitionName $releaseDefinitionName
            $releaseInfo | Select-Object ID, Name, Description
            $release = Read-Host -Prompt "Which one of the above releases would you like to manage? Please Enter ID from Left Column"
            $releaseId = ($releaseInfo | Where-Object { $_.id -eq $release }).id
        }

        $releaseTarget = Get-ADORelease -releaseId $releaseId
        $releaseTarget.environments.Name
        $envCheck = Read-Host -Prompt "What Environment would you like to deploy? Please select from the above list."
        $environmentInfo = $releaseTarget.environments | Where-Object { $_.name -eq $envCheck }
        $uri = "https://vsrm.dev.azure.com/$($ADOAccount)/$($ADOProjectname)/_apis/Release/releases/$($releaseTarget.id)/environments/$($environmentInfo.id)?api-version=6.1-preview.7"
        $body = [pscustomobject]@{
            status = "inProgress"
            scheduledDeploymentTime = $null
            comment = $null
            variables = ''
        }
        $body = $body | ConvertTo-Json
        $result = Invoke-RestMethod -Uri $uri -Method Patch -ContentType "application/json" -Headers @{ Authorization = ("Basic {0}" -f $base64AuthInfo) } -Body $body
        Write-Host "Deployment to $($envCheck) started. Checking for current Status."
        $status = Get-ADORelease -releaseId $releaseId
        $envStatus = $status.environments | Where-Object { $_.name -eq $envCheck }
        $envStatus | Select-Object id, releaseId, name, status, preDeployApprovals
        if ($null -ne $envStatus.preDeployApprovals.id){
            Write-Host "Deployment has an approval pending. Waiting for $($envStatus.preDeployApprovals.approver.displayName) to approve."
            $answer = Read-Host "Is this you?(Yes/No)"
            if ($answer -match '^Y'){
                Set-ADOreleaseApproval -releaseId $releaseId -approvalStatus approved
            }
        }
    }
    end{
        return $result
    }
}