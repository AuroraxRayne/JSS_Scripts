#!/bin/sh


if [ -e /Library/Application\ Support/JAMF/Waiting\ Room/Microsoft_Office_2016_Volume_Installer2.pkg ]; then
echo "Office Cached"

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "New Application Available" -description "Office 2016 for Mac will be available for you to install from Self Service shortly.  If you have any issues please reach out to IT Support.  

YOU WILL NEED TO SETUP OUTLOOK ONCE THE INSTALL IS COMPLETE.  PLEASE VISIT https://dealertrackhub.jiveon.com/docs/DOC-7122 FOR INSTRUCTIONS. " -button1 "OK" -timeout 150
    exit 0
else
echo "Office Didn't Cache"
fi