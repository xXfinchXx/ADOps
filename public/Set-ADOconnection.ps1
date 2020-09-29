function set-adoconnection {
    param(
        [string]$ADOAccount = "",
        [string]$ADOprojectName = "",
        [string]$ADOpat = ""
 
    )
    $Global:ADOAccount = $ADOAccount
    $Global:ADOProjectName = $ADOprojectName
    $Global:ADOUser = ''
    $Global:ADOpat = $ADOpat
}