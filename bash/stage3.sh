#!/bin/bash

if [ "$1" == "--help" ]; then
    >&2 echo "Usage: ./stage3.sh [-D delta_file] [-0 old_alpha] [-E excess_file] [data_file]..."
    >&2 echo " -D Output delta information to the given file"
    >&2 echo " -0 Get old alpha information from the specified file"
    >&2 echo " -E Output extra, unused parse data to the given file"
    >&2 echo " ( NOTE: If any flag is supplied, all flags should be supplied )"
    exit
fi

dfile=''
afile=''
efile=''

while getopts 'D:0:E:' opt; do
    case "$opt" in
        D)
            dfile="$OPTARG"
            ;;
        0)
            afile="$OPTARG"
            ;;
        E)
            efile="$OPTARG"
            ;;
    esac
done

shift $((OPTIND - 1))

if [ -n "$dfile" ] && [ -n "$afile" ] && [ -n "$efile" ]; then
    ./ruby/deltarunner.rb "$afile" "$dfile" "$efile" $*
else
    ./ruby/runner.rb $*
fi
