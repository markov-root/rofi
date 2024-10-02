#!/bin/bash

# Easily changeable variables
SEARCH_DIR="$HOME/documents/obsidian"
ROFI_THEME="$HOME/.config/rofi/text_theme_fullscreen.rasi"

# File type associations
TEXTEDIT="alacritty -e nvim"
VIDEO_PLAYER="mpv"
IMAGE_VIEWER="feh"
PDF_VIEWER="zathura"
FOLDER_OPENER="alacritty -e ranger"

function open_file() {
    local file="$1"
    local ext="${file##*.}"
    
    case "$ext" in
        mp4|mkv|avi|mov)
            $VIDEO_PLAYER "$file" &
            ;;
        jpg|jpeg|png|gif)
            $IMAGE_VIEWER "$file" &
            ;;
        pdf)
            $PDF_VIEWER "$file" &
            ;;
        *)
            $TEXTEDIT "$file" &
            ;;
    esac
}

function open_folder() {
    local folder="$1"
    $FOLDER_OPENER "$folder" &
}

function rofi_main()
{
    local rofi_config="
        configuration {
            kb-accept-alt: \"\";
            kb-custom-1: \"Shift+Return\";
        }
    "
    
    local rofi_command="rofi -theme $ROFI_THEME -dmenu -i -p 'Notes FZF' \
        -config <(echo \"$rofi_config\")"

    local selected
    local exit_code

    selected="$( (echo .; find "$SEARCH_DIR" \( ! -path '*/\.*' \) -printf '%P\n') | eval "$rofi_command")"
    exit_code=$?

    if [[ -z "$selected" ]]; then
        exit 0
    fi

    if [[ "$selected" == "." ]]; then
        selected=$(find "$SEARCH_DIR" \( -path '*/\.*' \) -printf '%P\n' | eval "$rofi_command")
        exit_code=$?
    fi

    local full_path="$SEARCH_DIR/$selected"

    case $exit_code in
        0) # Normal Enter
            if [[ -f "$full_path" ]]; then
                open_file "$full_path"
            elif [[ -d "$full_path" ]]; then
                open_folder "$full_path"
            else
                echo "Selected item does not exist: $full_path"
            fi
            ;;
        10) # Shift+Return
            if [[ -f "$full_path" ]]; then
                open_folder "$(dirname "$full_path")"
            elif [[ -d "$full_path" ]]; then
                open_folder "$full_path"
            else
                echo "Selected item does not exist: $full_path"
            fi
            ;;
    esac
}

function print_usage()
{
    printf 'Usage: %s
        Obsidian Fuzzy Finder
Options:
     --help        Show this message and exit
     --dir         Set Obsidian directory (default: %s)

Key Bindings:
     Enter         Open file or folder
     Shift+Return  Open containing folder (for files) or selected folder
' "${0##*/}" "$SEARCH_DIR"
    exit 2
}

while getopts ":h-:" opt; do
    case $opt in
        -)
            case "${OPTARG}" in
                help)
                    print_usage
                    ;;
                dir)
                    SEARCH_DIR="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
                    ;;
                *)
                    echo "Invalid option: --$OPTARG" >&2
                    print_usage
                    ;;
            esac
            ;;
        h)
            print_usage
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            print_usage
            ;;
    esac
done

rofi_main
exit 0
