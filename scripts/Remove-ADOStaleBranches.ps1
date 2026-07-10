param(
    [Parameter(Mandatory)][string]$ADOprojectName,
    [Parameter(Mandatory)][string]$repositoryName,
    [Parameter(Mandatory)][string]$StartDate,
    [Parameter(Mandatory)][string]$ADOAccount,
    [Parameter(Mandatory)][string]$ADOpat,
    [switch]$WhatIf
)

Import-Module "$PSScriptRoot\..\ADOps.psd1" -ErrorAction SilentlyContinue
# Fetch repository ID from name
set-adoconnection -ProjectName $ADOprojectName -adoaccount $ADOAccount -adopat $ADOpat
$repo = Get-ADORepo -ADOprojectName $ADOprojectName -Name $repositoryName
if (-not $repo.value.id) {
    Write-Host "Repository '$repositoryName' not found in project '$ADOprojectName'."
    exit 1
}
$repositoryId = $repo.value.id
# Parse the date (allow year or full date)
if ($StartDate -match '^\d{4}$') {
    $filterDate = Get-Date "$StartDate-01-01"
} else {
    $filterDate = Get-Date $StartDate
}

# Fetch all branches with commit dates
$branches = Get-ADORepoBranches -repositoryId $repositoryId -ADOprojectName $ADOprojectName -IncludeDates

if (-not $branches.value) {
    Write-Host "No branches found or failed to fetch branches."
    exit 1
}

# Filter branches older than the filter date (exclude default branch)
$staleBranches = $branches.value | Where-Object {
    $_.name -like 'refs/heads/*' -and
    $_.lastCommitDate -and
    (Get-Date $_.lastCommitDate) -lt $filterDate -and
    $_.name -ne $branches.value[0].defaultBranch
}

if ($staleBranches.Count -eq 0) {
    Write-Host "No stale branches found before $($filterDate.ToShortDateString())."
    exit 0
}

Write-Host "Branches older than $($filterDate.ToShortDateString()):"
$staleBranches | ForEach-Object { Write-Host $_.name "Last Commit:" $_.lastCommitDate }

if ($WhatIf) {
    Write-Host "`nWhatIf: No branches will be deleted."
    exit 0
}

# Confirm deletion
$confirm = Read-Host "`nAre you sure you want to delete these branches? Type 'YES' to confirm"
if ($confirm -ne 'YES') {
    Write-Host "Aborted by user."
    exit 0
}

foreach ($branch in $staleBranches) {
    $branchName = $branch.name -replace '^refs/heads/', ''
    try {
        $uri = "https://dev.azure.com/$($Global:ADOAccount)/$ADOprojectName/_apis/git/repositories/$repositoryId/refs?filter=refs/heads/$branchName&api-version=7.1"
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Global:ADOUser,$Global:ADOpat)))
        $ref = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
        if ($ref.count -eq 1) {
            $deleteUri = "https://dev.azure.com/$($Global:ADOAccount)/$ADOprojectName/_apis/git/repositories/$repositoryId/refs?api-version=7.1"
            $body = @(
                @{
                    name = "refs/heads/$branchName"
                    oldObjectId = $ref.value[0].objectId
                    newObjectId = '0000000000000000000000000000000000000000'
                }
            ) | ConvertTo-Json
            Invoke-RestMethod -Uri $deleteUri -Method Post -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Body $body
            Write-Host "Deleted branch: $branchName"
        } else {
            Write-Warning "Branch $branchName not found or ambiguous."
        }
    } catch {
        Write-Warning "Failed to delete branch $($branchName): $_"
    }
}