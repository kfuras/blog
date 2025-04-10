---
title: "How to Deploy Fonts on macOS Using Microsoft Intune"
date: '2025-03-26'
lastmod: '2025-03-26'
draft: true
description: "Microsoft Intune allows IT admins to remotely deploy fonts without requiring manual installation. In this post, I\u2019ll walk through how to install fonts on macOS via Intune using a Bash script."
summary: "Microsoft Intune allows IT admins to remotely deploy fonts without requiring manual installation. In this post, I\u2019ll walk through how to install fonts on macOS via Intune using a Bash script."
keywords:
- automation
- deploy
- deploy-fonts-on-macos-intune
- fonts
- intune
- macos
- microsoft
image:
  src: featured.png
  previewOnly: false
cover:
  image: featured.png
  alt: How to Deploy Fonts on macOS Using Microsoft Intune preview
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
tags: []
---

Microsoft Intune allows IT admins to remotely deploy fonts without requiring manual installation. In this post, I’ll walk through how to install fonts on macOS via Intune using a Bash script.

## Why Deploy Fonts via Intune

- Ensure all Mac devices in your organization use the same fonts

- Automate font deployment without requiring user interaction

- Deploy fonts across multiple devices from Microsoft Intune

## Prerequisites

Before proceeding, ensure you have:

- macOS devices enrolled in Intune

- Admin access to Microsoft Intune

## Step 1: Prepare the Deployment Script

This guide can be used to deploy **any fonts**, but for this example, I’ll be deploying **Roboto**.

Use the following shell script to download and install Roboto fonts in `/Library/Fonts` (making them available to all users).

```bash
#!/bin/bash

# Logging to /var/tmp
log="/var/tmp/roboto-install.log"
exec >> "$log" 2>&1
echo "Starting Roboto font installation (system-wide) at $(date)"

# System-wide font directory
FONT_DIR="/Library/Fonts"

# Create the directory if it doesn't exist
mkdir -p "$FONT_DIR"

# Roboto font source
BASE_URL="https://github.com/google/fonts/raw/main/ofl/roboto/"
FONT1="Roboto%5Bwdth%2Cwght%5D.ttf"
FONT2="Roboto-Italic%5Bwdth%2Cwght%5D.ttf"

echo "Downloading Roboto fonts to $FONT_DIR..."

# Download Roboto fonts
curl -L -o "$FONT_DIR/Roboto[wdth,wght].ttf" "${BASE_URL}${FONT1}"
curl -L -o "$FONT_DIR/Roboto-Italic[wdth,wght].ttf" "${BASE_URL}${FONT2}"

echo "Roboto fonts installed successfully in $FONT_DIR"
```

## Step 2: Upload the Script to Microsoft Intune

1. **Go to Microsoft Intune**
    - Navigate to **Devices** > **macOS** > **Scripts**
    
    - Click **\+ Add**

3. **Upload the script**
    - Name: **macOS - Roboto Fonts**
    
    - Description: **Deploys Roboto fonts to macOS devices**
    
    - Upload script: **install\_roboto\_fonts.sh**

5. **Configure Execution Settings**
    - Run script as signed-in user: **No** (This will install it as root)
    
    - Hide script notifications: **Yes** (optional)
    
    - Script frequency: **Every 1 week** (optional)
    
    - Max number of times to retry if script fails: **3 times** (optional)

7. **Assign to Target Mac Devices**
    - Assign to a **test group** first.
    
    - Deploy to **production devices** once tested.

## Step 3: Verify Installation

Once deployed, confirm the fonts are installed:

- Open **Launchpad** or **Spotlight** and search for **font**.

- Select the **Font Book** app and verify that **Roboto** is in the font list.

## Troubleshooting & Logs

If the fonts don’t install, check the install logs using:

```bash
cat /var/tmp/roboto-install.log | grep -i roboto
```

## Final Thoughts

By using **Microsoft Intune**, you can automate font deployment across your macOS devices, reducing manual work for IT admins. This approach can be adapted to deploy **any other fonts** required by your organization.
