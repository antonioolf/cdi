#!/bin/bash

# CDI - Change Dir Interactively
# Don't waste more time in the terminal browsing folders with CD

# TODO list
# - Abstract stylization of text in functions
# - Add more comments

print_folders() {
    # $1 = current_dir
    # $2 = current_selection

    # List files and filter only those ending with "/"
    array=($(ls -p $1 | grep /))

    if [ "${#array[@]}" -ne 0 ]; then
        for i in "${!array[@]}"; do
            if test "$i" -eq $2; then
                echo -e "\033[1m→ ${array[i]}\033[0m"
            else
                echo "  ${array[i]}"
            fi
        done
    else
        echo -e 'No folders here, press \033[1m←\033[0m to back'
    fi
}

print_status() {
    echo -e "[ \033[1m$1\033[0m ]\n"
    #echo -e "Selection $2 \n"
}

get_selected_folder() {
    # $1 = current_dir
    # $2 = current_selection

    array=($(ls -p $1 | grep /))
    for i in "${!array[@]}"; do

        if test "$i" -eq $2
        then
            selected_folder=${array[i]::-1}
        fi
    done
}

print_instructions() {
    echo -e '\n* Use arrows to move ← → ↑ ↓\n* Press enter to copy directory path to clipboard and exit, then press ctrl + shift + v in your terminal to paste \n'
}

init() {
    # Initial values
    current_dir=$(pwd)
    current_selection=0

    # Hide cursor
    # tput civis

    clear

    escape_char=$(printf "\u1b")
    while 
        # print_instructions
        print_status $current_dir $current_selection
        print_folders $current_dir $current_selection

        read -rsn1 mode
        clear
        do

        if [[ $mode == $escape_char ]]; then
            read -rsn2 mode
        fi

        # echo $mode
        case $mode in
            '[A') current_selection=$((current_selection-1)) ;; # UP
            '[B') current_selection=$((current_selection+1)) ;; # DOWN
            
            '[D') # LEFT
                # Removes the last path level
                current_dir=${current_dir%/*}
                current_selection=0
            ;; 
            
            '[C') # RIGHT
                get_selected_folder $current_dir $current_selection
                current_dir="$current_dir/$selected_folder"
                current_selection=0
            ;;

            *) >&2 
                # Sends current directory to the clipboard
                echo -n "cd $current_dir" | xclip -sel clip
                # Change to directory
                cd "$current_dir"
                exec bash
                exit ;;
        esac
    done
}

init
