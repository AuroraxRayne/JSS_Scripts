#!/bin/sh

LoggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

if [[ ${LoggedInUser} =~ "admin" ]] || [[ ${LoggedInUser} == "fixme" ]]; then
    echo "$LoggedInUser is logged in and this process will exit"
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "FAIL" -description "You must be logged in as the team member!.  Please Logout of $LoggedInUser and login to the Mac as the team member and run this process again." -button1 "OK"
    exit 1
else
    echo "$LoggedInUser is logged in.  Lets setup their email!"
    /usr/bin/osascript /Library/Application\ Support/CAI/setupOutlookCox.scpt
fi