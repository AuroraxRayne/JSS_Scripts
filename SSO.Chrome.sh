#!/bin/sh

check=`pgrep "Google Chrome"`

if [ "$check" != "" ]; then
	echo "Chrome is Running"
	
	prompt=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "Okta SSO Update" -description "Chrome must quit and reboot the computer to apply an update.  Click OK to quit Chrome now and reboot." -button1 "OK"`
	if [ "$prompt" == "0" ]; then
		killall "Google Chrome"
		
		sleep 2
		
		un=`ls -l /dev/console | cut -d " " -f4`

		echo "$un"
		echo "adding DOMAIN"
		defaults write /Users/$un/Library/Preferences/com.google.Chrome AuthServerWhitelist "*.DOMAIN"

		sleep 2
		echo "changing ownership"
		sudo chown $un /Users/$un/Library/Preferences/com.google.Chrome.plist
	fi
/usr/local/jamf/bin/jamf policy -trigger rebootdelay

else
	echo "Chrome is not running"
	un=`who | grep console | awk '{print $1}'`

	echo "$un"
	echo "adding DOMAIN"
	defaults write /Users/$un/Library/Preferences/com.google.Chrome AuthServerWhitelist "*.DOMAIN"

	sleep 2
	echo "changing ownership"
	sudo chown $un /Users/$un/Library/Preferences/com.google.Chrome.plist
	
	sleep 2
	
	/usr/local/jamf/bin/jamf policy -trigger rebootdelay
fi
	
