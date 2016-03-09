#!/bin/sh


if [ -f /Library/LaunchDaemons/com.company.caspercheck.plist ]; then

    launchctl unload -w /Library/LaunchDaemons/com.company.caspercheck.plist
    echo "unloaded"
fi

sleep 2

launchctl load -w /Library/LaunchDaemons/com.company.caspercheck.plist
echo "loaded"
exit 0