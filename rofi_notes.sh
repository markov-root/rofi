#!/bin/bash

# Easily changeable variables
SEARCH_DIR="$HOME/documents/obsidian"
ROFI_THEME="$HOME/.config/rofi/text_theme_fullscreen.rasi"
NOTE_EXTENSION=".md"

# Function to create a new note
function create_note() {
    local title
    title=$(rofi -dmenu -p "Enter note title:" -theme "$ROFI_THEME")
    if [ -n "$title" ]; then
        local filename="${SEARCH_DIR}/${title// /_}${NOTE_EXTENSION}"
        if [[ ! -f "$filename" ]]; then
            echo "# $title" > "$filename"
            echo "Created: $(date +"%Y-%m-%d %H:%M:%S")" >> "$filename"
            echo "" >> "$filename"
            echo "Note created: $filename"
        else
            echo "Note already exists: $filename"
        fi
    fi
}

# Function to delete a note
function delete_note() {
    local note
    note=$(find "$SEARCH_DIR" -type f -name "*${NOTE_EXTENSION}" | 
           sed "s|${SEARCH_DIR}/||" | 
           rofi -dmenu -i -p "Select note to delete:" -theme "$ROFI_THEME")
    if [ -n "$note" ]; then
        local full_path="${SEARCH_DIR}/${note}"
        if [[ -f "$full_path" ]]; then
            rm "$full_path"
            echo "Deleted: $full_path"
        else
            echo "File not found: $full_path"
        fi
    fi
}

# Function to generate and copy a link to a file (including media files)
function copy_link() {
    local file
    file=$(find "$SEARCH_DIR" -type f | 
           sed "s|${SEARCH_DIR}/||" | 
           rofi -dmenu -i -p "Select file to link:" -theme "$ROFI_THEME")
    if [ -n "$file" ]; then
        local link
        # Check if it's a note or a media file
        if [[ "$file" == *"$NOTE_EXTENSION" ]]; then
            link="[[$(basename "$file" "$NOTE_EXTENSION")]]"
        else
            link="![[${file}]]"
        fi
        echo -n "$link" | xclip -selection clipboard
        echo "Copied to clipboard: $link"
    fi
}

# Main menu function
function rofi_main() {
    local options="Create Note\nDelete Note\nCopy Link\nQuit"
    local selected
    
    selected=$(echo -e "$options" | rofi -theme "$ROFI_THEME" -dmenu -i -p 'Note Functions')

    case "$selected" in
        "Create Note")
            create_note
            ;;
        "Delete Note")
            delete_note
            ;;
        "Copy Link")
            copy_link
            ;;
        "Quit")
            exit 0
            ;;
    esac
}

# Main execution
rofi_main
exit 0
