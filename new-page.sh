#!/bin/bash

# Exit if no page name is given
if [ -z "$1" ]; then
  echo "Usage: ./new-page.sh \"Your Page Name\""
  exit 1
fi

# Convert input to slug: lowercase, hyphen-separated
PAGE_SLUG=$(echo "$*" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# Set the target path
PAGE_PATH="content/$PAGE_SLUG"
INDEX_FILE="$PAGE_PATH/index.md"

# Run Hugo's new command with custom kind
hugo new --kind page "$PAGE_SLUG/index.md" >/dev/null

# Final confirmation
echo "✅ Page created at \"$PAGE_PATH/\""
