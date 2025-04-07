#!/bin/bash

# Exit if no post title is given
if [ -z "$1" ]; then
  echo "Usage: ./new-post.sh \"Your Post Title\""
  exit 1
fi

# Convert input to slug: lowercase, hyphen-separated, safe characters only
POST_SLUG=$(echo "$*" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')

POST_PATH="content/posts/$POST_SLUG"
INDEX_FILE="$POST_PATH/index.md"

# Run Hugo's new post command
hugo new "posts/$POST_SLUG/index.md" >/dev/null

# Create /img folder
mkdir -p "$POST_PATH/img"

# Final confirmation
echo "✅ Post created at \"$POST_PATH/\" with \"img/\" folder."

