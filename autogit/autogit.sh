#!/bin/bash

# Initialize the previous directory
prev_dir=""

# Function to determine if the current working directory is a git repository
function is_git_repository() {
  git -C . rev-parse 2> /dev/null
}
# Determine the root directory of the current git repository - used to determine if the user 
# has changed into a sub-directory of the repo (meaning that we shouldn't re-run auto_pull)
function get_repo_root() {
  git rev-parse --show-toplevel 2> /dev/null
}

function changed_to_subdir() {
  local repo_root
  repo_root=$(get_repo_root)
  if [[ -z "$repo_root" ]]; then 
    # not a git repository 
    return 1
  fi
  local cwd
  cwd=$(realpath .)
  [[ "$cwd" != "$repo_root" && "$repo_root"/ != "repo_root/"* ]]
}

# Handle the edge case where a local repository was originally cloned when the GitHub remote's default branch was "master" but has since become out of date
# And we need to update the local repository to use the new GitHub default branch, which is probably named "main"
function check_and_switch_to_main() {
  if git show-ref --verify --quiet refs/heads/master && \
     git show-ref --verify --quiet refs/remotes/origin/main && \
     ! git show-ref --verify --quiet refs/remotes/origin/master; then
    echo "The local repository was cloned when the remote repository had a default branch of 'master', but the remote repository's default branch has been switched to 'main'. Switching to 'main' and pulling..."
    git checkout main
    git pull origin main
    return 0  # return true
  fi
  return 1  # return false
}

# Determine the default branch from the perspective of GitHub 
function get_default_branch() {
    local default_branch
    default_branch=$(git remote show origin | grep "HEAD branch" | cut -d ":" -f 2 | xargs)
    echo "$default_branch"
}

# Checks if a branch switch has occurred on the remote
function check_branch_switch() {
    local default_branch
    default_branch=$(get_default_branch)
    git checkout "$default_branch" 2> /dev/null
    git fetch origin "$default_branch" 2> /dev/null
    if git rev-parse --verify origin/"$default_branch" >/dev/null 2>&1; then
        git checkout "$default_branch" && git pull origin "$default_branch"
    fi
}

# Function to check if a git pull is needed
needs_pull() {
    local default_branch
    default_branch=$(get_default_branch)

    git fetch origin "$default_branch" > /dev/null 2>&1
    ! git diff --quiet HEAD origin/"$default_branch" 2> /dev/null
}

auto_pull() {
  if is_git_repository; then

    # If the user navigates to a sub-directory of the original git repo, then we should not
    # run auto_pull again
    if changed_to_subdir; then
      return
    fi

    # Check if the repository has any commits
    if [ -z "$(git rev-parse HEAD 2>/dev/null)" ]; then
      echo "The repository is brand new and doesn't have any commits."
      return
    fi

    # Check if the repository has a remote set up
    if [ -z "$(git config --get remote.origin.url)" ]; then
      echo "The repository doesn't have a remote set up."
      return
    fi

    # Fetch all branches and tags, and prune deleted ones
    echo "Fetching all branches and tags, and pruning deleted ones..."
    git fetch --all --prune

    # Check if the repository was cloned when the default branch was 'master' but now it's 'main'
    if check_and_switch_to_main; then
      return
    fi

    # Determine the default branch
    local default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    if [[ -z "$default_branch" ]]; then
      if git show-ref --verify --quiet refs/remotes/origin/main; then
        default_branch="main"
      elif git show-ref --verify --quiet refs/remotes/origin/master; then
        default_branch="master"
      else
        echo "Could not determine default branch"
        return
      fi
    fi

    # Check if the repository needs to be updated
    if ! needs_pull $default_branch; then
      echo "The repository is already up to date."
      return
    fi

    # Check if there are any changes
    if ! git diff-index --quiet HEAD --; then
      local stashName="auto_pull_$(date +%s)"
      git stash save -u $stashName > /dev/null 2>&1
      if git stash list | grep -q $stashName; then
        echo "Local changes detected and stashed."
      fi
    fi

    git checkout $original_branch > /dev/null 2>&1

    if git stash list | grep -q $stashName; then
      echo "Applying stashed changes..."
      git stash apply
    fi
  fi
}

run_autogit() {
 local current_dir; 
 current_dir=$(pwd)
 if [ "$prev_dir" != "$current_dir" ]; then 
   prev_dir="$current_dir"; 
   auto_pull
 fi
}

run_autogit
