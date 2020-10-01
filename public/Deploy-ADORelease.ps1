function deploy-adorelease{
    param(
        $releasedefinitionname,
        $releaseid
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
            $release = Read-host -Prompt "Which one of the above releases would you like to manage? Please Enter ID from Left Column"
            $Releaseid = ($releaseinfo | Where id -match $Release).id
            $releaseTarget=Get-ADORelease -releaseid $releaseid
        }

        $releaseTarget=Get-adoRelease -releaseid $releaseid
        $releaseTarget.environments.Name
        $EnvCheck = Read-host -prompt "What Environment would you like to deploy? Please select from the above list."
        $Environmentinfo = $releaseTarget.environments | Where name -match $EnvCheck
        $uri = "https://vsrm.dev.azure.com/$($ADOAccount)/$($ADOProjectname)/_apis/Release/releases/$($releasetarget.id)/environments/$($environmentinfo.id)?api-version=6.1-preview.7"
        $body = [pscustomobject]@{
            status= "inProgress"
            scheduledDeploymentTime= $null
            comment= $null
            variables= ''
        }
        $body = $body | ConvertTo-Json
        $result = Invoke-RestMethod -Uri $uri -Method Patch -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -body $body
        Write-host "Deployment to $($ENVCheck) started. Checking for current Status."
        $Status = Get-ADORelease -releaseid $releaseid
        $ENVStatus=$status.Environments | Where name -match $ENVCheck
        $ENVStatus | Select id,releaseid,name,status,predeployApprovals
        if ( $null -ne $ENVStatus.predeployApprovals.id){
            Write-Host "Deployment has an approval pending. Waiting for $($ENVStatus.predeployapprovals.approver.displayname) to approve."
            $Answer=Read-Host "Is this you?(Yes/No)"
            if ($Answer -match '^Y'){
                Set-ADOreleaseApproval -releaseid $releaseid -approvalstatus approved
            }
        }
    }
    end{
        return $result
    }
}