$projectlist = get-adoprojects
foreach($project in $projectlist.value[0]){
    $releaseDeflist = get-adoreleasedefinitions -ADOprojectName $project.name
    Foreach ($release in $releasedeflist[0]){
        $releaseDef = get-adoreleasedefinition -ReleaseDefinitionID $release.id -ADOproject $project.name
        $json=[PSCustomObject]@{
            Name = "$($releasedef.name)"
            id = $releaseDef.id
            environments = $releaseDef.environments
            artifacts = $releaseDef.artifacts
            triggers = $releaseDef.triggers
            releaseNameFormat = $releaseDef.releaseNameFormat
            tags = $releaseDef.tags
            properties = $releaseDef.properties
            path = "\$($project.name)$($releaseDef.path)"
        }
        New-adoreleasedefinition -ReleaseDefinitionJSON ($json|ConvertTo-Json -Depth 10) -adoproject WTD
    }
}