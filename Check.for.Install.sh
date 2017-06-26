#!/bin/sh


if [[ "$4" != "" ]]; then
check="$4"
fi
echo "Application to check for: $check"

if [ -d "/Applications/$check" ]; then
    echo "Installation of $check was successful"
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "Installation Complete" -description "The installation of $check has completed. You can click OK and start using $check" -button1 "OK"
    exit 0
else
    echo "Installaltion of $check failed"
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "Installation Failed" -description "The installation for $check has failed. Please reach out to Desktop Support to get this application installed." -button1 "OK"
    exit 1
fi    
