#!/bin/sh


if [ -e /Library/Application\ Support/JAMF/Waiting\ Room/Install_OS_X_El_Capitan.InstallESD.dmg ]; then
echo "El Capitan Cached"

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "New Application Available" -description "Mac OS X El Capitan will be available for you to install from Self Service shortly.  If you have any issues please reach out to IT Support." -button1 "OK" -timeout 150
    exit 0
else
echo "El Capitan Didn't Cache"
fi