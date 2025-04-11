---
title: "Automate Blog Image Creation Using Python"
slug: automate-blog-image-creation-using-python
date: '2025-04-07'
lastmod: '2025-04-07'
draft: false
description: "Creating a featured image for every blog post used to be the most tedious part of publishing for me. I wanted consistent, branded visuals \u2014 but manually designing them in Canva, copying over titles, tweaking layouts, and exporting each one quickly became a chore."
summary: "Creating a featured image for every blog post used to be the most tedious part of publishing for me. I wanted consistent, branded visuals \u2014 but manually designing them in Canva, copying over titles, tweaking layouts, and exporting each one quickly became a chore."
keywords:
- automate
- automate-blog-image-creation-using-python
- automation
- blog
- creation
- image
- python
image:
  src: featured-automate-blog-image-creation-using-python.png
  previewOnly: false
cover:
  image: featured-automate-blog-image-creation-using-python.png
  alt: Automate Blog Image Creation Using Python preview
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

Creating a featured image for every blog post used to be the most tedious part of publishing for me. I wanted consistent, branded visuals — but manually designing them in Canva, copying over titles, tweaking layouts, and exporting each one quickly became a chore.

So I automated the entire process.

Now I generate 1200×628px featured images using a Python script in seconds — complete with a clean background, styled title, category label, and domain name.

> I created the background images in Canva using a free account and added my domain name at the bottom for branding.

![Image illustrating my featured image][automation-1024x536]

## Why Automate Featured Images?

- Keeps my posts visually consistent

- Saves tons of time — 5+ images in seconds

- Looks polished on my homepage and in social previews

- Lets me focus on content, not design fiddling

## Tools I Use

- **[Python 3](https://www.python.org/downloads/)** (preinstalled on macOS/Linux)

- **[Pillow](https://pypi.org/project/pillow/)** (Python Imaging Library)

- **[DejaVuSans-Bold.ttf](https://dejavu-fonts.github.io/)** font

- **Backgrounds** (one per category, stored as PNGs)

- **A CSV file** with blog post titles and categories

## My Python Script

The script reads a CSV file of blog titles and categories, selects the matching background, adds a semi-transparent dark overlay, then draws a category label and centers the title text with a subtle shadow for better readability.

Here’s a trimmed version of the script:

```python
from PIL import Image, ImageDraw, ImageFont
import csv, os

# --- Config ---
WIDTH, HEIGHT = 1200, 628
FONT_PATH = "fonts/DejaVuSans-Bold.ttf"
FONT_SIZE = 50
SMALL_FONT_SIZE = 24
TEXT_COLOR = "white"
SHADOW_COLOR = "black"
OUTPUT_DIR = "generated-images"
BACKGROUND_DIR = "backgrounds"

# --- Setup ---
os.makedirs(OUTPUT_DIR, exist_ok=True)
font = ImageFont.truetype(FONT_PATH, FONT_SIZE)
small_font = ImageFont.truetype(FONT_PATH, SMALL_FONT_SIZE)

# --- Process CSV ---
with open("titles.csv", newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        title = row.get("title", "").strip()
        category = row.get("category", "").strip()
        if not title or not category:
            continue

        # ... image generation logic goes here
```

> You can view the [full script on GitHub](https://github.com/kfuras/lab/tree/main/python/blog-image-generator).

## How It Works

1. Looks up a background image per category

3. Applies a semi-transparent dark overlay

5. Adds a category label top-left

7. Wraps the title text and centers it

9. Exports a PNG with a clean filename

## CSV Example

```bash
title,category
Automate Blog Image Creation Using Python,Automation
Hardening Azure VM SSH Access,Cybersecurity
Deploying Web Apps with Bicep,Azure Cloud
Running Plex in Proxmox,Homelab
Building an IaC Lab,IaC
Enable Sensitivity Labels in Outlook,Microsoft 365
```

To generate an image, make sure each row in the CSV has a populated title — the script skips empty titles.

Then, run the following:

```bash
cd lab/python/blog-image-generator
python3 generate_images.py
```

If it was successful you will see something like this:

```batch
✅ Created: generated-images/automate-blog-image-creation-using-python.png
```

You’ll find the generated image inside the `generated-images/` folder.

It should look like this:

![][automate-blog-image-creation-using-python-1024x536]

## Final Thoughts

This little tool saves me a ton of time, keeps my blog visually consistent, and lets me focus on writing instead of fiddling with design.

Happy automating!

_Found this helpful?_ Check out [more tech tutorials](https://kjetilfuras.com/blog/) or follow me on [GitHub](https://github.com/kfuras), where I share homelab setups, automation tools, and real-world projects from my day-to-day work as an IT consultant.

[automation-1024x536]: automation-1024x536.png
[automate-blog-image-creation-using-python-1024x536]: automate-blog-image-creation-using-python-1024x536.png
