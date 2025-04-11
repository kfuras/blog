---
title: "Automate Certificates with Azure Arc &amp; Azure Key Vault"
slug: azure-arc-key-vault-certificates
date: '2025-03-21'
lastmod: '2025-03-21'
draft: false
description: "Managing certificates across hybrid environments can be a complex challenge for IT administrators. Azure Arc, combined with Azure Key Vault, provides a seamless solution for managing certificates on hybrid servers without requiring full migration to Azure."
summary: "Managing certificates across hybrid environments can be a complex challenge for IT administrators. Azure Arc, combined with Azure Key Vault, provides a seamless solution for managing certificates on hybrid servers without requiring full migration to Azure."
keywords:
- automate
- automation
- azure
- azure-arc-key-vault-certificates
- azure-cloud
- certificates
- vault
image:
  src: featured-azure-arc-key-vault-certificates.png
  previewOnly: false
cover:
  image: featured-azure-arc-key-vault-certificates.png
  alt: Automate Certificates with Azure Arc &amp; Azure Key Vault preview
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
- automation
- azure-cloud
tags: []
---

Managing certificates across hybrid environments can be a complex challenge for IT administrators. Azure Arc, combined with Azure Key Vault, provides a seamless solution for managing certificates on hybrid servers without requiring full migration to Azure.

In this post, we will learn how to automate certificate management using Azure Arc & Azure Key Vault for secure hybrid cloud environments.

## **How Azure Arc & Azure Key Vault Simplify Certificate Management**

Using [Azure Arc](/securing-tier-0-systems-in-azure-arc/) allows you to extend Azure management capabilities to your on-premises or multi-cloud servers, treating them as Azure resources. By integrating **Azure Key Vault**, you can securely store and manage certificates, reducing the risk of expired or mismanaged certificates in your infrastructure.

### **Key Benefits:**

- Store and manage certificates in a secure Azure Key Vault.

- Distribute certificates to Arc-enabled servers automatically.

- Utilize Azure’s RBAC and Managed Identity to control access.

- Maintain logs and alerts using Azure Security tools.

## **Prerequisites**

Before setting up certificate management via Azure Arc, ensure you have the following:

- A Windows Server registered with Azure Arc.

- An Azure Key Vault with the required certificates.

- An Azure subscription with the required permissions.

- PowerShell modules installed.

- Azure RBAC permissions to manage Key Vault certificates.

## **Setting Up the Lab Environment**

To demonstrate this process, I have set up a **test virtual machine** running **Windows Server 2022** in my homelab. Additionally, I have:

- Created a **Resource Group** in Azure.

- Deployed an **Azure Key Vault**.

- Registered and connected the Windows Server to **Azure Arc**.

With the environment ready, let’s move on to the configuration steps.

### **Step 1: Get Your Object ID**

You need your Entra ID **Object ID** for your user or service principal.

Run this command to get your **User Object ID**:

```powershell
(Get-AzADUser -UserPrincipalName "<your-email@example.com>").Id
```

### **Step 2: Assign Key Vault Permissions Using RBAC**

I will assign myself the **Key Vault Administrator** role (I will be using this role to create a self-signed certificate in step 3).

Run this command:

```powershell
$vaultResourceId = "/subscriptions/<YourSubscriptionID>/resourceGroups/<MyResourceGroup>/providers/Microsoft.KeyVault/vaults/<YourKeyVault>"
$objectId = "<YourObjectId>" # Replace with your actual Object ID

New-AzRoleAssignment -ObjectId $objectId -RoleDefinitionName "Key Vault Administrator" -Scope $vaultResourceId
```

### **Step 3: Generate a Self-Signed Certificate**

Azure provides the option to create a self-signed certificate, I will be using this because, in this lab, I don’t have access to a real Certification Authority.

Below is an example of how to create one and store it in Key Vault.

