#!/bin/sh

progname="$(basename "$0")"
normal="$(tput sgr0)"
bold="$(tput bold)"

usage() {
    printf '%3b %s\n\n' "${bold}USAGE${normal}:" "$progname --output <output> --brightness <value>"
    printf '%3b %s\n\n' "${bold}DESCRIPTION${normal}:" "Adjusts screen brightness with xrandr, preventing it from being set to 0 to ensure visibility."
    printf '%3s %-15s %s\n' " " "--output" "The display output to adjust"
    printf '%3s %-15s %s\n' " " "--brightness" "The desired screen brightness, ranging from 0.1 to 1.0"
}

try_help() {
    echo "Try $progname --help for more information"
}

err_invalid_argument() {
    echo "Invalid argument -- '$1'" 1>&2
    try_help
    exit 1
}

err_out_of_range() {
    echo "Brightness value must range from 0.1 to 1.0." 1>&2
    try_help
    exit 1
}

check_range() {
    if [ "$(echo "$brightness < 0.1" | bc -l)" -eq 1 ] || [ "$(echo "$brightness > 1.0" | bc -l)" -eq 1 ]; then
        err_out_of_range
    fi
}

main() {
    opts=
    output=
    brightness=

    while [ -n "$1" ]; do 
        case "$1" in
            --output     ) shift
                           output="$1"
                           ;;

            --brightness ) shift 
                           brightness="$1"
                           ;;

            --help       ) usage
                           exit 0
                           ;;

            *            ) err_invalid_argument "$1"
                           ;;
        esac
        shift
    done

    for last in "$@"; do 
        if [ "$last" = "--help" ]; then 
            usage 
            exit 0
        fi
    done

    if [ -n "$output" ]; then opts="--output $output"; fi

    if [ -n "$brightness" ]; then
        check_range
        opts="$opts --brightness $brightness"
    fi

    xrandr $opts
}

main "$@"
