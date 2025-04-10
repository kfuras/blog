---
title: "Securing Tier-0 Systems in Azure Arc: A Comprehensive Guide [2024]"
date: '2024-05-08'
lastmod: '2024-05-08'
draft: false
description: "Are you focused on securing Tier-0 systems in Azure Arc?"
summary: "Are you focused on securing Tier-0 systems in Azure Arc?"
keywords:
- '2024'
- azure
- azure-cloud
- securing
- securing-tier-0-systems-in-azure-arc
- tier-0
image:
  src: featured-securing-tier-0-systems-in-azure-arc.png
  previewOnly: false
cover:
  image: featured-securing-tier-0-systems-in-azure-arc.png
  alt: 'Securing Tier-0 Systems in Azure Arc: A Comprehensive Guide [2024] preview'
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
- azure-cloud
tags:
- featured
---

Are you focused on securing Tier-0 systems in Azure Arc?

Look no further.

In this blog post, I will explore several key topics, including:

- Potential Security Risks of the Azure Connected Machine Agent

- How to Limit Access to the RunCommandHandler

- And more!

**Let's dive in!**

## Introduction

For businesses using [Azure Arc](/azure-arc-key-vault-certificates) to manage their hybrid environments, it's crucial to secure Tier-0 systems. These typically include domain controllers, PKI servers, and other key infrastructure components.

A breach in these systems could severely disrupt operations.

Here’s a detailed guide on how to effectively secure these crucial systems.

## Testing the Run Command

Before we discuss deactivating the **Run Command**, or enable **Monitor Mode**, let's first understand how this feature might be used.

The feature could potentially be used to silently install software on servers using a script.

In the first example, we simply execute the **ipconfig** command, which retrieves the IP configuration from the targeted VM.

```powershell
# Define the script block to run ipconfig
$Script = {
    ipconfig
}

# Set parameters for the Run Command feature
$Parameters = @{
    ResourceGroupName = "ResourceGroupName"
    Location = "Location"
    SourceScript = $Script
    RunCommandName = "RunIpconfig"
    MachineName = "MachineName"
    SubscriptionId = "SubscriptionId"
}

# Execute the Run Command
New-AzConnectedMachineRunCommand @Parameters
```

Which output the following.

![][image-5-1024x218]

For the second example, we will execute a script that creates two firewall rules to allow ICMP traffic inbound to the server.

```powershell
# Set parameters for the Run Command feature
$Parameters = @{
    ResourceGroupName = "ResourceGroupName"
    Location = "Location"
    SourceScript = $Script
    RunCommandName = "SetupInboundICMP"
    MachineName = "MachineName"
    SubscriptionId = "SubscriptionId"
}

# Define the script block to allow ICMP (ping) requests for both IPv4 and IPv6
$Script = {
    try {
        # Firewall rule parameters for allowing ICMPv4 (Ping)
        $ruleNameV4 = "Allow ICMPv4-In"
        $descriptionV4 = "Inbound rule to allow ICMPv4 (Ping) traffic."

        # Create ICMPv4 rule
        New-NetFirewallRule -DisplayName $ruleNameV4 -Direction Inbound -Action Allow -Protocol ICMPv4 -IcmpType 8 -Profile Any -Description $descriptionV4

        # Firewall rule parameters for allowing ICMPv6 (Ping)
        $ruleNameV6 = "Allow ICMPv6-In"
        $descriptionV6 = "Inbound rule to allow ICMPv6 (Ping) traffic."

        # Create ICMPv6 rule
        New-NetFirewallRule -DisplayName $ruleNameV6 -Direction Inbound -Action Allow -Protocol ICMPv6 -IcmpType 128 -Profile Any -Description $descriptionV6

    } catch {
        # Output any exceptions that occur
        Write-Output $_.Exception.Message
    }
}

# Execute the Run Command
New-AzConnectedMachineRunCommand @Parameters
```

As we review the screenshots below, we can see that the command was executed successfully, resulting in the creation of the two firewall rules.

![][image-6-979x1024]

![][image-8-1024x76]

## Checking The Arc Client's Local Config

Looking at the Azure Connected Machine Agent (ACMA) Config we see that:

**extensions.allowlist** and **extensions.blocklist** is set to **'\[ \]'**

![Securing Tier-0 Systems in Azure Arc][image-2-1024x445]

