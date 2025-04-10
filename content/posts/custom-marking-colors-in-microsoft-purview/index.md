---
title: "Custom Marking Colors in Microsoft Purview"
date: '2024-10-03'
lastmod: '2024-10-03'
draft: false
description: "When working with sensitivity labels in Microsoft Purview, customizing header and footer content markings is key to maintaining your organization\u2019s branding and visual standards."
summary: "When working with sensitivity labels in Microsoft Purview, customizing header and footer content markings is key to maintaining your organization\u2019s branding and visual standards."
keywords:
- colors
- custom
- custom-marking-colors-in-microsoft-purview
- marking
- microsoft
- microsoft-365
- purview
image:
  src: featured-custom-marking-colors-in-microsoft-purview.png
  previewOnly: false
cover:
  image: featured-custom-marking-colors-in-microsoft-purview.png
  alt: Custom Marking Colors in Microsoft Purview preview
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

When working with sensitivity labels in Microsoft Purview, customizing header and footer content markings is key to maintaining your organization’s branding and visual standards.

These markings highlight sensitive information, helping users identify the security level of a document at a glance.

However, the Microsoft Purview portal has limitations, especially when it comes to setting custom colors for these markings.

If you've tried using the portal to apply specific header or footer colors, you've likely found the options are limited to the options below.

![Custom Marking Colors in Microsoft Purview][image-1]

This limitation means you can't use the portal to fully control the look of your content markings.

To solve this, you have to use PowerShell.

Through PowerShell, you can apply specific hex color codes for your labels.

Without this, you're limited to basic options in the portal, which might not suit all security or branding needs.

Also, the default Yellow on-white is barely seen.

## Custom Header and Footer Content Marking Colors

First, we need to install the PowerShell modules needed.

Install and import the Exchange Online PowerShell Module.

```powershell
Install-Module ExchangeOnlineManagement
Import-Module ExchangeOnlineManagement
```

Then, run the following to connect to Microsoft Purview:

```powershell
Connect-IPPSSession
```

We will use a cmdlet named **Set-Label**, this cmdlet changes the header or footer marking color for documents.

Note

The **Set-Label** cmdlet does more than just change header or footer marking colors for documents.  
It allows you to configure various sensitivity label settings, to explore all the capabilities of **Set-Label**, [read more here](https://learn.microsoft.com/en-us/powershell/module/exchange/set-label?view=exchange-ps).

### Apply Content Marking Colors

You define the colors for each header and footer by specifying hex color codes.

This allows total control over the exact colors that match your organization’s branding or security needs.

Start by opening PowerShell with administrative rights. Then, run the following:

```powershell
Set-Label -Identity LabelName -ApplyContentMarkingHeaderFontColor '#FFA500'
```

Change **LabelName** to your label’s name, and replace the hex code with your preferred color.

This gives your documents a professional and secure look, ensuring that anyone who views them recognizes the sensitivity markings immediately.

This method ensures that every document marked with a sensitivity label stands out.

## Summary

In summary, the colors you choose for your sensitivity labels are more than just a design choice.

Thoughtfully selected colors help ensure sensitive information is easily recognized and safeguarded, reducing the risk of data breaches.

So, choose your colors wisely, align them with your security needs, and use them to strengthen your defense like a true expert!

[image-1]: image-1.png
