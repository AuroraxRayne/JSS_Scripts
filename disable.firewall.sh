#!/bin/sh

defaults write /Library/Preferences/com.apple.alf globalstate -int 0

launchctl unload /System/Library/LaunchAgents/com.apple.alf.useragent.plist
launchctl unload /System/Library/LaunchDaemons/com.apple.alf.agent.plist

defaults write /Library/Preferences/com.apple.alf globalstate -int 0

launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist
launchctl load /System/Library/LaunchAgents/com.apple.alf.useragent.plist