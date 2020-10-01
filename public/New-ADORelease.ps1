function new-adorelease{
    param(
        $releasedefinitionname,
        $builddefinitionname
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
        $uri = "https://vsrm.dev.azure.com/$($ADOAccount)/$($ADOprojectName)/_apis/release/releases?api-version=6.0"
        $Build=Get-ADOBuildDefinitions | Where name -Match $builddefinitionname
        $Buildinfo = get-adobuild -buildDefID $Build.id
        get-adobuild -buildDefID $Build.id |select buildnumber,sourceBranch|  FT
        $buildVer = Read-Host -Prompt "What Build version would you like to create a release for?(Please Enter desired build number from above or enter other known build number)"
        $release= get-adoreleasedefinitions | Where name -Match $releasedefinitionname
        $ReleaseInfo = get-adoreleasedefinition -ReleaseDefinitionID $release.id
        $body = [pscustomobject]@{
                definitionId= $ReleaseInfo.id
                description= 'Release Created via Powershell'
                artifacts= [pscustomobject]@{
                    instanceReference= [pscustomobject]@{
                        id= ($Buildinfo | Where buildnumber -Match $buildVer).id
                        name= $null
                    }
                  }
        
                isDraft= $false
                reason= "none"
                manualEnvironments= $null
              }
        $body=$body |ConvertTo-Json -Depth 10      
        $result = Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -body $body
    }
    end{
        return $result
    }
}