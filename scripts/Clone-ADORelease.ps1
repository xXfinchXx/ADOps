$releaseDeflist = get-adoreleasedefinitions
foreach ($id in $testlist.id){
    remove-adoreleasedefinition -ReleaseDefinitionID $ID
}
Foreach ($release in $releasedeflist){
    $releaseDef = get-adoreleasedefinition -ReleaseDefinitionID $release.id
    $TemplateReleaseDef = Get-Content -LiteralPath C:\temp\template.json | ConvertFrom-Json -Depth 10
    $json=[PSCustomObject]@{
        Name = "lasmigration-$($releasedef.name)"
        id = $releaseDef.id
        environments = $TemplateReleaseDef.environments
        artifacts = $releaseDef.artifacts
        triggers = $TemplateReleaseDef.triggers
        releaseNameFormat = '$(Build.BuildNumber)-r$(rev:rr)'
        tags = $TemplateReleaseDef.tags
        properties = $TemplateReleaseDef.properties
        path = '\LASMigration'
    }
    New-adoreleasedefinition -ReleaseDefinitionJSON ($json|ConvertTo-Json -Depth 10)
}
