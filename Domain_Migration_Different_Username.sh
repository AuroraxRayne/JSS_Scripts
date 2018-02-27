#!/bin/sh

LoggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

oldDomain="varietycorp.com"
newDomain="corp.pmc.com"
newDomainTrigger="ADBind"

Run_Migration ()
{
#prompt for User's username for changing permissions later in the script
# New Domain Username
newUn=$(/usr/bin/osascript <<EOT
tell application "System Events"
    activate
    with timeout of 600 seconds
        set newUn to text returned of (display dialog "Please type in users $newDomain AD Username" default answer "" with icon 2)
    end timeout
end tell
EOT)

# Old Domain username
oldDomainUn=$(/usr/bin/osascript <<EOT
tell application "System Events"
    activate
    with timeout of 600 seconds
        set oldDomainUn to text returned of (display dialog "Please type in users $oldDomain username" default answer "" with icon 2)
    end timeout
end tell
EOT)

#Force removed from previous Domain
dsconfigad -r -f -u user -p pass
dsconfigldap -r -f -u user -p pass

sleep 3

#Lets update the home dir folder name to the correct name
mv /Users/$oldDomainUn/ /Users/$newUn

#Lets join the $newDomain Domain
/usr/local/jamf/bin/jamf policy -trigger $newDomainTrigger
sleep 5

#Make sure we are on the new domain
echo "first check after bind"
domain2=$(dsconfigad -show | awk '/Active Directory Domain/{print $NF}')

#Line for recording in Policy Log
echo "results of first check $domain2"

sleep 3
# If on the new Domain, reset permissions on home directory to new UUID for first Login
if [[ ${domain2} == $newDomain ]]; then
	echo "Sweet you are on $newDomain You are all set"
	echo "Lets clean up your old account"
	#removing profile but not home dir
	dscl . -delete /Users/$oldDomainUn
	echo "Lets fix permissions on $newUn home directory"
	#change ownership of home dir to new UUID
	chown -R $newUn /Users/$newUn
	sleep 2
	
	/usr/local/bin/jamf recon
	sleep 2
	
prompt1=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "Migration Complete" -description "The Migration has completed successfully.  Please click OK and logout of this account." -button1 "OK"`
    echo "Results of $prompt1";
	    if [ "$prompt1" == "0" ]; then
			exit 0
		fi
		
else
	prompt3=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "Migration Incomplete" -description "The Migration has not completed.  There was an issue with your migration, please reach out to Client Engineering on-call." -button1 "OK"`

	echo "Results of $prompt3";
	    if [ "$prompt3" == "0" ]; then
			exit 1
		fi

fi
}

if [[ ${LoggedInUser} =~ "admin" ]] || [[ ${LoggedInUser} == "pmcadmin" ]]; then
	echo "Not regular user logged in, lets run migraiton"
	Run_Migration
else
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "FAIL" -description "You must be logged in as pmcadmin or admin account.  Please Logout of $LoggedInUser and login as pmcadmin or admin and run this process again." -button1 "OK"
fi