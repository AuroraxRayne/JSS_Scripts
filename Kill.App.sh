#!/bin/sh

if [[ "$4" != "" ]]; then
app="$4"
fi

if ( pgrep "$app" > /dev/null ); then
    echo "Killing $app"
    killall "$app"
else
    echo "$app is not running"
fi