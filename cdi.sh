#!/bin/bash

# CDI - Change Dir Interactively
# Don't waste more time in the terminal browsing folders with CD

# TODO: Change directory

##################### Functions ################################

print_folders() {
    # $1 = current_dir
    # $2 = current_selection

    echo "Debug >> $1 $2 <<"

    array=($(ls -p $1 | grep /))
    for i in "${!array[@]}"; do
        if test "$i" -eq $2
        then
            echo "→ ${array[i]}"
        else
            echo "  ${array[i]}"
        fi
    done
}

get_selected_folder() {
    # $1 = current_dir
    # $2 = current_selection

    array=($(ls -p $1 | grep /))
    for i in "${!array[@]}"; do

        if test "$i" -eq $2
        then
            selected_folder=${array[i]}
        fi
    done
}

print_instructions() {
    echo -e '\n* Use arrows to move ↑ ↓ ← →\n * Press enter to copy directory path to clipboard and exit, then press ctrl + shift + v in your terminal to paste \n'
}
###############################################################

# Initial values
current_dir=$(pwd)
current_selection=0

# Hide cursor
tput civis

# Initial instructions
clear

escape_char=$(printf "\u1b")
while 
    print_instructions
    print_folders $current_dir $current_selection
    read -rsn1 mode
    clear
    do

    if [[ $mode == $escape_char ]]; then
        read -rsn2 mode # read 2 more chars
    fi

    echo $mode

    case $mode in
        'q') echo QUITTING ; exit ;;
        '[A') current_selection=$((current_selection-1)) ;; # UP
        '[B') current_selection=$((current_selection+1)) ;; # DOWN
        
        '[D') # LEFT
            current_dir="$current_dir/.."
            current_selection=0
        ;; 
        
        '[C') # RIGHT
            get_selected_folder $current_dir $current_selection
            current_dir="$current_dir/$selected_folder"
            current_selection=0
        ;;

        *) >&2 
            echo 'saindo...'; 
            return ;;
    esac
done
