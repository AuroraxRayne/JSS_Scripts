#!/bin/sh

echo "Unjoining Old Domain"

dsconfigad -remove -u UNAME -p PASSWORD

sleep 3

un=`/usr/bin/osascript <<EOT
tell application "System Events"
    activate
    set un to text returned of (display dialog "Please type Username" default answer "" with icon 2)
end tell
EOT`

domain1=$(dsconfigad -show | grep 'Active Directory Domain')

if [[ ${domain1} =~ 'OLD_DOMAIN' ]]; then
	echo "Still on OLD_DOMAIN"
	dsconfigad -force -remove -u UNAME -p PASSWORD
else
	echo "Looks like unjoin worked.  Lets join the NEW_DOMAIN"
	/usr/local/jamf/bin/jamf policy -trigger NEW_DOMAIN_POLICY
	sleep 5


    # Remove Local account
    echo "Deleteing local User but not Home Dir"
    if [[ $un != "admin" ]]; then
    /usr/bin/dscl . -delete /Users/$un
    fi
fi

sleep 3
echo "first check after bind"
domain2=$(dsconfigad -show | grep 'Active Directory Domain')

echo "results of first check $domain2"

sleep 3

if [[ ${domain2} =~ 'NEW_DOMAIN' ]]; then
	echo "Sweet you are on NEW_DOMAIN You are all set"
	chown -R $un /Users/$un
	sleep 2
prompt1=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "Migration Complete" -description "The Migration has completed successfully.  Once you click OK your computer will reboot in 1 minute" -button1 "OK"`
    echo "Results of $prompt1";
	    if [ "$prompt1" == "0" ]; then
			exit 0
		fi
		
else
	prompt3=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "Migration Incomplete" -description "The Migration has not completed.  There was an issue with your migration, please reach out to Dennis Browning, Jon Allyn or Ben Stuart." -button1 "OK"`

	echo "Results of $prompt3";
	    if [ "$prompt3" == "0" ]; then
			exit 1
		fi

fi