This is the default setting and means that all extensions will be **allowed**.

One important thing to note is that if an extension exists in the  
allowed and blocked list, it will be **blocked**.

When examining the **Local Configuration Settings**, you might wonder what each setting means and what their default values are. To find out, run the following command to display this information.

```bash
azcmagent.exe config info
```

## Security Recommendations

It's crucial to fully understand the security implications associated with the Azure Connected Machine Agent (ACMA), especially since it plays a significant role in managing hybrid cloud configurations.

### Potential Security Risks

The ACMA comes equipped with several default capabilities intended to enhance management flexibility. However, these capabilities can also pose risks, particularly in environments where security is vital.

Notably, the default configuration of the ACMA allows administrators to:

- **Execute remote commands on Arc-enabled systems**.

- **Potentially enable SSH access, which could open up further vulnerabilities**.

### Execution Context and Security

When the Run Command feature is used, it executes code with high-level privileges like:

- **'SYSTEM' on Windows and as 'root' on Linux**.

This level of access can be extremely risky if commands are misused or if unauthorized access is gained.

### Mitigating Risks

To mitigate these risks, consider the following strategies:

1. ****Limit access to Run Command using RBAC**:**  
    Limit who can execute remote commands and under what circumstances. Use role-based access control (RBAC) to control administrative privileges.

3. **Configure ACMA as a Logging Agent:**  
    By configuring the ACMA to primarily function as a logging agent, you significantly reduce the number of active, potentially exploitable services. This setup focuses on collecting and managing logs without additional administrative capabilities.

5. **Disable the Run Command Feature:**  
    For maximum security, particularly in highly sensitive environments, consider disabling the Run Command feature entirely. This prevents the execution of any remote commands, thereby protecting against a vector of attacks that could otherwise escalate privileges or spread an infection.

By implementing these steps, you can enhance the security posture of your hybrid cloud environments managed by Azure Arc, ensuring that the tools provided by ACMA do not become liabilities.

## Limit access to Run Command using RBAC

**For Viewing and Listing Run Commands:**  
Use the **Reader role** to control access to viewing and listing run commands.

This role grants the **Microsoft.HybridCompute/machines/runCommands/read** permission, enabling users to view detailed information about run commands without granting them execution rights.

Here are the steps to assign the **Reader role** using PowerShell.

```powershell
# Connect to Azure
Connect-AzAccount

# Set the correct subscription Context
Set-AzContext -SubscriptionName "MySubscriptionName"

# Set the Reader Role on the specified Arc Machine
New-AzRoleAssignment -UserPrincipalName "MyUserPrincipalName" -RoleDefinitionName "Reader" -Scope "/subscriptions/"MySubscriptionID"/resourceGroups/"MyResourceGroup"/providers/Microsoft.HybridCompute/machines/MyMachine"
```

Warning

Note that the following section will allow the execution of Run Commands. To limit the use of Run Commands, do not grant access to the **Azure Connected Machine Resource Administrator role**.

**For Executing Run Commands:**  
Use the **Azure Connected Machine Resource Administrator role** to grant permissions for executing run commands.

This role grants the **Microsoft.HybridCompute/machines/runCommands/write** permission, which enables the execution of run commands and allows for a variety of other administrative activities on Azure-connected machines.

Here are the steps to assign the **Azure Connected Machine Resource Administrator role** using PowerShell.

```powershell
# Connect to Azure
Connect-AzAccount

# Set the correct subscription Context
Set-AzContext -SubscriptionName "MySubscriptionName"

# Set the Reader Role on the specified Arc Machine
New-AzRoleAssignment -UserPrincipalName "MyUserPrincipalName" -RoleDefinitionName "Azure Connected Machine Resource Administrator" -Scope "/subscriptions/"MySubscriptionID"/resourceGroups/"MyResourceGroup"/providers/Microsoft.HybridCompute/machines/MyMachine"
```

## Configure ACMA as a Logging Agent

To configure the Azure Connected Machine Agent (ACMA) as a logging agent using the command-line, you'll need to execute a specific command on the machine where ACMA is installed.

Note that making changes to the **Local Configuration Settings** while in Monitor mode is not allowed.

Here’s how you can enable **monitor mode**:

