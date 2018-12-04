#!/bin/sh

LoggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

oldDomain=""
newDomain=""
newDomainTrigger=""

runMigration ()
{

echo "Unjoining Old Domain"

dsconfigad -remove -force -u user -p pass

sleep 3

#prompt for User's username for changing permissions later in the script
un=`/usr/bin/osascript <<EOT
tell application "System Events"
    activate
    with timeout of 600 seconds
        set un to text returned of (display dialog "Please type in Active Directory Username" default answer "" with icon 2)
    end timeout
end tell
EOT`

#Chcek to see if disjoin worked.  If not, a forced disjoin will be done and then joined to new Domain.  If the disjoin worked at first it will just join to the new domain.
domain1=$(dsconfigad -show | grep 'Active Directory Domain')

if [[ ${domain1} =~ '$oldDomain' ]]; then
	echo "Still on $oldDomain"
	dsconfigad -force -remove -u user -p pass
	sleep 10
	/usr/local/jamf/bin/jamf policy -trigger $newDomainTrigger
else
	echo "Looks like unjoin worked.  Lets join the $newDomain Domain"
	/usr/local/jamf/bin/jamf policy -trigger $newDomainTrigger
	sleep 5
fi

sleep 3
#Make sure we are on the new domain
echo "first check after bind"
domain2=$(dsconfigad -show | grep 'Active Directory Domain')

#Line for recording in Policy Log
echo "results of first check $domain2"

sleep 3
# If on the new Domain, reset permissions on home directory to new UUID for first Login
if [[ ${domain2} =~ '$newDomain' ]]; then
	echo "Sweet you are on $newDomain You are all set"
	echo "Lets clean up your old AD account"
	#removing profile but not home dir
	dscl . -delete /Users/$un
	echo "Lets fix permissions on $un home directory"
	#change ownership of home dir to new UUID
	chown -R $un /Users/$un
	sleep 2
prompt1=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "Migration Complete" -description "The Migration has completed successfully.  Please click OK and reboot your computer." -button1 "OK"`
    echo "Results of $prompt1";
	    if [ "$prompt1" == "0" ]; then
			exit 0
		fi
		
else
	prompt3=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "Migration Incomplete" -description "The Migration has not completed.  There was an issue with your migration, please reach out to Support for help." -button1 "OK"`

	echo "Results of $prompt3";
	    if [ "$prompt3" == "0" ]; then
			exit 1
		fi

fi
}


if [[ ${LoggedInUser} =~ "admin" ]] || [[ ${LoggedInUser} == "fixme" ]]; then
    echo "No normal user is logged in!  lets run the migration!"
    runMigration
else
    echo "$LoggedInUser is logged in and this process will exit"
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "FAIL" -description "You must be logged in as fixme or admin account.  Please Logout of $LoggedInUser and login as fixme or admin and run this process again." -button1 "OK"
    exit 1
fi