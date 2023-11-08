$template = get-adoreleasedefinition -ADOproject wtd -ReleaseDefinitionID 1
Foreach ($release in $releasedeflist){
    $json=[PSCustomObject]@{
        Name = "$($release.releasedefName)"
        id = $template.id
        environments = $template.environments
        artifacts = $template.artifacts
        triggers = $template.triggers
        releaseNameFormat = $template.releaseNameFormat
        tags = $template.tags
        properties = $template.properties
        path = "\$($release.projectname)"
    }
    New-adoreleasedefinition -ReleaseDefinitionJSON ($json|ConvertTo-Json -Depth 10) -adoproject WTD
}
