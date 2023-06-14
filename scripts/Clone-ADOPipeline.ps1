$projectlist = get-adoprojects
foreach($project in $projectlist.value){
    $pipelineDeflist = get-adobuilddefinitions -ADOproject $project.name
    Foreach ($pipeline in $pipelinedeflist){
        $pipelineDef = get-adobuilddefinition -BuildDefinitionID $pipeline.id -ADOproject $project.name
        $repo = get-adorepo -ADOprojectName $project.name -repositoryId $pipelineDef.configuration.repository.id
        $repolist = get-adorepolist -ADOprojectName WTD
        $repoNew = $repolist | Where name -match "$($repo.name)"
        $pipelineDef.configuration.repository.id = $repoNew.id
        $json=[PSCustomObject]@{
            Name = "$($pipelinedef.name)"
            configuration = $pipelineDef.configuration
            id = $pipelineDef.id
            folder = "\$($project.name)$($pipelineDef.folder)"
        }
        New-adobuilddefinition -buildDefinitionJSON ($json|ConvertTo-Json -Depth 10) -adoproject WTD
    }
}