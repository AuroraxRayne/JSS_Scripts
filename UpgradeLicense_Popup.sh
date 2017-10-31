#!/bin/sh
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
jamfHelperIcon="/Applications/Microsoft Outlook.app/Contents/Resources/ol_Outlook_Email_Hover@2x.png"
LoggedInUser=`ls -l /dev/console | cut -d " " -f4`


fRunUpgrade ()
{    
	echo "Lets run the License upgrade tool"
	/usr/local/jamf/bin/jamf policy -trigger 2016VolRemoval
	exit 0
}

if [ "$LoggedInUser" == "" ]; then
    fRunUpgrade
else
    HELPER=$("$jamfHelper" -windowType utility -icon "$jamfHelperIcon" -heading "Upgrade to O365 Subscription" -description "It has been determined that your Office 2016 installation is still using an old license model.  To start the upgrade process, close out of all Microsoft Applications and then click the \"Upgrade\" button below to start the process of upgrading to your subscription license.
	
Once complete, Outlook will open and you will be required to login to activate your Office365 Subscription.

If now is not a good time, you can open \"Self Service\" and run the \"2016 Vol Removal\" tool.

This process takes about 1 minute to complete.

**Please note that after January 8th 2018, this update will be mandated.**

" -button1 "Upgrade" -button2 "Cancel" -defaultButton "2" -cancelButton "2" -timeout 900 -countdown -alignCountdown center -alignDescription justified)


       echo "jamf helper result was $HELPER";
       if [ "$HELPER" == "0" ]; then
           fRunUpgrade
       else
           echo "$LoggedInUser clicked Cancel"
           exit 0
       fi

fi