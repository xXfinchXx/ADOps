$projectlist = get-adoprojects
foreach($project in ($projectlist.value)){
    $pipelineDeflist = get-adopipelinedefinitions -ADOproject $project.name
    Foreach ($pipeline in ($pipelinedeflist)){
        $pipelineDef = get-adopipelinedefinition -pipelineDefinitionID $pipeline.id -ADOproject $project.name
        $repo = get-adorepo -ADOprojectName $project.name -repositoryId $pipelineDef.configuration.repository.id
        $repolist = get-adorepolist -ADOprojectName WTD
        $reponame =if ($repo.project.name -match $repo.name){$repo.name}else{"$($repo.project.name -replace "-",'')-$($repo.name)"}
        $repoNew = $repolist | Where name -eq "$($reponame)"
        $pipelineDef.configuration.repository.id = $repoNew.id
        $json=[PSCustomObject]@{
            Name = "$($pipelinedef.name)"
            configuration = $pipelineDef.configuration
            id = $pipelineDef.id
            folder = "\$($project.name)$($pipelineDef.folder)"
        }
        try {
            New-adopipelinedefinition -pipelineDefinitionJSON ($json|ConvertTo-Json -Depth 10) -adoproject WTD
        }
        catch {
            Write-Host "Pipeline Creation for $($pipeline.name) was unsuccessful"
        }
    }
}