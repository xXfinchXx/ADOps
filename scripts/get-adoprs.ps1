$ADOProjectName = ''
$RepositoryName = ''
$repo = (get-adorepo -ADOprojectName $ADOProjectName).value | Where Name -match $RepositoryName
$reportstartdate = '2023-09-30' #Replace
$OldestPR = '2024-10-25'
$skip = 0
$prlist = While ($reportstartdate -lt $OldestPR){
    if ($skip -eq 0){
        get-adopullrequests -ADOprojectName $ADOProjectName -repositoryId $repo.id -status completed
        $temp=get-adopullrequests -ADOprojectName $ADOProjectName -repositoryId $repo.id -status completed
        $skip =$skip + 100
        $OldestPR = ($temp.value| Sort ClosedDate| Select -First 1).closeddate
    } else {
        get-adopullrequests -ADOprojectName $ADOProjectName -repositoryId $repo.id -skip $skip -status completed
        $temp=get-adopullrequests -ADOprojectName $ADOProjectName -repositoryId $repo.id -skip $skip -status completed
        $skip =$skip + 100
        $OldestPR = ($temp.value| Sort ClosedDate| Select -First 1).closeddate
    }
}