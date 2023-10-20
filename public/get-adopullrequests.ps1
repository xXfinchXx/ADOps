function get-adopullrequests{
    param(
        [Parameter(Mandatory)][string]$repositoryId,
        $ADOprojectName,
        $creatorId,
        $includeLinks,
        $reviewerId,
        $sourceRefName,
        $sourceRepositoryId,
        [ValidateSet('abandoned','active','all','completed','notSet')]$status,
        $targetRefName,
        $skip


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
        if ($creatorId){
            $creatorIduri = "searchCriteria.creatorId=$($creatorId)&"
        }
        if ($includeLinks){
            $includeLinksuri = "searchCriteria.includeLinks=$($includeLinks)&"
        }
        if ($reviewerId){
            $reviewerIduri = "searchCriteria.reviewerId=$($reviewerId)&"
        }
        if ($sourceRefName){
            $sourceRefNameuri = "searchCriteria.sourceRefName=$($sourceRefName)&"
        }
        if ($sourceRepositoryId){
            $sourceRepositoryIduri = "searchCriteria.sourceRepositoryId=$($sourceRepositoryId)&"
        }
        if ($status){
            $statusuri = "searchCriteria.status=$($status)&"
        }
        if ($targetRefName){
            $targetRefNameuri = "searchCriteria.targetRefName=$($targetRefName)&"
        }
        $apiversion = 'api-version=7.0'
        if ($skip){
            $skipuri = '$skip={0}'-f $skip
            if ($creatorId -or $includeLinks -or $sourceRefName -or $sourceRepositoryId -or $reviewerId -or $status -or $targetRefName){
                $uri = "https://dev.azure.com/$($ADOAccount)/$($ADOprojectName)/_apis/git/repositories/$($repositoryId)/pullrequests?$($skipuri)&"+$creatorIduri+$includeLinksuri+$sourceRefNameuri+$sourceRepositoryIduri+$reviewerIduri+$statusuri+$targetRefNameuri+$apiversion
            }else{
                $uri = "https://dev.azure.com/$($ADOAccount)/$($ADOprojectName)/_apis/git/repositories/$($repositoryId)/pullrequests?$($skipuri)&$($apiversion)"
            }
        }else{
            if ($creatorId -or $includeLinks -or $sourceRefName -or $sourceRepositoryId -or $reviewerId -or $status -or $targetRefName){
                $uri = "https://dev.azure.com/$($ADOAccount)/$($ADOprojectName)/_apis/git/repositories/$($repositoryId)/pullrequests?"+$creatorIduri+$includeLinksuri+$sourceRefNameuri+$sourceRepositoryIduri+$reviewerIduri+$statusuri+$targetRefNameuri+$apiversion
            }else{
                $uri = "https://dev.azure.com/$($ADOAccount)/$($ADOprojectName)/_apis/git/repositories/$($repositoryId)/pullrequests?$($apiversion)"
            }
        }
        $result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
    }
    end{
        return $result
    }
}