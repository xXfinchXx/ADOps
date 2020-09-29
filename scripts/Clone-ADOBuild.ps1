$Organization = 'elead1one'
$Project = 'EleadPlatform'
[string]$user = ""
[string]$token = "6cxlckvmb5iy3d3yw5waw37di4li2vksvuwmvles3ydysq5ullda"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user,$token)))

$BuildDefs= list-adobuilddefinitions 
$DefinitionToCloneID=$BuildDefs | Where Name -match 'Evo2-Bui' | Select ID
$URL="https://dev.azure.com/${organization}/${project}/_apis/build/definitions?definitionToCloneId=${definitionToCloneId}&api-version=6.0-preview.7"
foreach ($build in ($BuildDefs|Where Name -NotMatch 'nuget|automatedtesting|sip\.|cc_|BUILDTESTCOVERITY|audit|^elead')){
    $Name = if ($build.name -match 'fixedOps'){($build.name)}elseIf ($build.name -match 'aspnet|react|csharp'){$build.name.split('-')[0]}else{$build.name}
    [pscustomObject]@{
        name = "$($Name)-coverityscan"
    }

    Invoke-RestMethod -Uri $URL -Method Post -Body $Body -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
}    


foreach ($build in ($BuildDefs|Where Name -Match 'messenger-aspnet')){
    $Name = if ($build.name -match 'fixedOps'){($build.name)}elseIf ($build.name -match 'aspnet|react|csharp'){$build.name.split('-')[0]}else{$build.name}
    [pscustomObject]@{
        name = "$($Name)-coverityscan"
    }

    Invoke-RestMethod -Uri $URL -Method Post -Body $Body -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
}