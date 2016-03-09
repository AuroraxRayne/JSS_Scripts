#!/bin/sh

	un=`who | grep console | awk '{print $1}'`

	echo "$un"
	echo "adding DOMAIN"
	defaults write /Users/$un/Library/Preferences/com.google.Chrome AuthServerWhitelist "*.DOMAIN"

	sleep 2
	echo "changing ownership"
	sudo chown $un /Users/$un/Library/Preferences/com.google.Chrome.plist
	
