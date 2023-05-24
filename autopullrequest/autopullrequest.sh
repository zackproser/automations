#!/usr/bin/env bash

check_dependencies() {
    local DEPS=("mods" "gum" "glow" "gh")
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
            "gum")
                echo "- gum: https://github.com/charmbracelet/gum"
                ;;
            "glow")
                echo "- glow: https://github.com/charmbracelet/glow"
                ;;
            "gh")
                echo "- gh: https://github.com/cli/cli"
                ;;
            esac
        done
        exit 1
    fi
}

# Function to determine if the current working directory is a git repository
function is_git_repository() {
  git -C . rev-parse 2> /dev/null
}

function get_default_branch() {
  git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
}

function get_current_branch() {
  git rev-parse --abbrev-ref HEAD
}

function get_commits_for_branch() {
  git --no-pager log --pretty=format:"%s" --cherry "$(get_default_branch)"..."$(get_current_branch)"
}

function summarize_commit_messages() {
  readonly commit_messages="$1"

  local commit_summary
  commit_summary="$(mods "Summarize these git commits into a pull request description. Include a high level summary of what the changes do, context for the changes, and anything else commonly appearing in high quality pull request descriptions" -f < "$commit_messages")"
  echo "$commit_summary"

}

autopullrequest() {
  if ! is_git_repository; then
    echo "Not a git repository"
    exit 1
  fi

  check_dependencies

  commits=$(get_commits_for_branch)
  if [ -z "$commits" ]; then
    echo "No commits found"
    exit 1
  fi

  summary=$(summarize_commit_messages "$commits")
  echo "$summary"
}

autopullrequest

