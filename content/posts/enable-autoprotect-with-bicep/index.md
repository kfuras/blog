---
title: "Enable AUTOPROTECT with Bicep: A Step-by-Step Guide"
slug: enable-autoprotect-with-bicep
date: '2024-04-26'
lastmod: '2024-04-26'
draft: false
description: "In today's tutorial, I'm excited to show you exactly **how to enable AUTOPROTECT with Bicep**."
summary: "In today's tutorial, I'm excited to show you exactly **how to enable AUTOPROTECT with Bicep**."
keywords:
- autoprotect
- azure-cloud
- bicep
- enable
- enable-autoprotect-with-bicep
- iac
- step-by-step
image:
  src: featured-enable-autoprotect-with-bicep.png
  previewOnly: false
cover:
  image: featured-enable-autoprotect-with-bicep.png
  alt: 'Enable AUTOPROTECT with Bicep: A Step-by-Step Guide preview'
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
- iac
tags:
- featured
---

In today's tutorial, I'm excited to show you exactly **how to enable AUTOPROTECT with Bicep**.

I will give you all my code snippets to get this up and running:

- **Deploy SQL Servers running Windows**

- **Deploy a Recovery Services Vault**

- **Create a SQL Server Backup Policy**

- **Register the SQL Servers to the Vault**

- **Enabling the AUTOPROTECT Feature**

## Overview of Azure Recovery Services Vault

In short Azure Recovery Services Vault is a crucial component within Azure that provides centralized data protection and disaster recovery.

It ensures data safety, allows scalable and cost-effective management of backups, and enhances security by safeguarding data during transfer and storage.

This makes it an essential tool for businesses to maintain data integrity and availability in Azure.

While many of us are familiar with setting up configurations through the Azure portal.

The real question is, how do we achieve this using Infrastructure as Code with Bicep?

Let's find out!

## What Is This AUTO PROTECT Feature

The **Auto Protect** feature in **Azure Recovery Services Vault** for SQL Server is designed to simplify the backup process of SQL Server databases running on Azure VMs.

When enabled, it automatically detects any new SQL Server instances and databases hosted on Azure VMs and adds them to the existing backup policy.

This means that as new databases are created or new SQL instances are deployed, they are automatically protected according to the pre-defined backup settings without the need for manual intervention.

## Setting Up the Environment

For this guide, I've pre-created a couple of Resource Groups to organize our Azure resources:

- **KF-RSV-RG**: This resource group is designated for the **Recovery Services Vault**.

- **KF-VMS-RG**: This group will contain all resources related to **Virtual Machines**.

While a Vnet is also required, it will not be covered in this article.

I will walk you through each module individually before integrating them during the deployment phase.

### Access the Code from GitHub

