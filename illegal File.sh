#!/bin/sh

badfile=`find / -name "Batman*.mkv"`
#badfile=`mdfind ".mkv"`


echo "The badboy file is: $badfile"

echo ""

if [[ -e "$badfile" ]]; then
    echo "this is your bad guy"
    exit 1
else
    echo "computer is clean"
    exit 0
fi