#!/bin/sh

if [ -e /Library/LaunchAgents/com.ADPassMon.plist ]; then
   sleep 2
   launchctl unload /Library/LaunchAgents/com.ADPassMon.plist
   sleep 2
    rm -f /Library/LaunchAgents/com.ADPassMon.plist
    echo "removed LaunchAgent"
else
    echo "No LaunchAgent"    
fi