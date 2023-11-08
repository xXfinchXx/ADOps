#AZ CLI is Needed to Add new Variables to the Libraries
#start with AZ LOGIN
#Then az devops configure --defaults organization=https://dev.azure.com/ORGNAMEHERE
#Finally use set-ADoconnection -ADOAccount ORGNAME -ADOprojectName DEFAULTPROJECT -ADOpat PAT

$projectlist = get-adoprojects
foreach($project in $projectlist.value){
    $releaseDeflist = get-adoreleasedefinitions -ADOprojectName $project.name
    Foreach ($release in $releasedeflist){
        $releaseDef = get-adoreleasedefinition -ReleaseDefinitionID $release.id -ADOproject $project.name
        $VarGroup=if ($releaseDef.name -match 'UAT'){(get-adovariablegroups -ADOprojectName WTD).value | Where name -match 'uat'}elseif($releaseDef.name -match 'prod|prd'){(get-adovariablegroups -ADOprojectName WTD).value | Where name -match 'prod'}elseif($releaseDef.name -match 'preview'){(get-adovariablegroups -ADOprojectName WTD).value | Where name -match 'preview'}elseif($releaseDef.name -match 'sit'){(get-adovariablegroups -ADOprojectName WTD).value | Where name -match 'dev'}
        $vars = $releaseDef.variables.psobject.Members | where-object membertype -like 'noteproperty'
        Start-Sleep -Seconds 60
        foreach ($var in $vars){
            $value = If ($null -ne $var.value.value){$var.value.value}else{"REPLACE"}
            if ($null -ne $var.name){
                if ($vargroup.variables.($var.name)){
                    Write-host "$($Var.name) is already a variable within the $($vargroup.name) variable Library" -ForegroundColor Red
                    if ($vargroup.variables.($var.name) -match $value){
                        Write-host "Variable Value Matched for $($var.name)... Skipping create step" -ForegroundColor Green
                    }else{
                        Write-host "Variable Value for $($var.name) did not match. Creating new name for a new entry to the Variable Group" -ForegroundColor Red;$newName = "$($releasedef.name -replace " ",'-')_$($var.name)"
                        az pipelines variable-group variable create --group-id $vargroup.id --name $newName --value $value --project WTD
                    }
                }else{
                    az pipelines variable-group variable create --group-id $vargroup.id --name $var.name --value $value --project WTD
                }    
            }
        }
    }
}