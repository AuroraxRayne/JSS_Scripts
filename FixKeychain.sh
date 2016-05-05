#!/bin/sh

#get logged in user
loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

#get Mac UUID
macUUID=`system_profiler SPHardwareDataType | awk '/Hardware UUID:/{ print $NF}'`

echo "MacUUID is: $macUUID"

#Lets delete the local Items Keychain
rm -rf /Users/$loggedInUser/Library/Keychains/$macUUID

sleep 2

#Lets delete the Login Keychain
security delete-keychain /Users/$loggedInUser/Library/Keychains/login.keychain

sleep 2

/usr/bin/osascript <<EOT
display dialog "Your Mac needs to restart to finish fixing your Keychain. Please dismiss any Local Items keychain prompts, close any open Applications and click Restart." with icon 0 buttons {"Restart"}
EOT
