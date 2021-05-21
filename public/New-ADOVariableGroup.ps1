function new-adovariablegroup {
    Param(
        $VariableGroupName,
        $Variables,
        $variableProjectname,
        $variableProjectID
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
        $Jsonbody=[PSCustomObject]@{
            Name = $VariableGroupName
            Variables = $Variables
            type = 'vsts'
            variableGroupProjectReferences=@{
                projectReference=@{
                    name=$variableProjectname
                    id=$variableProjectID
                }
                name=$VariableGroupName
            }
        }|ConvertTo-Json -Depth 10
        $uri = "https://dev.azure.com/${vstsaccount}/_apis/distributedtask/variablegroups?api-version=6.1-preview.2"
        $result = Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Body $Jsonbody
    }
    end {
        return $result
    }
}   