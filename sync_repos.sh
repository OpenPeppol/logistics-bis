#!/bin/bash
# Script to sync specific directories and files from multiple Git repositories
POACCREPO="https://github.com/OpenPEPPOL/poacc-upgrade-3.git"
POACCBRANCH="2026-Q2-QA2"

# Function to clone and copy files
sync_repo() {
  local repo_url=$1
  local branch=$2
  local source_path=$3
  local target_path=$4

  echo "Syncing $repo_url $source_path"
  git clone --depth=1 --branch "$branch" "$repo_url" temp-repo

  if [ -d "temp-repo/$source_path" ]; then
    mkdir -p "$target_path"
    cp -rvf temp-repo/"$source_path"/* "$target_path"
  elif [ -f "temp-repo/$source_path" ]; then
    mkdir -p "$(dirname "$target_path")"
    cp -vf temp-repo/"$source_path" "$target_path"
  else
    echo "Source path not found: $source_path"
    rm -rf temp-repo
    return 1
  fi

  rm -rf temp-repo
}


# Sync files from multiple repositories without './' in target path
# Rules
sync_repo $POACCREPO $POACCBRANCH "rules/sch/parts" "rules/sch/parts"

# Code lists
sync_repo $POACCREPO $POACCBRANCH "structure/codelist" "structure/codelist"