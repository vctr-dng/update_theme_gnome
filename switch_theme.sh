#!/bin/bash

switch_to() {
    local theme
    local res

    theme=$1

    if [[ $theme == "light" ]]; then
        echo "Switching to light theme..."
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
        res=0
    elif [[ $theme == "dark" ]]; then
        echo "Switching to dark theme..."
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        res=0
    else
        echo "Invalid parameter. Please use 'light' or 'dark'."
        res=1
    fi
    return $res
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    # Script is executed
    switch_to "$1"
    res=$?
    if [[ $res -eq "0" ]]; then
        exit 0
    else
        exit 1
    fi
else
    # Script is sourced
    export switch_to
fi
export switch_to