```powershell
# Create a self-signed certificate and store it in Key Vault
$certName = "<YourSelfSignedCert>"
$keyVaultName = "<YourKeyVault>"

# Create the self-signed certificate
$Policy = New-AzKeyVaultCertificatePolicy -SecretContentType "application/x-pkcs12" -SubjectName "CN=contoso.com" -IssuerName "Self" -ValidityInMonths 12 -ReuseKeyOnRenewal

# Import the certificate to Key Vault
Add-AzKeyVaultCertificate -VaultName $keyVaultName -Name $certName -CertificatePolicy $Policy
```

### **Step 4: Verify that the Certificate is ready**

Once the certificate is generated, check if its ready by running:

```powershell
Get-AzKeyVaultCertificate -VaultName $keyVaultName -Name $certName
```

### **Step 5: Get the Arc Server’s Managed Identity**

Get the **Principal ID** of the Arc-enabled server in Azure:

```powershell
Get-AzConnectedMachine -ResourceGroupName "<YourResourceGroup>" | Select IdentityPrincipalId
```

Copy the **Object ID** from the output.

### **Step 6: Assign the Key Vault Secrets User Role**

Now, assign the **Key Vault Certificate User** role to the Arc-enabled server.

```powershell
$objectId = "<YourObjectId>"
$vaultResourceId = "/subscriptions/<YourSubscriptionID>/resourceGroups/<YourResourceGroup>/providers/Microsoft.KeyVault/vaults/<YourKeyVault>"

New-AzRoleAssignment -ObjectId $objectId -RoleDefinitionName "Key Vault Certificate User" -Scope $vaultResourceId
```

This will grant the Arc-enabled server **read access** to certificates in Azure Key Vault.

### **Step 7: Deploy the Azure Arc Key Vault** **extension**

Now you can deploy the extension to the server. For that run this command on your admin workstation with the Az.ConnectedMachine module installed.

```powershell
$Settings = @{
secretsManagementSettings = @{
observedCertificates = @(
"https://<YourKeyVault>.vault.azure.net:443/secrets/<YourSelfSignedCert>"
# Add more here in a comma separated list
)
certificateStoreLocation = "LocalMachine"
certificateStoreName = "My"
pollingIntervalInS = "3600" # every hour
}
authenticationSettings = @{
# Don't change this line, it's required for Arc enabled servers
msiEndpoint = "<http://localhost:40342/metadata/identity>"
}
}
$ResourceGroup = "<YourResourceGroup>"
$ArcMachineName = "<YourArcMachineName>"
$Location = "<YourLocation>"

New-AzConnectedMachineExtension -ResourceGroupName $ResourceGroup -MachineName $ArcMachineName -Name "KeyVaultForWindows" -Location $Location -Publisher "Microsoft.Azure.KeyVault" -ExtensionType "KeyVaultForWindows" -Setting $Settings
```

## Logging

Logging path to the KeyVaultForWindows Extension

```powershell
C:\ProgramData\GuestConfig\extension_logs\Microsoft.Azure.KeyVault.KeyVaultForWindows\
```

To view extension logs run the following command:

```powershell
cat C:\ProgramData\GuestConfig\extension_logs\Microsoft.Azure.KeyVault.KeyVaultForWindows\akvvm_service_2025-03-19_21-56-29.19.log
```

Check for installed extensions:

```powershell
Get-AzConnectedMachineExtension -ResourceGroupName "<YourResourceGroup>" -MachineName "<YourArcMachineName>"
```

## **Key Takeaways**

By leveraging **Azure Arc** and **Azure Key Vault**, you can automate certificate management across hybrid environments without manual intervention.

Implementing this solution will help organizations maintain secure, up-to-date certificates while reducing the risk of outages due to expired certificates.

## **References**

- [Azure Arc-Enabled Servers Documentation](https://learn.microsoft.com/en-us/azure/azure-arc/servers/overview)

- [Azure Key Vault Certificate Management](https://learn.microsoft.com/en-us/azure/key-vault/certificates/)