1. **Access the Machine:**  
    First, ensure you have access to the machine where the Azure Connected Machine Agent is installed. This can be done via SSH for Linux or Remote Desktop for Windows.

3. **Open Command Prompt or Terminal:**
    - **For Windows:** Open powershell as Administrator.
    
    - **For Linux:** Open your terminal.

5. **Run the Configuration Command:**  
    Execute the command below to set the agent to monitor (logging) mode.

```bash
azcmagent.exe config set config.mode monitor
```

## Block the Run Command Feature

A key step in securing your Tier-0 systems involves blocking the **Run Command** feature, which could be exploited if not properly secured. Blocking this feature prevents unauthorized or malicious use of remote command execution, which is critical in maintaining the integrity of your systems.

Here’s how you can **block** this feature:

1. **Access the Machine:**  
    First, ensure you have access to the machine where the Azure Connected Machine Agent is installed. This can be done via SSH for Linux or Remote Desktop for Windows.

3. **Open Command Prompt or Terminal:**
    - **For Windows:** Open powershell as Administrator.
    
    - **For Linux:** Open your terminal.

5. **Run the Configuration Command:**  
    Execute the command below to add the **RunCommandHandler** to the blocklist.

```bash
azcmagent.exe config set extensions.blocklist "microsoft.cplat.core/runcommandhandlerwindows"
```

## Verify the Configuration

After running the command, it’s a good idea to verify that the configuration has been applied successfully.

You can do this by running the command below.

```bash
azcmagent.exe config list
```

After adding the **RunCommandHandler** to the blocklist, the command should output the following in **full mode**.

![][image-4-1024x270]

And output the following in **monitor mode**.

![][image-3-1024x596]

When you change the config.mode from Monitor to Full, the extensions from Monitor mode are still present and will function as a whitelist.

## Configuration Changes During Installation

If your company requires the Arc Client to be configured only as a **monitoring agent** or to use a **whitelist**, you can achieve this by modifying the installation script downloaded from the Azure Portal.

Here I will give you two examples.

The first one configures the Arc Client for **monitor mode**.

The line to take note of is this one.

```powershell
& "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" config set config.mode monitor;
```

Full code here.

```powershell
try {
    # Add the service principal application ID and secret here
    $ServicePrincipalId="ServicePrincipalId";
    $ServicePrincipalClientSecret="ServicePrincipalClientSecret";

    $env:SUBSCRIPTION_ID = "SUBSCRIPTION_ID";
    $env:RESOURCE_GROUP = "RESOURCE_GROUP";
    $env:TENANT_ID = "TENANT_ID";
    $env:LOCATION = "LOCATION";
    $env:AUTH_TYPE = "principal";
    $env:CORRELATION_ID = "CORRELATION_ID";
    $env:CLOUD = "AzureCloud";
    

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072;

    # Download the installation package
    Invoke-WebRequest -UseBasicParsing -Uri "https://aka.ms/azcmagent-windows" -TimeoutSec 30 -OutFile "$env:TEMP\install_windows_azcmagent.ps1";

    # Install the hybrid agent
    & "$env:TEMP\install_windows_azcmagent.ps1";
    if ($LASTEXITCODE -ne 0) { exit 1; }

    # Run connect command
    & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect --service-principal-id "$ServicePrincipalId" --service-principal-secret "$ServicePrincipalClientSecret" --resource-group "$env:RESOURCE_GROUP" --tenant-id "$env:TENANT_ID" --location "$env:LOCATION" --subscription-id "$env:SUBSCRIPTION_ID" --cloud "$env:CLOUD" --correlation-id "$env:CORRELATION_ID";
    & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" config set config.mode monitor;
}
catch {
    $logBody = @{subscriptionId="$env:SUBSCRIPTION_ID";resourceGroup="$env:RESOURCE_GROUP";tenantId="$env:TENANT_ID";location="$env:LOCATION";correlationId="$env:CORRELATION_ID";authType="$env:AUTH_TYPE";operation="onboarding";messageType=$_.FullyQualifiedErrorId;message="$_";};
    Invoke-WebRequest -UseBasicParsing -Uri "https://gbl.his.arc.azure.com/log" -Method "PUT" -Body ($logBody | ConvertTo-Json) | out-null;
    Write-Host  -ForegroundColor red $_.Exception;
}
```

The second example will add two extensions to the **extensions.allowlist**.

The lines to take note of are these.

