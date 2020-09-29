$uri = "https://dev.azure.com/$($ADOAccount)/_apis/AccessControlEntries/2e9eb7ed-3c0a-47d4-87c1-0ffdd275fd87?api-version=5.1"
foreach ($RepoID in $repoList[0]){
    $permList=@(4,16384,16,32,2)
    foreach ($permNum in $permList[0]){
        $body=@"
            {
            "token": "repoV2/6bdcf8f4-d872-4f27-8c0e-630cd99056ee/$($RepoID.id)",
            "merge": true,
            "accessControlEntries": 
                [
                    {
                        "descriptor": "Microsoft.TeamFoundation.Identity;S-1-9-1551374245-4109950059-1926768463-2349753100-3650115310-1-3173511691-603310671-2930282073-3105999477",
                        "allow": 0,
                        "deny": $($PermNum),
                        "extendedinfo": {effectiveAllow: 0, effectiveDeny: $($PermNum), inheritedAllow: 0, inheritedDeny: $($PermNum)}
                    }
                ]
            }
"@
            Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Body $Body
    }
}    