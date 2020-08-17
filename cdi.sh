#!/bin/bash
#
# CDI - Change Dir Interactively
# Don't waste more time in the terminal browsing folders with CD

print_folders() {
    # $1 = current_dir
    # $2 = current_selection

    # List files and filter only those ending with "/"
    array=($(ls -p $1 | grep /))
    folders_list_size=$((${#array[@]}-1))

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

init() {
    # Initial values
    current_dir=$(pwd)
    current_selection=0

    clear

    escape_char=$(printf "\u1b")
    while 
        print_status $current_dir $current_selection
        print_folders $current_dir $current_selection

        read -rsn1 mode
        clear
        do

        if [[ $mode == "$escape_char" ]]; then
            read -rsn2 mode
        fi

        # echo $mode
        case $mode in
            '[A') # UP
                                
                if [ "$current_selection" -eq 0 ]; then
                    current_selection=$folders_list_size
                else
                  current_selection=$((current_selection-1))
                fi

                ;;
            '[B') # DOWN

                if [ "$current_selection" -eq "$folders_list_size" ]; then
                  current_selection=0
                else
                  current_selection=$((current_selection+1))
                fi

                ;; 
            
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

            *)
                # Change to directory
                #   Since script was invoked through the source command (. ./Script) we are still in the same Shell instance, 
                #   so it is possible to execute the CD command and thus change the directory.
                cd "$current_dir" || exit
                return
        esac
    done
}

init
