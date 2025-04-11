---
title: "How to List All Team Owners in Microsoft Teams"
slug: list-all-team-owners
date: '2024-10-03'
lastmod: '2024-10-03'
draft: false
description: "Managing Microsoft Teams can feel overwhelming, especially when you can't see who's in charge."
summary: "Managing Microsoft Teams can feel overwhelming, especially when you can't see who's in charge."
keywords:
- list
- list-all-team-owners
- microsoft
- microsoft-365
- owners
- team
- teams
image:
  src: featured-list-all-team-owners.png
  previewOnly: false
cover:
  image: featured-list-all-team-owners.png
  alt: How to List All Team Owners in Microsoft Teams preview
  caption: ''
showTableOfContents: true
showAuthor: true
showReadingTime: true
showSummary: false
showDate: true
showDateUpdated: true
showTaxonomies: true
layoutBackgroundHeaderSpace: false
categories:
- microsoft-365
tags: []
---

Managing Microsoft Teams can feel overwhelming, especially when you can't see who's in charge.

By default, the **[Teams Management Portal](https://learn.microsoft.com/en-us/microsoftteams/manage-teams-in-modern-portal)** hides owner information when you export data.

This makes it tough to keep track of who controls each team.

But don’t worry—there’s an easy way to list all team owners using PowerShell.

In this article, I’ll walk you through the exact steps you need to follow, so you can quickly gather a complete list of team owners.

## Setting Up The Tools

When you export data from the **Teams Management Portal**, you won’t see the team owners by default.

To find all owners, you need to use PowerShell.

First, we need to install a PowerShell Module named **MicrosoftTeams**.

Install and Import the PowerShell Module by running the following:

```powershell
Install-Module MicrosoftTeams
Import-Module MicrosoftTeams
```

Then, run the following to connect Powershell to Microsoft Teams.

```powershell
Connect-MicrosoftTeams
```

Make sure you're using a **Global Administrator** account.

Without proper access, PowerShell commands may not run.

By running a simple script, you can retrieve owner information for every team they are a part of and export it to a CSV file for easy access.

Below, I’ll walk you through the steps to run the code and explain how each part works.

## Setting Up The Script

This script pulls every active team, identifies the owners, and exports all the details to a well-formatted CSV file.

Now, let's look at the script that does this for you:

```powershell
# Get all teams that the current user has access to
$teams = Get-Team

# Initialize an empty array to store the results
$teamOwners = @()

# Loop through each team
foreach ($team in $teams) {
    # Get the team owners
    $owners = Get-TeamUser -GroupId $team.GroupId -Role Owner
    
    # For each owner, create an object with the Team Name and Owner details
    foreach ($owner in $owners) {
        $teamOwners += [pscustomobject]@{
            TeamName = $team.DisplayName
            OwnerName = $owner.Name   # Use the correct property for the owner's name
            OwnerUserPrincipalName = $owner.User
        }
    }
}

# Display the results in a table (for console output)
$teamOwners | Format-Table TeamName, OwnerName, OwnerUserPrincipalName

# Define the CSV file path
$csvFilePath = "C:\Path\To\Your\Directory\AllTeamOwners.csv"

# Use UTF-8 with BOM encoding to handle special characters like æ, ø, å, and handle commas properly by quoting fields
$teamOwners | Select-Object TeamName, OwnerName, OwnerUserPrincipalName |
    ConvertTo-Csv -NoTypeInformation | 
    ForEach-Object { 
        if ($_ -match ',') { 
            # Enclose the entire line in quotes if it contains commas
            '"' + $_.Replace('"', '""') + '"' 
        } else { 
            $_ 
        } 
    } | Out-File -FilePath $csvFilePath -Encoding UTF8BOM

# Confirm export
Write-Host "Team owners exported to: $csvFilePath with proper handling of commas and special characters."
```

### How The Script Works

The script first pulls all the **Teams** using the `Get-Team` command.

It then loops through each team to retrieve the owners with `Get-TeamUser`, filtering by the "Owner" role.

For every owner, it creates an object with the team name and owner details.

This object is stored in an array.

The results are displayed in the console using `Format-Table` for easy viewing.

Then, the script exports these results to a CSV file.

It uses UTF-8 encoding with BOM to ensure that special characters and commas are handled correctly, so the CSV file won’t break when opened in Excel or other programs.

Finally, a confirmation message appears to let you know that the export was successful.

## Final Thoughts

By using PowerShell, you can streamline the process of retrieving Microsoft Teams owners, bypassing the limitations of the **Teams Management Portal**.

This approach gives you more control and flexibility when managing large numbers of teams.

Exporting owner information to a CSV file makes it easy to keep track of team leaders, share data with others, and maintain updated records.

Whether you manage a few teams or an entire organization, this method saves time, ensures accuracy, and simplifies your workflow for better team oversight.
