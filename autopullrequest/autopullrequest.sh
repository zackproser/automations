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
  git remote show origin | awk '/HEAD branch/ {print $NF}'
}

function get_current_branch() {
  git rev-parse --abbrev-ref HEAD
}

function get_commits_for_branch() {
    git --no-pager log --pretty=format:"%s" ..."$(get_default_branch)"
}

function summarize_commit_messages() {
  readonly commit_messages="$1"

  local commit_summary
  commit_summary="$(echo "$commit_messages" | mods "Summarize these git commits into a pull request description. Include a high level summary of what the changes do, context for the changes, and anything else commonly appearing in high quality pull request descriptions")"
  echo "$commit_summary"
}

function create_title_from_summary() {
  readonly commit_summary="$1"

  pr_title="$(echo "$commit_summary" | mods "Write a pull request title based of this summary. Make sure it is concise yet perfectly descriptive of the changes")"
  echo "$pr_title"
}

function ensure_changes_pushed() {
  git push -u origin "$(get_current_branch)"
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

  ensure_changes_pushed

  summary=$(summarize_commit_messages "$commits")

  title=$(create_title_from_summary "$summary")


  gh pr create --title "$title" --body "$summary"  
}

autopullrequest

