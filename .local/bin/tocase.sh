#!/bin/sh

progname="$(basename "$0")"
normal="$(tput sgr0)"
bold="$(tput bold)"

usage() {
    printf "%-15b\n" "${bold}USAGE:${normal}"
    printf "%-15s\n\n" "$progname <file> <case_type> [option]"
    printf "%-15b\n" "${bold}DESCRIPTION:${normal}"
    printf "%-15s\n\n" "Script to rename a file using a given case type"
    printf "%-15b\n" "${bold}CASE TYPES:${normal}"
    printf "%s %-15s %s\n" " " "--camel" "Rename file using the camelCase convention"
    printf "%s %-15s %s\n" " " "--snake" "Rename file using the snake_case convention"
    printf "%s %-15s %s\n" " " "--pascal" "Rename file using the PascalCase convention"
    printf "%-15b\n" "${bold}OPTIONS:${normal}"
    printf "%s %-15s %s\n" " " "--help" "Show this help text"
}

e_missing_arg() {
    echo "Missing argument: <file>. Try $progname --help for more information."
    exit 1
}

e_not_a_file() {
    echo "$1 is not a file. Try $progname --help for more information"
    exit 1
}

rename_file() {
    filename="$1"
    pattern="$2" 
    new_name=$(echo "$filename" | sed -E "$pattern")

    mv "$filename" "$new_name"
}

to_camelcase() {
  rename_file "$1" 's/[^[:alnum:]]/ /g; s/^ +//; s/ +$//; s/([[:alnum:]])/\L\1/g; s/( \w)/\U\1/g; s/ (\w+$)/\.\L\1/; s/ //g'
}

to_snakecase() {
  rename_file "$1" 's/[^[:alnum:]]/ /g; s/^ +//; s/ +$//; s/([[:alnum:]])/\L\1/g; s/ (\w+$)/\.\1/; s/ +/_/g'
}

to_pascalcase() {
  rename_file "$1" 's/[^[:alnum:]]/ /g; s/^ +//; s/ +$//; s/([[:alnum:]])/\L\1/g; s/(\b\w)/\U\1/g; s/ (\w+$)/\.\1/; s/ //g'
}

main() {
    for p in "$@"; do
        if [ "$p" = "--help" ]; then 
            usage 
            exit 0
        fi
    done

    if [ -z "$1" ]; then
        e_missing_arg
    fi

    if [ ! -f "$1" ]; then
        e_not_a_file "$1"
    fi

    case "$2" in
        --camel)
            to_camelcase "$1"
            ;;

        --snake)
            to_snakecase "$1"
            ;;

        --pascal)
            to_pascalcase "$1"
            ;;

        *)
            echo "You must specify a valid case type. Try $progname --help for more information."
            exit 1
            ;;
    esac
}

main "$@"
