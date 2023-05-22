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



