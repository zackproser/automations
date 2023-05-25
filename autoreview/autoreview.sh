#!/bin/bash

# Function to check dependencies
check_dependencies() {
    local DEPS=("mods" "glow")
    local MISSING_DEPS=()

    for dep in "${DEPS[@]}"; do
        if ! command -v $dep &> /dev/null; then
            MISSING_DEPS+=($dep)
        fi
    done

    if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
        echo "The following dependencies are missing:"
        for dep in "${MISSING_DEPS[@]}"; do
            case $dep in
            "mods")
                echo "- mods: https://github.com/charmbracelet/mods"
                ;;
            "glow")
                echo "- glow: https://github.com/charmbracelet/glow"
                ;;
            esac
        done
        exit 1
    fi
}

# Function to get the repo name
get_repo_name() {
    echo $(basename `git rev-parse --show-toplevel`)
}

# Function to generate a markdown file for the review
generate_review_file() {
    local repo_name="$1"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "$AUTOREVIEW_DIR/$repo_name-$timestamp.md"
}

# Function to generate the review and write it to the review markdown file
generate_review() {
    local review_filename="$1"
    printf "\n" >> "$review_filename"
    echo "# Code Review for $REPO_NAME at `date -u +"%Y-%dt%H:%M"`" >> "$review_filename"
    printf "\n" >> "$review_filename"
    echo "## Here's what I found" >> "$review_filename"
    git diff --cached | mods --status-text "Reviewing your code" "$REVIEW_PROMPT" >> "$review_filename"
}

# Check dependencies
check_dependencies

# Directory for review files, can be overridden by setting AUTOREVIEW_DIR environment variable
AUTOREVIEW_DIR="${AUTOREVIEW_DIR:-$HOME/.autoreview}"

# Review prompt, can be overridden by setting REVIEW_PROMPT environment variable
REVIEW_PROMPT="${REVIEW_PROMPT:-* Please perform a code review on this source. List out any logical flaws or bugs you find, ranked in order of severity with the most severe issues presented first. When you spot a bug or issue, please always suggest a remediation. Include code snippets only when necessary to understand the issue.\n* Does the code follow common coding conventions and idioms for the language used? Does it include appropriate tests? If not, suggest initial tests that could be added.}"

# Create the directory if it doesn't exist
mkdir -p "$AUTOREVIEW_DIR"

# Get repo name
REPO_NAME=$(get_repo_name)

# Create a filename with timestamp
REVIEW_FILENAME=$(generate_review_file "$REPO_NAME")

# Check if there are staged changes
if git diff --cached --quiet; then
    echo "No staged changes to review"
    exit 0
fi

# Generate the review
echo "Performing code review. Please sit tight..."
generate_review "$REVIEW_FILENAME"

# Output the review
echo "\nReview file generated at: $REVIEW_FILENAME"
glow "$REVIEW_FILENAME"

