#!/bin/sh    

#Lets check to see if we are on Man.co
domain1=$(dsconfigad -show | grep 'Active Directory Domain')

if [[ ${domain1} =~ 'man.co' ]]; then
   echo "We are on Man.co"
   /usr/local/jamf/bin/jamf displayMessage -message "Alright I've confirmed we are on Man.co.  Lets move on to the next step."
   sleep 10
else
   echo "Looks like we are not on the Man.co domain"
   /usr/local/jamf/bin/jamf displayMessage -message "Looks like the domain join failed.  I will try joining again."
   sleep 5
	/usr/local/jamf/bin/jamf policy -trigger joinmanco
	
	sleep 10
	
	domain2=$(dsconfigad -show | grep 'Active Directory Domain')

	if [[ ${domain2} =~ 'man.co' ]]; then
	   echo "We are on Man.co"
	   /usr/local/jamf/bin/jamf displayMessage -message "Alright I've confirmed we are on Man.co.  Lets move on to the next step."
	   sleep 10
	else
		echo "Looks like we are not on the Man.co domain"
		/usr/local/jamf/bin/jamf displayMessage -message "Looks like the domain join failed.  Reach out to Dennis for assistance."
		exit 1
	fi
fi

#Lets confirm their username exist
/usr/local/jamf/bin/jamf displayMessage -message "Lets look at the user account now..."

un=`/usr/bin/osascript <<EOT
tell application "System Events"
    activate
    set un to text returned of (display dialog "Please type in DT Username" default answer "" with icon 2)
end tell
EOT`

if [[ -d "/Users/$un" ]]; then
	echo "Alright the users home dir exists"
	/usr/local/jamf/bin/jamf displayMessage -message "$un has a home dir.  Let me make sure permissions are set"
	sleep 2
	dscl . - delete /Users/$un
	sleep 2
	chown -R $un /Users/$un
	sleep 2
	/usr/local/jamf/bin/jamf displayMessage -message "Thats done.  Now lets have you log out and see if $un can login."
	exit 0
else
	echo "User account doesn't exist."
	/usr/local/jamf/bin/jamf displayMessage -message "No home dir with that name exists.  Reach out to Dennis with questions"
	exit 1
fi