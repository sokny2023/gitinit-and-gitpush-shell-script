#!/bin/bash

# Hardcoded GitHub username
github_username="sokny2023"

# GitHub token (replace with your own token)
github_token="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"

# Prompt for the repository name (without new line)
echo -n "Enter the name of the new repository: "
read repo_name

# Prompt for the project directory path (without new line)
echo -n "Enter the path to your project directory (example: D:/devops/nextjs): "
read project_dir

# Convert Windows-style paths (C:\ to /c/) for Git Bash/WSL compatibility
project_dir=$(echo "$project_dir" | sed 's|\\|/|g' | sed 's|^\([a-zA-Z]\):|/\L\1|')

# Check if the directory exists
if [ ! -d "$project_dir" ]; then
    echo "Directory does not exist. Please provide a valid path."
    exit 1
fi

# Navigate to the project directory
cd "$project_dir" || exit

# Confirm the working directory
echo "Initializing repository in: $(pwd)"

# Prompt to choose between private or public repository (without new line)
echo -n "Do you want the repository to be private (pr) or public (pu)?: "
read repo_visibility

# Set visibility flag
if [ "$repo_visibility" == "pr" ]; then
    visibility="true"
elif [ "$repo_visibility" == "pu" ]; then
    visibility="false"
else
    echo "Invalid input! Please enter 'pr' for private or 'pu' for public."
    exit 1
fi

# Initialize the Git repository locally (in the project directory)
git init

# Automatically add .gitkeep files to empty directories
find . -type d -empty -exec touch {}/.gitkeep \;

# Write the script to gitc.sh file using cat
cat <<'EOF' > gitc.sh
#!/bin/bash
while true; do
    echo -n "Enter commit message (or press Enter for auto-commit): "
    read commit_message

    # Remove leading and trailing whitespace
    commit_message_trimmed="$(echo -e "${commit_message}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

    if [ -z "$commit_message_trimmed" ]; then
        commit_message="Auto commit"
        break
    else
        commit_message="$commit_message_trimmed"
        break
    fi
done

git add .
git commit -m "$commit_message"
git push

echo "Git commit and push complete!"
EOF

# Make the gitc.sh file executable
chmod +x gitc.sh

# Add all files and folders (including gitc.sh and .gitkeep files in empty directories) to the Git repository
git add .

# Commit the files (including gitc.sh and empty directories with .gitkeep)
git commit -m "Initial commit for $repo_name"

# Create a GitHub repository using GitHub API
echo "Creating repository '$repo_name' on GitHub..."

# Use GitHub API to create a repository
response=$(curl -s -H "Authorization: token $github_token" \
-d "{\"name\":\"$repo_name\", \"private\":$visibility}" \
https://api.github.com/user/repos)

# Print the API response for debugging
echo "API Response: $response"

# Extract the repository URL from the response
repo_url=$(echo $response | grep -oP '"clone_url": "\K(.*?)(?=")')

# If repository creation was successful, proceed
if [ -n "$repo_url" ]; then
    echo "Repository created successfully: $repo_url"

    # Add the remote repository
    git remote add origin "$repo_url"
    git branch -M main
    git push -u origin main
    echo "Pushed local repository to GitHub!"
else
    echo "Failed to create GitHub repository. Please check your token or repository name."
fi
