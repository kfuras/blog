---
# Auto-generated post title from the filename
title: "{{ replace .File.ContentBaseName "-" " " | title }}"

# SEO meta description (keep it ~160 characters)
description: ""

# Summary for previews and list pages
summary: ""

# Creation and last modified dates
date: {{ .Date }}
lastmod: {{ .Date }}

# Draft mode enabled by default until ready to publish
draft: true

# Clean URL path
slug: "{{ .File.ContentBaseName }}"

# Optional taxonomy
categories:
  - Blog
tags:
  - ""

# Author name (optional)
author: "Kjetil Furås"

# Enable summary on list pages
showSummary: true

# Social sharing & Open Graph image (also used as cover image)
# This image should be placed next to index.md as 'featured.png'
image:
  src: "posts/{{ .File.ContentBaseName }}/featured.png"
  previewOnly: false

# Cover image shown at top of post (same as featured)
cover:
  image: "posts/{{ .File.ContentBaseName }}/featured.png"
  alt: ""     # Add a descriptive alt text manually later
  caption: "" # Optional caption

# Canonical URL for SEO — change this if the post is mirrored elsewhere
canonicalURL: "https://kjetilfuras.com/posts/{{ .File.ContentBaseName }}/"
---