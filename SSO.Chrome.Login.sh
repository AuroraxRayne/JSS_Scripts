#!/bin/sh

	un=`who | grep console | awk '{print $1}'`

	echo "$un"
	echo "adding dt.inc"
	defaults write /Users/$un/Library/Preferences/com.google.Chrome AuthServerWhitelist "*.dt.inc"

	sleep 2
	echo "changing ownership"
	sudo chown $un /Users/$un/Library/Preferences/com.google.Chrome.plist
	
