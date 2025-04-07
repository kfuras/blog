---
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
draft: false

showDate: false
showDateOnlyInArticle: false
showDateUpdated: false
showHeadingAnchors: false
showPagination: false
showReadingTime: false
showTableOfContents: true
showTaxonomies: false
showWordCount: false
showSummary: false
sharingLinks: false
showEdit: false
showViews: false
showLikes: false
showAuthor: true
layoutBackgroundHeaderSpace: false

# SEO
summary: "Get to know Kjetil Furas – an IT consultant focused on cloud, automation, and security."
description: "Learn more about Kjetil Furas, a hands-on IT consultant sharing deep-dive guides on Azure, Hugo, and tech automation."
keywords: ["{{ replace .Name "-" " " | title }}"]
image: "img/about-preview.png"
---