```powershell
& "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" config set extensions.allowlist "Microsoft.CPlat.Core/WindowsPatchExtension" --add;
& "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" config set extensions.allowlist "Microsoft.SoftwareUpdateManagement/WindowsOsUpdateExtension" --add;
```

Full code here.

```powershell
try {
    # Add the service principal application ID and secret here
    $ServicePrincipalId="ServicePrincipalId";
    $ServicePrincipalClientSecret="ServicePrincipalClientSecret";

    $env:SUBSCRIPTION_ID = "SUBSCRIPTION_ID";
    $env:RESOURCE_GROUP = "RESOURCE_GROUP";
    $env:TENANT_ID = "TENANT_ID";
    $env:LOCATION = "LOCATION";
    $env:AUTH_TYPE = "principal";
    $env:CORRELATION_ID = "CORRELATION_ID";
    $env:CLOUD = "AzureCloud";
    

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072;

    # Download the installation package
    Invoke-WebRequest -UseBasicParsing -Uri "https://aka.ms/azcmagent-windows" -TimeoutSec 30 -OutFile "$env:TEMP\install_windows_azcmagent.ps1";

    # Install the hybrid agent
    & "$env:TEMP\install_windows_azcmagent.ps1";
    if ($LASTEXITCODE -ne 0) { exit 1; }

    # Run connect command
    & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect --service-principal-id "$ServicePrincipalId" --service-principal-secret "$ServicePrincipalClientSecret" --resource-group "$env:RESOURCE_GROUP" --tenant-id "$env:TENANT_ID" --location "$env:LOCATION" --subscription-id "$env:SUBSCRIPTION_ID" --cloud "$env:CLOUD" --correlation-id "$env:CORRELATION_ID";
    & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" config set extensions.allowlist "Microsoft.CPlat.Core/WindowsPatchExtension" --add;
    & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" config set extensions.allowlist "Microsoft.SoftwareUpdateManagement/WindowsOsUpdateExtension" --add;
}
catch {
    $logBody = @{subscriptionId="$env:SUBSCRIPTION_ID";resourceGroup="$env:RESOURCE_GROUP";tenantId="$env:TENANT_ID";location="$env:LOCATION";correlationId="$env:CORRELATION_ID";authType="$env:AUTH_TYPE";operation="onboarding";messageType=$_.FullyQualifiedErrorId;message="$_";};
    Invoke-WebRequest -UseBasicParsing -Uri "https://gbl.his.arc.azure.com/log" -Method "PUT" -Body ($logBody | ConvertTo-Json) | out-null;
    Write-Host  -ForegroundColor red $_.Exception;
}
```

To verify the configuration, run the **azcmagent.exe config list** command mentioned above.

## Troubleshooting

Should you experience any problems with the **RunCommandHandler**, which enables the execution of scripts and commands on virtual machines managed by Azure Arc, the following commands can be utilized for its removal.

```powershell
# Stop the Guest Configuration Extension Service
Stop-Service ExtensionService

# Lists all Extensions installed on the Virtual Machine
azcmagent.exe extension list

# Removes the RunCommandHandler Extension from the Virtual Machine
azcmagent.exe extension remove -n RunCommandHandler
```

  
Use the following command to collect logs from the Arc Client.

```bash
azcmagent.exe logs
```

This command creates a .zip file containing the most recent and relevant logs, which can be very useful for troubleshooting.

## Conclusion

And there you have it!

If you have any questions about this guide or need further clarification, please don't hesitate to reach out. I'm here to help!

Don’t forget to visit my [website](https://kjetilfuras.com/) for more updates, I'll be posting similar content in the future.

Take care and happy Arc-ing! 😊

## **Additional Resources**

Links to Microsoft Official Documentation

- [Azure Arc Documentation](https://learn.microsoft.com/en-us/azure/azure-arc/overview)

- [Azure Arc Runcommand Documentation](https://learn.microsoft.com/en-us/azure/azure-arc/servers/run-command).

[image-5-1024x218]: image-5-1024x218.png
[image-6-979x1024]: image-6-979x1024.png
[image-8-1024x76]: image-8-1024x76.png
[image-2-1024x445]: image-2-1024x445.png
[image-4-1024x270]: image-4-1024x270.png
[image-3-1024x596]: image-3-1024x596.png
