#!/bin/sh

userName=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'` 


## Get the logged in user's password via a prompt
echo "Prompting ${userName} for their login password."
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "FileVault Recovery Key Remediation" -description "Your Cox Automotive issued computer is currently encrypted.  A recovery key must be escrowed to the company management system.  You will be prompted for your login password." -button1 "OK"

##Prompt for password
userPassword="$(/usr/bin/osascript -e 'with timeout of 600 seconds' -e 'Tell application "System Events" to display dialog "Please enter your login password:" default answer "" with title "Login Password" with text buttons {"Ok"} default button 1 with hidden answer' -e 'end timeout' -e 'text returned of result')"

sleep 2

# create the plist file:
	echo '<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
	<key>Username</key>
	<string>macadmin</string>
	<key>Password</key>
	<string>Fri3ndlyGh0st</string>
	<key>AdditionalUsers</key>
	<array>
	    <dict>
	        <key>Username</key>
	        <string>'$userName'</string>
	        <key>Password</key>
	        <string>'$userPassword'</string>
	    </dict>
	</array>
	</dict>
	</plist>' > /tmp/fvenable.plist
	

sleep 2

fdesetup add -inputplist -verbose < /tmp/fvenable.plist

sleep 5

## This "expect" block will populate answers for the fdesetup prompts that normally occur while hiding them from output
	expect -c "
	log_user 0
	spawn fdesetup changerecovery -personal
	expect \"Enter a password for '/', or the recovery key:\"
	send "{${userPassword}}"
	send \r
	log_user 1
	expect eof
	"