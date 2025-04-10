---
title: "How I Manage My SSH Keys Across Multiple Servers and GitHub"
date: ''
lastmod: ''
draft: true
description: "Managing SSH keys across multiple servers and platforms can get messy fast \u2014 especially when you have a homelab, VPS, GitHub repos, and more. I used to juggle one or two keys across everything... until I hit name collisions, agent confusion, and \"wrong key\" errors."
summary: "Managing SSH keys across multiple servers and platforms can get messy fast \u2014 especially when you have a homelab, VPS, GitHub repos, and more. I used to juggle one or two keys across everything... until I hit name collisions, agent confusion, and \"wrong key\" errors."
keywords:
- across
- github
- keys
- manage
- multiple
- servers
- how-i-manage-my-ssh-keys
image:
  src: featured.png
  previewOnly: false
cover:
  image: featured.png
  alt: How I Manage My SSH Keys Across Multiple Servers and GitHub preview
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

Managing SSH keys across multiple servers and platforms can get messy fast — especially when you have a homelab, VPS, GitHub repos, and more. I used to juggle one or two keys across everything... until I hit name collisions, agent confusion, and "wrong key" errors.

Now I generate **one key per service or server**, store them with meaningful filenames, and use an organized `~/.ssh/config` to control how each is used.

Here’s how I do it — and how you can too.

## My SSH Key Directory Structure

```
~/.ssh/
├── id_ed25519_homelab
├── id_ed25519_homelab.pub
├── id_ed25519_hetzner
├── id_ed25519_hetzner.pub
├── id_ed25519_github
├── id_ed25519_github.pub
├── config
```

## Step-by-Step Setup

### 1\. Generate a Separate Key for Each Server

```
ssh-keygen -t ed25519 -C "docker-01" -f ~/.ssh/id_ed25519_docker_01
ssh-keygen -t ed25519 -C "pve-1" -f ~/.ssh/id_ed25519_pve_1
ssh-keygen -t ed25519 -C "hetzner" -f ~/.ssh/id_ed25519_hetzner_example
ssh-keygen -t ed25519 -C "github"  -f ~/.ssh/id_ed25519_github_example
```

> Tip: You can skip the passphrase for convenience or add one for security.

### 2\. Copy Your Public Keys to the Remote Hosts

```
ssh-copy-id -i ~/.ssh/id_ed25519_docker_01.pub kaf@10.160.0.22
ssh-copy-id -i ~/.ssh/id_ed25519_pve_1.pub root@10.160.0.20
ssh-copy-id -i ~/.ssh/id_ed25519_hetzner.pub root@your-vps-ip
```

### 3\. Configure Your `~/.ssh/config`

```
vim ~/.ssh/config
```

Example:

```
# Docker server
Host docker-01
  HostName 10.160.0.22
  User kaf
  IdentityFile ~/.ssh/id_ed25519_docker_01

# Proxmox node
Host pve-1
  HostName 10.160.0.20
  User root
  IdentityFile ~/.ssh/id_ed25519_pve_1

# Hetzner VPS
Host hetzner
  HostName 65.21.xx.xx
  User root
  IdentityFile ~/.ssh/id_ed25519_hetzner

# GitHub
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_github
  IdentitiesOnly yes
```

> `IdentitiesOnly yes` prevents SSH from trying other keys — helps avoid confusion when multiple keys are loaded.

### 4\. Add SSH Key to GitHub

### 4.1. Copy the Public Key

- **macOS:**

```
pbcopy < ~/.ssh/id_ed25519_github.pub
```

- **Linux:**

```
xclip -sel clip < ~/.ssh/id_ed25519_github.pub
# or 
wl-copy < ~/.ssh/id_ed25519_github.pub
```

### 4.2. Add to GitHub

1. Visit [GitHub SSH settings](https://github.com/settings/keys)

3. Click **"New SSH key"**

5. Give it a meaningful name

7. Paste the key

9. Click **"Add SSH key"**

## Test Your Setup

```
ssh docker-01
ssh pve-1
ssh hetzner
ssh -T git@github.com
```

If everything’s set up correctly, GitHub will reply:

```
Hi kfuras! You've successfully authenticated, but GitHub does not provide shell access.
```

## Bonus Tips

### Add Keys to SSH Agent (Optional)

```
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_docker_01
```

### See Which Key is Used

```
ssh -v docker-01
```

You’ll see a line like:

```
Offering public key: ~/.ssh/id_ed25519_docker_01
```

### Optional: Disable Password Prompt for sudo

If you're tired of typing your password every time you use `sudo`, you can edit the `sudoers` file:

```
sudo visudo
```

Look for this line and change it:

```
-%sudo  ALL=(ALL:ALL) ALL
+%sudo  ALL=(ALL:ALL) NOPASSWD: ALL
```

Just be careful — removing password prompts reduces security, especially on multi-user or production systems.

## Final Thoughts

This setup has completely decluttered my SSH workflow — no more guessing which key is being used, or why I can’t connect. Whether you're running a homelab, cloud servers, or just want GitHub SSH access done right, this pattern is clean, scalable, and easy to maintain.
