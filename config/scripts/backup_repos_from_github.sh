#!/bin/bash

backup_repos_from_github() {
    # Suppress job completion messages
    set +m
    
    # Parse command line arguments
    TARGET_DIR=""
    for arg in "$@"; do
        case $arg in
            --dir=*)
            TARGET_DIR="${arg#*=}"
            shift
            ;;
            *)
            ;;
        esac
    done

    if [ -z "$TARGET_DIR" ]; then
        echo "Error: --dir argument is required"
        echo "Usage: $0 --dir=/path/to/directory"
        return
    fi

    # Get GitHub username from CLI
    if ! GITHUB_USER=$(gh api user --jq .login); then
        echo "Error: Could not get GitHub user"
        echo "Make sure you're authenticated with GitHub CLI (gh auth login)"
        return
    fi

    if [ ! -d "$TARGET_DIR" ]; then
        echo "Error: Directory '$TARGET_DIR' does not exist"
        return
    fi

    # Function to handle a single repository
    handle_repository() {
        local repo="$1"
        local repo_path="$TARGET_DIR/$repo"
        
        if [ -d "$repo_path" ]; then
            # Repository exists, fetch all branches and update current branch
            echo "Updating $repo..."
            if git -C "$repo_path" remote update; then
                echo "✅ Updated $repo"
            else
                echo "❌ Failed to update $repo"
            fi
        else
            # Repository doesn't exist, clone it as mirror
            echo "Cloning $repo..."
            if git clone --mirror "git@github.com:$GITHUB_USER/$repo.git" "$repo_path"; then
                echo "✅ Cloned $repo"
            else
                echo "❌ Failed to clone $repo"
            fi
        fi
    }

    echo "Fetching repositories from GitHub..."
    
    # Get all repositories that are sources (not forks)
    if ! repos=$(gh repo list --source --json name --jq '.[].name'); then
        echo "Error fetching repositories"
        echo "Make sure you're authenticated with GitHub CLI (gh auth login)"
        return
    fi
    
    # Process all repositories
    while IFS= read -r repo; do
        if [ -n "$repo" ]; then
            # Run handle_repository in background for async execution
            handle_repository "$repo" &
        fi
    done <<< "$repos"
    
    # Wait for all background processes to complete
    wait
    
    echo ""
    echo "Repository sync completed!"
}
