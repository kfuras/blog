---
title: "Forgot Windows Admin Password? Fix it Now [2025]"
slug: forgot-windows-admin-password
date: '2025-03-12'
lastmod: '2025-03-12'
draft: false
description: "In this blog post, I will walk you through the steps to regain access to your local admin account using Windows' built-in tools."
summary: "In this blog post, I will walk you through the steps to regain access to your local admin account using Windows' built-in tools."
keywords:
- '2025'
- admin
- cybersecurity
- forgot
- forgot-windows-admin-password
- password
- windows
image:
  src: featured-forgot-windows-admin-password.png
  previewOnly: false
cover:
  image: featured-forgot-windows-admin-password.png
  alt: Forgot Windows Admin Password? Fix it Now [2025] preview
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
- cybersecurity
tags: []
---

In this blog post, I’ll walk you through the steps to regain access to your local admin account using Windows' built-in tools.

If your computer is **BitLocker-protected**, this guide will show you how to unlock it and regain access. However, the method also works for systems **without BitLocker**, so you can follow along regardless of your setup. :)

## **Get Your BitLocker Recovery Key**

To proceed, you need your **BitLocker recovery key**. If you don’t have it yet, follow these steps:

1. Go to your Microsoft account on another device:
    - Visit [https://account.microsoft.com/devices](https://account.microsoft.com/devices)

3. Find your PC in the list of registered devices.

5. Look for the **Recovery Key**, which is a **48-digit key**—you’ll need this later.

## **Scenario 1 - Completely Locked Out**

_If you **cannot log into your PC at all** and don’t have another admin account, follow these steps:_

### **Step 1: Boot Into Windows Setup & Open Command Prompt**

1. **Create a bootable USB drive**:
    - Download a **Windows 10/11 ISO** from Microsoft.
    
    - Use **Rufus** to create a **bootable USB**.

3. **Boot from the USB**:
    - Plug the USB into your PC.
    
    - Restart your PC and **enter the boot menu** (press **F2, F12, ESC, or DEL**, depending on your PC).
    
    - Select the **USB drive** and boot into the **Windows Setup** screen.

5. **Open Command Prompt**:
    - At the **Windows Setup** screen, press **Shift + F10**.
    
    - This will open the **Command Prompt**.

### **Step 2: Identify Your Windows Partition**

1\. At the Command Prompt, type:

```powershell
diskpart
```

_(This will open the Disk Partition Tool.)_

2\. List all available drives:

```powershell
list disk
```

Identify the disk containing **Windows** (usually **Disk 0**).

3\. Select the correct disk:

```powershell
select disk 0
```

_(Replace `0` with the correct disk number if needed.)_

### **Step 3: Show and Mount the Hidden Partition**

1\. List all partitions on the selected disk:

```powershell
list partition
```

2\. Identify the **system partition** (usually the **largest one**). Select this partition:

```powershell
select partition x
```

_(Replace `X` with the correct partition number.)_

3\. Assign a drive letter:

```powershell
assign letter=C
```

_(Now, the hidden partition should be mounted as C:)_

### **Step 4: Unlock the BitLocker Drive**

1\. Now that the drive is mounted, you need to unlock it:

```powershell
manage-bde -unlock C: -RecoveryPassword YOUR-48-DIGIT-KEY
```

**Example:**

```powershell
manage-bde -unlock C: -RecoveryPassword 123456-123456-123456-123456-123456-123456-123456-123456
```

2\. If successful, your drive should now be accessible.

### **Step 5: Modify System Files**

1\. Change the directory to the **System32 folder**:

```powershell
cd c:\windows\system32
```

2\. Backup the **Sticky Keys** file to the `C:\windows\` folder:

```powershell
copy sethc.exe ..
```

3\. Replace `sethc.exe` with the **Command Prompt** executable:

```powershell
copy cmd.exe sethc.exe
```

4\. Close the Command Prompt and boot back into Windows.

### **Step 6: Create a New Admin Account**

1\. At the **Windows login screen**, **press Shift 5 times**.

_(This will open the **Command Prompt**._)

2\. Create a new admin user and add it to the local administrators group:

```powershell
net user "username" "password" /add
net localgroup administrators "username" /add
```

(_Replace `"username"` and _`"password"`__ _with your desired name and password.)_

3\. Close the command prompt and restart your computer. Now, you can log in with your newly created admin account.

### **Step 7: Restore System Files**

1\. Once you regain access, restore `sethc.exe` to its original state:

```powershell
robocopy C:\windows C:\windows\system32 sethc.exe /B
del C:\windows\sethc.exe
```

(_This ensures Sticky Keys functions normally again._)

* * *

## **Scenario 2 - Have Another Admin Account**

_If you can log into your PC with a different account but need to recover access to another admin account, follow these steps instead._

### **Step 1: Boot Into Recovery Mode**

1. Restart your PC **while holding Shift**.

3. Select **Troubleshoot > Advanced options > Command Prompt**.

5. Windows will ask for your **BitLocker key**—enter your **48-digit recovery key**.

### **Step 2: Modify System Files**

1\. Change the directory to the **System32 folder**:

```powershell
cd c:\windows\system32
```

2\. Backup the **Sticky Keys** file to the `C:\windows\` folder:

```powershell
copy sethc.exe ..
```

3\. Replace `sethc.exe` with the **Command Prompt** executable:

```powershell
copy cmd.exe sethc.exe
```

4\. Close the Command Prompt and boot back into Windows.

### **Step 3: **Create a New Admin Account****

1\. At the **Windows login screen**, **press Shift 5 times**.

_(This will open the **Command Prompt**._)

2\. Create a new admin user and add it to the local administrators group:

```powershell
net user "username" "password" /add
net localgroup administrators "username" /add
```

(_Replace `"username"` and _`"password"`__ _with your desired name and password.)_

3\. Close the command prompt and restart your computer. Now, you can log in with your newly created admin account.

### **Step 4: Restore System Files**

1\. Once you regain access, restore `sethc.exe` to its original state:

```powershell
robocopy C:\windows C:\windows\system32 sethc.exe /B
del C:\windows\sethc.exe
```

(_This ensures Sticky Keys functions normally again._)

## Key Takeaways

If you ever lose access to your Windows admin account, these methods can help you regain control. Remember to keep your BitLocker recovery key stored safely to avoid future issues.
