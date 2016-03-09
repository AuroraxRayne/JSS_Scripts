#!/bin/sh


if [[ "$4" != "" ]]; then
app="$4"
fi
echo "$app available in SS"

/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "New Application Available" -description "$app will be available for you to install from Self Service shortly.  If you have any issues please reach out to IT Support." -button1 "OK" -timeout 150
    exit 0