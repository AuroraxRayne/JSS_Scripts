#!/bin/sh


if [[ "$4" != "" ]]; then
check="$4"
fi
echo "Application to check for: $check"

if [ -d "/Applications/$check" ]; then
    echo "Installation of $check was successful"
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "Installation Complete" -description "The installation has completed. You can click OK and start using the new Application" -button1 "OK"
    exit 0
else
    echo "Installaltion of $check failed"
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "Installation Failed" -description "The installation has failed. Please reach out to IT Support Services to get this application installed." -button1 "OK"
    exit 1
fi    
