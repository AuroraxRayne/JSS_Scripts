#!/bin/sh
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
jamfHelperIcon="/System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns"
LoggedInUser=`ls -l /dev/console | cut -d " " -f4`


fRunUpgrade ()
{
    ## In case we need the process ID for the jamfHelper
	OS_MINOR=$(sw_vers -productVersion | awk -F . '{print $2}')
	if [[ "$OS_MINOR" -le 9 ]]; then
	    echo "Lets run the Upgrade to Sierra 10-"
		/usr/local/jamf/bin/jamf policy -trigger #upgradeToSierra9
	else
		echo "Lets run the upgrade to Sierra 10+"
		/usr/local/jamf/bin/jamf policy -trigger #upgradeToSierra10
	fi
    
    exit 0
}

if [ "$LoggedInUser" == "" ]; then
    fRunUpgrade
else
    HELPER=$("$jamfHelper" -windowType utility -icon "$jamfHelperIcon" -heading "OS Upgrade to Support Office 2016 and Skype for Business" -description "Did you know that you can upgrade your Operating System so that you can run the latest version of Office 2016 and Skype for Business for Mac?
	
To start the upgrade process, close all open applications and then click the \"Install\" button below.  If you do not want to do it now, you can go into Self Service and run the \"Upgrade to Sierra\" option found on the main page.

**Please note that after January 8th 2018, this update will be forced.**

" -button1 "Install" -button2 "Cancel" -defaultButton "2" -cancelButton "2" -timeout 900 -countdown -alignCountdown center -alignDescription justified)


       echo "jamf helper result was $HELPER";
       if [ "$HELPER" == "0" ]; then
           fRunUpgrade
       else
           echo "$LoggedInUser clicked Cancel"
           exit 0
       fi

fi