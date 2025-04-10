---
title: "{{ replace .File.ContentBaseName "-" " " | title }}"
date: {{ .Date }}
lastmod: {{ .Date }}
draft: true

# SEO
description: ""
summary: ""
keywords: []

# Cover & social preview image
# Make sure to save 'featured-{{ .File.ContentBaseName }}.png' next to index.md
image:
  src: "featured-{{ .File.ContentBaseName }}.png"
  previewOnly: false

cover:
  image: "featured-{{ .File.ContentBaseName }}.png"
  alt: "{{ replace .File.ContentBaseName "-" " " | title }} preview"
  caption: ""

# UX & layout
showTableOfContents: true
showAuthor: true
showReadingTime: true
showSummary: true
showDate: true
showDateUpdated: true
showTaxonomies: false
layoutBackgroundHeaderSpace: false

# Taxonomy
categories: []
tags: []

# Optional slug override — comment this out unless needed
# slug: "{{ .File.ContentBaseName }}"

# Optional canonical URL — only use if content is mirrored elsewhere
# canonicalURL: "https://kjetilfuras.com/posts/{{ .File.ContentBaseName }}/"
---