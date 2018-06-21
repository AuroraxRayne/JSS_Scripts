#!/bin/sh


#Variables
loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

adminPasswordPrompt="Please type in the password for $loggedInUser :"

newUsernamePrompt="Please type in the username for the Team Member :"

newUserFullNamePrompt="Please type in the Full Name for the Team Member :"

newUsernamePasswordPrompt="Please type in the password for the Team Member :"

verifyUsernamePasswordPrompt="Please verify the password for the Team Member :"


#Prompt for Current users password
adminPassword=$(/usr/bin/sudo -u "$loggedInUser" /usr/bin/osascript -e "text returned of (display dialog \"$adminPasswordPrompt\" default answer \"\" buttons {\"Ok\"} default button 1 with title\"Password\" with hidden answer)") >/dev/null 2>&1

#Prompt for New User's username
newUsername=$(/usr/bin/sudo -u "$loggedInUser" /usr/bin/osascript -e "text returned of (display dialog \"$newUsernamePrompt\" default answer \"\" buttons {\"Ok\"} default button 1 with title\"Username\")") >/dev/null 2>&1

#Prompt for New User's full Name
newUserFullName=$(/usr/bin/sudo -u "$loggedInUser" /usr/bin/osascript -e "text returned of (display dialog \"$newUserFullNamePrompt\" default answer \"\" buttons {\"Ok\"} default button 1 with title\"Full Name\")") >/dev/null 2>&1

#Prompt for New User's password
newUserPassword=$(/usr/bin/sudo -u "$loggedInUser" /usr/bin/osascript -e "text returned of (display dialog \"$newUsernamePasswordPrompt\" default answer \"\" buttons {\"Ok\"} default button 1 with title\"Password\" with hidden answer)") >/dev/null 2>&1

#Prompt for Verification Password
verifyUserPassword=$(/usr/bin/sudo -u "$loggedInUser" /usr/bin/osascript -e "text returned of (display dialog \"$verifyUsernamePasswordPrompt\" default answer \"\" buttons {\"Ok\"} default button 1 with title\"Password\" with hidden answer)") >/dev/null 2>&1

#Compare Passwords to validation
if [[ $newUserPassword == $verifyUserPassword ]]; then
	echo "Passwords match.  Let me create an account for you!"
	/usr/sbin/sysadminctl -adminUser $loggedInUser -adminPassword $adminPassword -addUser $newUsername -fullName "$newUserFullName" -password $newUserPassword -admin
	echo "New User Created"
	/usr/bin/sudo -u "$loggedInUser" /usr/bin/osascript -e "display dialog \"New User Created! 
	Username: $newUsername
	Full Name: $newUserFullName
	Password: $newUserPassword\" buttons {\"Ok\"} default button 1 with title\"New User Created\""
	exit 0
else
	echo "Passwords do not match.  Let us recapture."
	/usr/bin/sudo -u "$loggedInUser" /usr/bin/osascript -e "display dialog \"Passwords do not match!  Please try again\" buttons {\"Ok\"} default button 1 with title\"Password\""
	#Prompt for New User's password
	newUserPassword2=$(/usr/bin/sudo -u "$loggedInUser" /usr/bin/osascript -e "text returned of (display dialog \"$newUsernamePasswordPrompt\" default answer \"\" buttons {\"Ok\"} default button 1 with title\"Password\" with hidden answer)") >/dev/null 2>&1
	#Prompt for Verification Password
	verifyUserPassword2=$(/usr/bin/sudo -u "$loggedInUser" /usr/bin/osascript -e "text returned of (display dialog \"$verifyUsernamePasswordPrompt\" default answer \"\" buttons {\"Ok\"} default button 1 with title\"Password\" with hidden answer)") >/dev/null 2>&1
fi

if [ $newUserPassword2 == $verifyUserPassword2 ]; then
	echo "Passwords match.  Let me create an account for you!"
	/usr/sbin/sysadminctl -adminUser $loggedInUser -adminPassword $adminPassword -addUser $newUsername -fullName "$newUserFullName" -password $newUserPassword -admin
	echo "New User Created"
	/usr/bin/sudo -u "$loggedInUser" /usr/bin/osascript -e "display dialog \"New User Created! 
	Username: $newUsername
	Full Name: $newUserFullName
	Password: $newUserPassword\" buttons {\"Ok\"} default button 1 with title\"New User Created\""
	exit 0
else
	echo "Passwords still don't match.  Exit out with Error."
	/usr/bin/sudo -u "$loggedInUser" /usr/bin/osascript -e "display dialog \"Passwords do not match!  Quiting out of this process.\" buttons {\"Ok\"} default button 1 with title\"Error\""
	exit 1
fi

