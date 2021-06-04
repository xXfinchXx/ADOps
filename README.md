---
external help file: ADOps-help.xml
Module Name: ADOps
online version:
schema: 2.0.0
---

# ADOps Module

## SYNOPSIS

Here you will find the ADOps Module and the various scripts that were needed to complete tasks.
The ADOps Module consists of a number of functions that will assist in the retrieval of information for reporting.
It will also allow the user to trigger a deployment without even touching the webpage.

## Functions

## Set-ADOConnection

```POWERSHELL
Set-ADOConnection [-ADOaccount][-ADOProjectname][-ADOPat]
```

## DESCRIPTION

To Set your Azure Devops Environment Variables for all actions within this Module

## PARAMETERS

### -ADOAccount

Enter your Azure DevOps account name here to save it for later use

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ADOProjectName

Enter your Azure DevOps project name here to save it for later use

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ADOPAT

Enter your Azure DevOps PAT here to save it for later use

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## Get-ADOBuildDefinitions

```POWERSHELL
Get-ADOBuildDefinitions
```

## DESCRIPTION

Collect all Build Definitions from your desired project. This will filter to just the Name, ID, url, path, revision, and queueStatus

## Get-ADOReleaseDefinitions

```POWERSHELL
Get-ADOReleaseDefinitions
```

## DESCRIPTION

Collect all Release Definitions from your desired project. This will filter to just the Name, ID, url, path, revision, and queueStatus