#!/bin/bash
#
# CDI - Change Dir Interactively
# Don't waste more time in the terminal browsing folders with CD

# helper function to colorize terminal text
color_print() {
    # function call syntax
    # print_color "text to print" <foreground-color> <formatting> <background-color>

    # Foreground colors
    get_foreground() {
        case $1 in 
            'black') printf "\033[30m" ;;
            'red') printf "\033[31m" ;;
            'green') printf "\033[32m" ;;
            'orange') printf "\033[33m" ;;
            'blue') printf "\033[34m" ;;
            'magenta') printf "\033[35m" ;;
            'cyan') printf "\033[36m" ;;
            'gray') printf "\033[37m" ;;
            *) printf "\033[39m" ;; # default or anything else
        esac
    }

    # Formatting
    get_formatting() {
        case $1 in
            'bold') printf '\033[1m' ;;
            'underline') printf '\033[4m' ;;
            'bold-underline') printf '\033[4m\033[1m' ;;
            *) printf '\033[22m\033[24m' ;; # code 22 to disable bold, 24 for underline
        esac
    }

    # Background colors
    get_background() {
        case $1 in
            'black') printf '\033[40m' ;;
            'red') printf '\033[41m' ;;
            'green') printf '\033[42m' ;;
            'orange') printf '\033[43m' ;;
            'blue') printf '\033[44m' ;;
            'magenta') printf '\033[45m' ;;
            'cyan') printf '\033[46m' ;;
            'light-gray') printf '\033[47m' ;;
            'gray') printf '\033[100m' ;;
            'light-red') printf '\033[101m' ;;
            'light-green') printf '\033[102m' ;;
            'yellow') printf '\033[103m' ;;
            'light-blue') printf '\033[104m' ;;
            'light-purple') printf '\033[105m' ;;
            'teal') printf '\033[106m' ;;
            'white') printf '\033[107m' ;;
            *) printf '\033[49m' ;; # default or anything else
        esac
    }

    FORE=`get_foreground $2`
    BACK=`get_background $4`
    FMT=`get_formatting $3`

    printf "$FORE$BACK$FMT$1\n"
    # reset all formatting, can be combined to a single line for reduced code
    printf '\033[39m' # default foreground
    printf '\033[49m' # default background
    printf '\033[22m\033[24m' # default formatting
}

print_folders() {
    # $1 = current_dir
    # $2 = current_selection

    # List files and filter only those ending with "/"
    array=($(ls -p $1 | grep /))
    folders_list_size=$((${#array[@]}-1))

    if [ "${#array[@]}" -ne 0 ]; then
        for i in "${!array[@]}"; do
            if test "$i" -eq $2; then
                # echo -e "\033[1m→ ${array[i]}\033[0m"
                printf "→ " # print selection arrow on same line
                color_print "${array[i]}" green bold-underline
            else
                # echo "  ${array[i]}"
                color_print "  ${array[i]}" 
            fi
        done
    else
        #echo -e 'No folders here, press \033[1m←\033[0m to back'
        color_print 'No folders here, press ← to back' red
    fi
}

print_status() {
    #echo -e "[ \033[1m$1\033[0m ]\n"
    color_print " [ $1 ]\n" orange bold
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
