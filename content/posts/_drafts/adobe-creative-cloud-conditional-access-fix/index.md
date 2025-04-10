---
title: "Fix Adobe Creative Cloud Conditional Access Login Issues"
date: ''
lastmod: ''
draft: true
description: "Recently, while working with a customer, I had to troubleshoot a frustrating issue with an Adobe Creative Cloud Application. The application was deployed successfully, the user was licensed, SSO was enabled, yet when launching the application, the embedded browser window popped up asking the user to sign in."
summary: "Recently, while working with a customer, I had to troubleshoot a frustrating issue with an Adobe Creative Cloud Application. The application was deployed successfully, the user was licensed, SSO was enabled, yet when launching the application, the embedded browser window popped up asking the user to sign in."
keywords:
- access
- adobe
- adobe-creative-cloud-conditional-access-fix
- cloud
- conditional
- creative
- issues
- login
image:
  src: featured.png
  previewOnly: false
cover:
  image: featured.png
  alt: Fix Adobe Creative Cloud Conditional Access Login Issues preview
  caption: ''
showTableOfContents: true
showAuthor: true
showReadingTime: true
showSummary: false
showDate: true
showDateUpdated: true
showTaxonomies: true
layoutBackgroundHeaderSpace: false
categories: []
tags: []
---

Recently, while working with a customer, I had to troubleshoot a frustrating issue with an Adobe Creative Cloud Application. The application was deployed successfully, the user was licensed, SSO was enabled, yet when launching the application, the embedded browser window popped up asking the user to sign in.

## The Setup

The customer enforces Conditional Access policies in Entra ID that require applications to be accessed only from compliant or Entra ID-joined devices. This works well for most apps, especially those that authenticate through modern browsers like Edge or Chrome.

But Adobe Creative Cloud wasn’t cooperating.

The login prompt inside the Adobe app looked like a browser popup, but it wasn’t passing device identity to Entra ID. That meant Entra ID couldn’t evaluate the identity of the device, and the login was blocked.

## The Root Cause

Turns out, the embedded browser used by Adobe Creative Cloud is a lightweight, standalone webview that impersonates Edge/Chrome for compatibility, but it doesn’t actually support Chrome extensions or device identity pass-through.

This meant Entra ID couldn’t verify the login.

## The Fix

Fortunately, Adobe offers [workarounds](https://helpx.adobe.com/acrobat/kb/cef-based-sign-in-not-working-with-azure-ad-conditional-access.html); one of the workarounds is that you can force Adobe Creative Cloud to use the default system browser for login instead of the embedded one.

This is done by setting a registry key. I used Patch My PC’s post-script feature to deploy it across all managed devices:

```powershell
$regPath = "HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown"

if (-not (Test-Path -LiteralPath $regPath)) {
    New-Item -Path $regPath -Force -ErrorAction SilentlyContinue
}

New-ItemProperty -Path $regPath `
    -Name "iAcroLoginType" `
    -Value 5 `
    -PropertyType DWord `
    -Force `
    -ErrorAction SilentlyContinue
```

Once this key is set, Adobe Creative Cloud opens the sign-in process in your default browser.

### Why This Works

When the sign-in happens in a full browser:

- If it’s Microsoft Edge, device identity is passed through automatically (assuming the user is signed in with their corporate account).

- If it’s Chrome, device identity is passed through only if one of the following is true:
    - The Windows Accounts or Microsoft 365 extension is installed
    
    - Chrome 111+ is configured with CloudAPAuthEnabled

This way, Conditional Access can evaluate the login correctly, and Adobe authentication works as expected.

### Final Thoughts

If Adobe Creative Cloud is blocked by Conditional Access even on compliant devices, check how the app is authenticating. If it’s using an embedded browser, it might not be passing device identity.

Forcing Adobe to use the system browser for login via registry key can resolve this and maintain your Conditional Access policies without needing to whitelist the app.

This small registry tweak saved hours of troubleshooting and is easily deployable with Intune or tools like Patch My PC.
