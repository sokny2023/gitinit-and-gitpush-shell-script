#!/bin/bash

# Get the list of updated or newly created files
changed_files=$(git diff --cached --name-only)

while true; do
    echo -n "Enter commit message (or press Enter for auto-commit based on file changes): "
    read commit_message

    # Remove leading and trailing whitespace
    commit_message_trimmed="$(echo -e "${commit_message}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

    if [ -z "$commit_message_trimmed" ]; then
        # If no manual message, create auto-commit message based on changed files
        if [ -z "$changed_files" ]; then
            commit_message="Auto commit (no specific file changes)"
        else
            # Use the list of changed files for the commit message
            commit_message="Auto commit: updated $(echo $changed_files | tr '\n' ' ')"
        fi
        break
    else
        commit_message="$commit_message_trimmed"
        break
    fi
done

git add .
git commit -m "$commit_message"
git push

echo "Git commit and push completed successfully!"
