#!/bin/bash

check_dependencies() {
    local DEPS=("mods" "gum")
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
            esac
        done
        exit 1
    fi
}

autocommitmessage() {
  msg="$(git diff --cached | mods "write a commit message for this diff")" && \
      printf '\n' && \
      gum write --header=" Look good? Ctrl+D to commit." --value="$msg" && \
      git commit -am "$msg"
}

autocommitmessage