As we set up the environment, you can access all the necessary Bicep files from my [GitHub repository](https://github.com/kfuras/Enable-AUTOPROTECT-with-Bicep) to follow along more easily. This repository contains all the code used in this article, organized and ready for use.

## Deploying the Virtual Machines

### 1\. Network Interface Module

Let us start by building the first module, create a file named '**networkInterface.bicep**' and copy the following code into it.

```typescript
targetScope = 'resourceGroup'
param networkInterfaceName string
param location string
param subnetRef string
param publicIpAddressId string
param nsgId string

// Creates a network interface resource with the specified properties.
resource networkInterface 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpAddressId
          }
        }
      }
    ]
    enableAcceleratedNetworking: true
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

// Outputs the ID of the created network interface resource.
output networkInterfaceId string = networkInterface.id
```

### 2\. Public Interface Module

Note

I want to give a heads-up that this setup is configured for a lab environment, and a public interface is not necessary unless you plan to make this server internet-accessible.  
  
For secure RDP connections to your Azure Virtual Machines, consider using [Azure Bastion](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview) instead.

Now for the second module, create a file named '**publicIpAddress.bicep**' and copy the following code into it.

```typescript
targetScope = 'resourceGroup'
param publicIpAddressName string
param location string
param publicIpAddressSku string
param publicIpAddressType string

// Creates a public IP address resource
resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: publicIpAddressName
  location: location
  sku: {
    name: publicIpAddressSku
  }
  properties: {
    publicIPAllocationMethod: publicIpAddressType
  }
}

// Outputs the ID of the public IP address resource
output publicIpAddressId string = publicIpAddress.id
```

### 3\. SQL Virtual Machine Module

Create a file named '**sqlVirtualMachine.bicep**' and copy the following code into it.

```typescript
targetScope = 'resourceGroup'
param virtualMachineName string
param location string
param virtualMachineId string
param diskConfigurationType string
param storageWorkloadType string
param dataDisksLuns array
param dataPath string
param logDisksLuns array
param logPath string
param tempDbPath string

resource sqlVirtualMachine 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2022-07-01-preview' = {
  name: virtualMachineName
  location: location
  properties: {
    virtualMachineResourceId: virtualMachineId
    sqlManagement: 'Full'
    sqlServerLicenseType: 'PAYG'
    storageConfigurationSettings: {
      diskConfigurationType: diskConfigurationType
      storageWorkloadType: storageWorkloadType
      sqlDataSettings: {
        luns: dataDisksLuns
        defaultFilePath: dataPath
      }
      sqlLogSettings: {
        luns: logDisksLuns
        defaultFilePath: logPath
      }
      sqlTempDbSettings: {
        defaultFilePath: tempDbPath
      }
    }
  }
}

output sqlVirtualMachineId string = sqlVirtualMachine.id
```

### 4\. Virtual Machine Module

Note

I want to give a heads-up here too, in this module I pass the password directly in the code.  

Avoid doing this in a production environment.

Instead, use [Azure KeyVault](https://learn.microsoft.com/en-us/azure/key-vault/general/overview) for secure password management.

Create a file named '**virtualMachine.bicep**' and copy the following code into it.

```typescript
targetScope = 'resourceGroup'
param virtualMachineName string
param location string
param virtualMachineSize string
param imageOffer string
param sqlSku string
param adminUsername string
param adminPassword string
param networkInterfaceId string
param dataDisks object
param sqlDataDisksCount int
param sqlLogDisksCount int

resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        name: '${virtualMachineName}-osdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftSQLServer'
        offer: imageOffer
        sku: sqlSku
        version: 'latest'
      }
      dataDisks: [for j in range(0, (sqlDataDisksCount + sqlLogDisksCount)): {
        lun: j
        createOption: dataDisks.createOption
        caching: ((j >= sqlDataDisksCount) ? 'None' : dataDisks.caching)
        writeAcceleratorEnabled: dataDisks.writeAcceleratorEnabled
        diskSizeGB: dataDisks.diskSizeGB
        name: '${virtualMachineName}-datadisk${j}'
        managedDisk: {
          storageAccountType: dataDisks.storageAccountType
        }
      }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceId
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
  }
}

output virtualMachineId string = virtualMachine.id
```

### 5\. Main Bicep File

For the Main file, create a file named '**Main.bicep**' and copy the following code into it.

```typescript
targetScope = 'managementGroup'

param subid string = 'INSERT-SUBSCRIPTION-ID-HERE' // Your Subscription Name
param vmsRG string = 'kf-vms-rg'
param location string = 'norwayeast'
param virtualMachineSize string = 'Standard_Ds1_v2'
param existingVirtualNetworkName string = 'kf-dev-vnet'
param existingVnetResourceGroup string = 'kf-vnet-rg'
param existingSubnetName string = 'kf-dev-vm-snet'
param existingnsgName string = 'nsg1'
param imageOffer string = 'sql2019-ws2019'
param sqlSku string = 'Standard'
param adminUsername string = 'INSERT-AZURE-ADMIN-HERE'
param adminPassword string = 'INSERT-PASSWORD-HERE'
param storageWorkloadType string = 'General'
param dataPath string = 'F:\\SQLData'
param logPath string = 'G:\\SQLLog'
param sqlDataDisksCount int = 1
param sqlLogDisksCount int = 1
param tempDbPath string = 'D:\\SQLTemp'

var dataDisksLuns = range(0, sqlDataDisksCount)
var logDisksLuns = range(sqlDataDisksCount, sqlLogDisksCount)
var subscriptionId = 'INSERT-SUBSCRIPTION-ID-HERE' // Your Subscription Name

@description('Array of SQL Servers')
param sqlServers array = [
  {
    name: 'sqlservervm1'
  }
  {
    name: 'sqlservervm2'
  }
]
// Module for Public IP Address
module publicIpAddress 'modules/publicIpAddress.bicep' = [for sqlServer in sqlServers: {
  name: '${sqlServer.name}-publicIpAddressModule'
  scope: resourceGroup(subid, vmsRG)
  params: {
    publicIpAddressName: '${sqlServer.name}-publicip'
    location: location
    publicIpAddressSku: 'Standard'
    publicIpAddressType: 'Static'
  }
}]

// Module for Network Interface
module networkInterface 'modules/networkInterface.bicep' = [for (sqlServer, idx) in sqlServers: {
  name: '${sqlServer.name}-networkInterfaceModule'
  scope: resourceGroup(subid, vmsRG)
  params: {
    networkInterfaceName: '${sqlServer.name}-nic'
    location: location
    subnetRef: '/subscriptions/${subscriptionId}/resourceGroups/${existingVnetResourceGroup}/providers/Microsoft.Network/virtualNetworks/${existingVirtualNetworkName}/subnets/${existingSubnetName}'
    publicIpAddressId: publicIpAddress[idx].outputs.publicIpAddressId  // Correctly accessing the output using an index
    nsgId: '/subscriptions/${subscriptionId}/resourceGroups/${existingVnetResourceGroup}/providers/Microsoft.Network/networkSecurityGroups/${existingnsgName}'
  }
}]

// Module for Virtual Machine
module virtualMachine 'modules/virtualMachine.bicep' = [for (sqlServer, idx) in sqlServers: {
  name: '${sqlServer.name}-virtualMachineModule'
  scope: resourceGroup(subid, vmsRG)
  params: {
    virtualMachineName: sqlServer.name
    location: location
    virtualMachineSize: virtualMachineSize
    imageOffer: imageOffer
    sqlSku: sqlSku
    adminUsername: adminUsername
    adminPassword: adminPassword
    networkInterfaceId: networkInterface[idx].outputs.networkInterfaceId // Correctly referencing network interface output
    dataDisks: {
      createOption: 'Empty'
      caching: 'ReadOnly'
      writeAcceleratorEnabled: false
      diskSizeGB: 100
      storageAccountType: 'Premium_LRS'
    }
    sqlDataDisksCount: sqlDataDisksCount
    sqlLogDisksCount: sqlLogDisksCount
  }
}]

// Module for SQL Virtual Machine
module sqlVirtualMachine 'modules/sqlVirtualMachine.bicep' = [for (sqlServer, idx) in sqlServers: {
  name: '${sqlServer.name}-sqlVirtualMachineModule'
  scope: resourceGroup(subid, vmsRG)
  params: {
    virtualMachineName: sqlServer.name
    location: location
    virtualMachineId: virtualMachine[idx].outputs.virtualMachineId // Correct integer indexing
    diskConfigurationType: 'NEW'
    storageWorkloadType: storageWorkloadType
    dataDisksLuns: dataDisksLuns
    dataPath: dataPath
    logDisksLuns: logDisksLuns
    logPath: logPath
    tempDbPath: tempDbPath
  }
}]

output adminUsernameOutput string = adminUsername
```

### 6\. Running The Code

You will end up with a folder structure as shown in the picture below.

![][image]

To deploy the Virtual Machine to Azure I use VSCode to execute it.

I'm deploying the code to a Management Group to streamline future deployments.

```bash
az deployment mg create --management-group-id INSERT-MANAGEMENTGROUP-ID-HERE --name "NAME-OF-THE-DEPLOYMENT" --location norwayeast --template-file .\bicep\infrastructure\sqlvm\main.bicep
```

To monitor the deployment process, head to the portal and select the management group you are deploying to.

Once the deployment is complete, the resource group should appear as follows.

![Picture illustrating a resource group with several virtual machine resources][image-9-1024x591]

## Deploying the Recovery Services Vault

In this section we will look at setting up the **Recovery Services Vault** along with Creating the Policy for SQL Server, how to register the SQL Servers and how to enable the AUTOPROTECT feature.

### 1\. Recovery Services Vault Module

Create a file named '**Vault.bicep**' and copy the following code into it.

```typescript
// Vault Module
targetScope = 'resourceGroup'

@description('Parameters')
param vaultName string
param vaultStorageType string
param skuName string
param skuTier string
param publicNetworkAccess string
param location string = resourceGroup().location

resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2022-10-01' = {
  name: vaultName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {

    publicNetworkAccess: publicNetworkAccess

  }
  
}

resource vaultName_vaultstorageconfig 'Microsoft.RecoveryServices/vaults/backupconfig@2023-01-01' = {
  parent: recoveryServicesVault
  name: 'vaultconfig'
  location: location
  properties: {
    storageModelType: vaultStorageType
    softDeleteFeatureState: 'Disabled' // Enable/Disable soft delete for cloud workloads
    enhancedSecurityState: 'Disabled' // Enable/Disable soft delete and security settings for hybrid workloads
  }
}

output vaultid string = recoveryServicesVault.id
```

The Bicep code snippet outlines a module for setting up a **Recovery Services Vault** in Azure, tailored with specific configurations including storage type, SKU, network access, and location.

The module allows customization of the vault's SKU and operational parameters, and importantly, it sets both the **softDeleteFeatureState** and **enhancedSecurityState** to '**Disabled**'.

**Reason for Disabling Features in a Lab Environment**:

**Soft Delete Feature**: Disabling the soft delete feature in this lab environment means that the vault does not retain deleted backup data for an extended period.

This approach is practical for a lab setting where the focus is often on testing and development rather than long-term data retention.

**Enhanced Security State**: The decision to disable enhanced security settings for hybrid workloads in a lab environment is based on the nature of the testing and development work.

In such settings, the primary concern may not be security but rather functionality testing and performance evaluation.

This configuration ensures that the data stored in the vault can be easily deleted after the testing is finished.

### 2\. SQL Server Backup Policy Module

Create a file named '**sqlServerPolicy.bicep**' and copy the following code into it.

```typescript
// SQL Server Policy Module
targetScope = 'resourceGroup'

@description('Parameters')
param vaultName string
param sqlpolicyName string

@description ('Existing Recovery Services Vault')
resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2022-10-01' existing = {
  name: vaultName
}

@description ('BackupPolicy for Azure SQL VMs')
resource sqlbackupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2022-10-01' = {
  parent: recoveryServicesVault
  name: sqlpolicyName
  properties: {
    backupManagementType: 'AzureWorkload'
    protectedItemsCount: 0
    settings: {
      isCompression: true
      issqlcompression: true
      timeZone: 'UTC'
    }
    subProtectionPolicy: [
      {
        policyType: 'Full'
        retentionPolicy: {
          dailySchedule: {
            retentionDuration: {
              count: 30
              durationType: 'Days'
            }
            retentionTimes: [
              '2023-02-02T02:00:00Z'
            ]
          }
          monthlySchedule: {
            retentionDuration: {
              count: 12
              durationType: 'Months'
            }
            retentionScheduleDaily: {
              daysOfTheMonth: [
                {
                  date: 1
                  isLast: false
                }
              ]
            }
            retentionScheduleFormatType: 'Daily'
            retentionTimes: [
              '2023-02-02T02:00:00Z'
            ]
          }
          retentionPolicyType: 'LongTermRetentionPolicy'
        }
        schedulePolicy: {
          schedulePolicyType: 'SimpleSchedulePolicy'
          scheduleRunFrequency: 'Daily'
          scheduleRunTimes: [
            '2023-02-02T02:00:00Z'
          ]
          scheduleWeeklyFrequency: 0
        }
        tieringPolicy: {
          ArchivedRP: {
            duration: 0
            durationType: 'Invalid'
            tieringMode: 'DoNotTier'
          }
        }
      }
      {
        policyType: 'Log'
        retentionPolicy: {
          retentionDuration: {
            count: 7
            durationType: 'Days'
          }
          retentionPolicyType: 'SimpleRetentionPolicy'
        }
        schedulePolicy: {
          scheduleFrequencyInMins: 30
          schedulePolicyType: 'LogSchedulePolicy'
        }
      }
    ]
    workLoadType: 'SQLDataBase'
  }
}
```

The code snippet outlines a Bicep module for creating a backup policy for SQL databases on Azure Virtual Machines within an existing Recovery Services Vault.

It specifies the backup settings, including compression and scheduling, under two sub-protection policies for full and log backups.

The full backup policy provides daily and monthly retention schedules, while the log backup policy ensures frequent backups every 30 minutes.

This setup automates backup procedures and enhances data protection by regularly and securely backing up SQL databases according to schedules and retention policies.

### 2\. SQL Server Registration Module

Create a file named '**sqlVmRegistration.bicep**' and copy the following code into it.

```typescript
// SQL VM Registration Module
targetScope = 'resourceGroup'

@description('Parameters')
param vaultName string
param resourceGroup string
param sqlServers array
@description('Variables')
var backupManagementType = 'AzureWorkload'
var containerType = 'VMAppContainer'
var backupFabric = 'Azure'

@description('Register SQL Virtual Machines in RSV')
resource protectionContainers 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers@2023-01-01' = [for sqlServer in sqlServers: {
  name: '${vaultName}/${backupFabric}/${containerType};compute;${resourceGroup};${sqlServer}'
  properties: {
    containerType: containerType
    backupManagementType: backupManagementType
    workloadType: 'SQLDataBase'
    friendlyName: sqlServer
    sourceResourceId: resourceId(resourceGroup, 'Microsoft.Compute/virtualMachines', sqlServer)
  }
}]
```

The code snippet above is designed to automate the registration of **SQL Virtual Machines** in Azure **Recovery Services Vault** for backup purposes.

It sets up each specified VM to be backed up by defining and iterating over an array of VM names.

Key components include parameters for the vault name and resource group, along with variables that specify the backup management type and container type.

Each VM is registered as a protection container with its configurations for workload type and resource ID.

This automation simplifies the backup setup process, ensuring SQL databases on these VMs are efficiently managed and protected.

### 3\. Protection Intent Module

Create a file named '**protectionIntent.bicep**' and copy the following code into it.

```typescript
// Protection Intent Module
targetScope = 'resourceGroup'
@description('Creates a backup protection intent for a specific item')
param vaultName string
param protectionIntentItems string
param rsvProviderNamespace string
param fabricName string
param autoProtectionContainers string
param policyName string
param backupManagementType string
param protectionIntentItemType string
param autoProtectedItems string
param protectionIntentItemTypes string

resource protectionIntent'Microsoft.RecoveryServices/vaults/backupFabrics/backupProtectionIntent@2023-01-01' = {
  name: '${vaultName}/${fabricName}/${protectionIntentItems}'
  properties: {
    protectionIntentItemType: protectionIntentItemTypes
    backupManagementType: backupManagementType
    parentName: resourceId('${rsvProviderNamespace}/vaults/backupFabrics/protectionContainers', vaultName, fabricName, autoProtectionContainers)
    itemId: resourceId('${rsvProviderNamespace}/vaults/backupFabrics/protectionContainers/protectableItems', vaultName, fabricName, autoProtectionContainers, autoProtectedItems)
    policyId: resourceId('${rsvProviderNamespace}/vaults/backupPolicies', vaultName, policyName)
  }
}
```

In the context of the above code, a **protectionIntentItem** refers to a specific entity or item that you intend to protect through your backup solution.

Specifically, when you're talking about protecting databases on SQL servers, the **protectionIntentItem** would be each individual **database** that you plan to secure with a backup.

This simplifies the management of backup resources; once the server is registered, there's no need to manually enable backup for each database on the servers.

### 5\. Main Bicep File

For the Main file, create a file named '**Main.bicep**' and copy the following code into it.

```typescript
// Main Bicep file for deploying Azure Recovery Services Vault, SQL Server Policy, SQL VM Registration and Protection Intent
targetScope = 'managementGroup'

@description('Parameters for Recovery Services Vault, SQL Server Policy, SQL VM Registration')
param subid string = 'INSERT-SUBSCRIPTION-ID-HERE' // Your Subscription Name
param vmsRG string = 'kf-vms-rg'
param rsvRG string = 'kf-rsv-rg'
param location string = 'norwayeast'
param vaultName string = 'myVault'
param vaultStorageType string = 'LocallyRedundant'
param skuName string = 'Standard'
param skuTier string = 'Standard'
param publicNetworkAccess string = 'Enabled'
param sqlpolicyName string = 'SQLVMPolicy'

@description('Protection Intent Parameters')
param rsvProviderNamespace string = 'Microsoft.RecoveryServices'
param fabricName string = 'Azure'
param backupManagementType string = 'AzureWorkload'
param protectionIntentItemType string = 'SQLInstance'
param protectionIntentItemTypes string = 'RecoveryServiceVaultItem'

@description('Array Intent Parameters')
param sqlServers array = [
  {
    name: 'sqlservervm1'
    resourceGroup: 'kf-vms-rg'
    protectedItems: 'sqlinstance;mssqlserver'
    protectionIntentItems: '123'
  }
  {
    name: 'sqlservervm2'
    resourceGroup: 'kf-vms-rg'
    protectedItems: 'sqlinstance;mssqlserver'
    protectionIntentItems: '456'
  }
]

@description('Vault Module')
module recoveryServicesVault 'modules/vault.bicep' = {
  name: 'vault'
  scope: resourceGroup(subid,rsvRG)
  params: {
    vaultName: vaultName
    vaultStorageType: vaultStorageType
    skuName: skuName
    skuTier: skuTier
    publicNetworkAccess: publicNetworkAccess
    location: location
  }
}

@description('Policy Module')
module policy 'modules/sqlServerPolicy.bicep' = {
  name: 'policyModule'
  scope: resourceGroup(subid,rsvRG)
  dependsOn: [
    recoveryServicesVault  // Ensure vault is deployed before policy
  ]
  params: {
    vaultName: vaultName
    sqlpolicyName: sqlpolicyName
  }
}

@description('SQL VM Registration Module')
module sqlVmRegistration 'modules/sqlVmRegistration.bicep' = [for sqlServer in sqlServers: {
  name: 'sqlVmRegistrationModule-${sqlServer.name}'
  scope: resourceGroup(subid,rsvRG)
  dependsOn: [
    recoveryServicesVault, policy  // Ensure vault is deployed before policy
  ]
  params: {
    vaultName: vaultName
    resourceGroup: vmsRG
    sqlServers: [sqlServer.name]
  }
}]

@description('Protection Intent Module')
module protectionIntentModules 'modules/protectionIntent.bicep' = [for sqlServer in sqlServers: {
  scope: resourceGroup(subid, rsvRG)
  name: 'protectionIntentModule-${sqlServer.name}'
  dependsOn: [
    recoveryServicesVault, policy, sqlVmRegistration  // Ensure vault is deployed before policy
  ]
  params: {
    autoProtectionContainers: 'vmappcontainer;compute;${sqlServer.resourceGroup};${sqlServer.name}'
    autoProtectedItems: sqlServer.protectedItems
    protectionIntentItems: sqlServer.protectionIntentItems
    backupManagementType: backupManagementType
    fabricName: fabricName
    policyName: sqlpolicyName
    protectionIntentItemType: protectionIntentItemType
    rsvProviderNamespace: rsvProviderNamespace
    vaultName: vaultName
    protectionIntentItemTypes: protectionIntentItemTypes
  }
}]
```

The Bicep code above sets up Azure Recovery Services Vault to manage and store backups, configures SQL Server backup policies to ensure data safety, and registers SQL Virtual Machines to the vault.

Additionally, it configures **Auto Protection** for all of the SQL databases running on the servers.

### 4\. Running the Code

You will end up with a folder structure as shown in the picture below.

![][image-1]

Same as above, to deploy this code to Azure, I'm deploying the code to a Management Group to streamline future deployments.

```bash
az deployment mg create --management-group-id "INSERT-MANAGEMENTGROUP-ID-HERE" --name "NAME-OF-THE-DEPLOYMENT" --location norwayeast --template-file .\bicep\infrastructure\backup\main.bicep
```

To monitor the deployment process, head to the portal and select the management group you are deploying to.

Once the deployment is complete, the **SQLVMPolicy** should appear as follows.

![Picture illustrating SQL Backup policy][image-10-1024x828]

You should see 2 registered servers under **Backup Infrastructure** in the Recovery Services Vault.

![Picture illustrating Protected Servers][image-14-1024x218]

Lastly, you will see all databases under the **Backup Items** in the Recovery Services Vault.

![Picture illustrating Backup Items][image-13-1024x319]

## Conclusion

This guide covered the key steps to enable AUTOPROTECT with Bicep, from setting up Recovery Services Vaults to creating and managing SQL Server backup policies.

Do you have thoughts on using Bicep for Azure workloads or tips on optimizing your setup?

Drop a comment below! I’d love to hear about your experiences, challenges, and successes.

Don’t forget to visit my [website](https://kjetilfuras.com/) for more updates, I’ll be posting similar content in the future.

## Additional Resources

- Links to the Official [Azure Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/) and [Bicep awesomeness](https://github.com/ElYusubov/AWESOME-Azure-Bicep).

[image]: image.png
[image-9-1024x591]: image-9-1024x591.png
[image-1]: image-1.png
[image-10-1024x828]: image-10-1024x828.png
[image-14-1024x218]: image-14-1024x218.png
[image-13-1024x319]: image-13-1024x319.png
