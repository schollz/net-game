#!/bin/bash

celebs=""
people=""
places=""
weapons=""
debug=""
stage1="./bash/stage1.sh"
stage2="./bash/stage2.sh"
stage3="./bash/stage3.sh"
stage4="./bash/stage4.sh"
prefix="net_"
clisp="clisp"

if [ $# -eq 0 ]; then
    echo "Usage: ./master.sh <args>"
    echo "For detailed help with instructions, try \`./master.sh --help\`"
    exit
fi

if [ $1 == "--help" ]; then
    echo "Usage: ./master.sh <args>"
    echo " -c Number of celebrities"
    echo " -p Number of people"
    echo " -P Number of places"
    echo " -w Number of weapons"
    echo " -d Debug mode"
    echo " -1 Do not run Stage 1"
    echo " -2 Do not run Stage 2"
    echo " -3 Do not run Stage 3"
    echo " -4 Do not run Stage 4"
    echo " -F Specify intermediate filename prefix"
    echo " -l Use the given Common Lisp implementation"
    exit
fi

while getopts 'c:p:P:w:d1234fF:l:' opt; do
    case "$opt" in
        c) # Celebrities
            celebs="-c $OPTARG"
            ;;
        p) # People
            people="-p $OPTARG"
            ;;
        P) # Places
            places="-P $OPTARG"
            ;;
        w) # Weapons
            weapons="-w $OPTARG"
            ;;
        d) # Debug Mode
            debug="-d"
            ;;
        1) # Stage 1
            stage1=""
            ;;
        2) # Stage 2
            stage2=""
            ;;
        3) # Stage 3
            stage3=""
            ;;
        4) # Stage 4
            stage4=""
            ;;
        F) # Intermediates with Filename
            prefix="$OPTARG"
            ;;
        l) # CLisp
            clisp="$OPTARG"
            ;;
    esac
done

if [ -n "$stage1" ]; then
    stage1="$stage1 $celebs $people $places $weapons $debug"
fi

if [ -n "$stage4" ]; then
    stage4="$stage4 $clisp"
fi

if [ -n "$stage1" ]; then
    $stage1 >"./temp/${prefix}1.txt"
fi
if [ -n "$stage2" ]; then
    $stage2 <"./temp/${prefix}1.txt" >"./temp/${prefix}2.txt"
fi
if [ -n "$stage3" ]; then
    $stage3 <"./temp/${prefix}2.txt" >"./temp/system.txt"
fi
if [ -n "$stage4" ]; then
    $stage4
fi
