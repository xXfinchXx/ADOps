function Get-ADORepoBranches {
    Param(
        [Parameter(Mandatory)][string]$repositoryId,
        $ADOprojectName,
        [switch]$IncludeDates
    )
    begin {
        if (!($ADOpat)) {
            Write-Warning "Looks like you haven't set your connection yet. Let me help you with that."
            $projectName = Read-Host -Prompt 'What is your Azure DevOps Project Name?'
            $vstsAccount = Read-host -Prompt 'What is your Azure DevOps Account Name?'
            $PAT = Read-Host -Prompt 'What is your Azure DevOps PAT (Personal Access Token)?'
            Set-ADOconnection -ADOAccount $vstsAccount -ADOprojectName $projectName -ADOpat $PAT
        }
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $ADOUser,$ADOpat)))
    }
    process {
        $uri = "https://dev.azure.com/$($ADOAccount)/$($ADOprojectName)/_apis/git/repositories/$($repositoryId)/refs?api-version=7.1"
        $refs = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
        
        if ($IncludeDates) {
            $branches = foreach ($ref in $refs.value) {
                if ($ref.name -like "refs/heads/*") {
                    # Get commit info for the branch
                    $commitUri = "https://dev.azure.com/$($ADOAccount)/$($ADOprojectName)/_apis/git/repositories/$($repositoryId)/commits/$($ref.objectId)?api-version=7.1"
                    $commit = Invoke-RestMethod -Uri $commitUri -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
                    
                    # Add dates to the branch object
                    $ref | Add-Member -NotePropertyName 'authorDate' -NotePropertyValue $commit.author.date -Force
                    $ref | Add-Member -NotePropertyName 'lastCommitDate' -NotePropertyValue $commit.committer.date -Force
                    $ref
                }
            }
            return @{
                count = $branches.Count
                value = $branches
            }
        }
        return $refs
    }
}
