#!/bin/bash
#
## =======================================================================================
## Script:   ConvertToLocalUser.sh
## Author:   Apple Professional Services
## Revision History:
## Date			Version	Personnel	Notes
## ----			-------	---------	-----
## 2016-10-01 	1.0		Apple		Script created
## 2016-12-13 	2.0		Apple		Added FileVault functionality - If the computer is FileVault Encrypted, and the current "Managed, Mobile" user is part of the FileVault users,
##									the "new" local account is added to the FileVault users. FileVault does not have to be decrypted. 
## 2017-03-19 	2.1		Apple		"killall jamf" and  "killall Self \Service" was being used to stop the process and the reboot when a user canceled the self service policy.
##									That caused problems when trying to re-run the policy. Now it is just "killall Self \Service" and calling another policy just for the reboot.
##									Additionally, back-ticks for `code` have been replaced with $(code)
## 2017-04-18 	2.2		Apple		Changed reboot method to call a separate reboot policy. Added RebootTrigger variable.
## 2017-06-06 	2.2.1	Apple		Fixed the full path for /usr/bin/grep in a few lines.
## 
## =======================================================================================
#
####################################################################################################
#
# DESCRIPTION
#	The purpose of this script is to convert the currently logged in user from a "Managed, Mobile" network account 
#	to a local account. This can be useful when using Enterprise Connect.
#
#	If the computer is FileVault encrypted, and the current "Managed, Mobile" user is part of the FileVault users, 
#	the "new" local account is added to the FileVault users. FileVault does not have to be decrypted.
#	An admin user will remain and admin user. A non-admin user will remain a non-admin user.
#
#	This script is intended to run as a Jamf Pro Self Service policy with a separate Reboot Mac Immediately policy called via a custom trigger.
#	Jamf Pro - Convert to Local User Self Service policy settings:
#		General > Display Name (Suggested): Convert to Local User
#		General > Execution Frequency: Ongoing
#		Scripts: ConverttoLocalUser
#		Scripts > Parameter 4 (RebootTrigger): RebootMacImmediately
#		Self Service > Make the policy available in Self Service: checked
#		Self Service > Button Name (Suggested): "Convert User"
#		Self Service > Description (Suggested): "This will convert your current network user account to a local account. 
#		When complete, your computer will REBOOT. 
#		Please SAVE all files and QUIT all apps before proceeding
#		Your system MUST be connected to AC power to continue."
#		Self Service > Ensure that users view the description: checked
#
#	The policy running the script should NOT be set to restart the computer. 
#	To initiate the needed reboot, a separate policy with an immediate reboot should be called a using custom trigger. (The Reboot Mac Immediately policy can be used with other policies too.)
#	Set The "RebootTrigger" variable (Jamf variable $4) to the name of the custom trigger (such as "RebootMacImmediately") for the reboot policy. "jamf policy -event $RebootTrigger"
#	Jamf Pro - Reboot Mac Immediately policy settings:
#		General > Display Name (Suggested): Reboot Mac Immediately
#		General > Trigger > Custom: checked
#		General > Custom Event (Suggested): RebootMacImmediately
#		General > Execution Frequency: Ongoing
#		Restart Options > Startup Disk: Current Startup Disk
#		Restart Options > No User Logged In Action: Restart Immediately 
#		Restart Options > User Logged In Action: Restart Immediately 
#		Restart Options > Perform authenticated restart on computers with FileVault 2 enabled: checked
#		Maintenance > Fix ByHost Files: checked
#		Maintenance > Flush System Caches: checked
#		Maintenance > Flush User Caches: checked
#
# Caveats
#	If there are problems running this script there are two likely issues to check.
#	If the "FVtmpUserPASSWORD" variable in the "FileVaultStuff" function does not meet the 
#	requirements of a local password policy, the script will fail. To mitigate this the "FVtmpUserPASSWORD" is designed to pass very strict password policies.
#	If a local password policy is more strict than the Active Directory password policy, 
#	the new local user account will be created but the user may not be able to log in.
#	Resetting the local user's password to meet the password local pasword policy will fix this after the fact. 
#	To avoid this, ensure the local and the Active Directory password policies are balanced, or the local policy is less strict.
#
# Exit codes
#	rootcheck                     exit 1
#	OSXVersioncheck               exit 2
#	CurrentUserIDcheck            exit 3
#	MobileAccountcheck            exit 4
#	MessageToUser                 exit 5
#	pmsetPowerStatus              exit 6
#	CaptureUserPassword_cancel    exit 7
#	CaptureUserPassword_blank     exit 8
#	FVtmpUser                     exit 9
#
#####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
#####################################################################################################
#
# OS X Version
sw_vers_Full=$(/usr/bin/sw_vers -productVersion)
sw_vers_Major=$(/usr/bin/sw_vers -productVersion | /usr/bin/cut -d. -f 1,2)
sw_vers_MajorNumber=$(/usr/bin/sw_vers -productVersion | /usr/bin/cut -d. -f 2)

computerName=$(/usr/sbin/scutil --get ComputerName)
currentuser=$(/bin/ls -l /dev/console | /usr/bin/awk '{print $3}')
currentuserID=$(/usr/bin/id -u $currentuser)
DisplayDialogMessage=""
#
# HARDCODED VALUE FOR "RebootTrigger" IS SET HERE - Specify the custom trigger for a reboot policy
RebootTrigger="RebootMacImmediately"
# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "RebootTrigger"
# If a value is specified via a casper policy, it will override the hardcoded value in the script.
if [ "$4" != "" ];then
    RebootTrigger=$4
fi
#
/bin/echo "$computerName" is running is OS X version "$sw_vers_Full"
/bin/echo "currentuser: 	$currentuser"
/bin/echo "RebootTrigger: 	$RebootTrigger"
#
#####################################################################################################
#
# Functions to call on
#
#####################################################################################################

#
### Ensure we are running this script as root ###
rootcheck () {
/bin/echo rootcheck
if [ "$(/usr/bin/whoami)" != "root" ] ; then
  /bin/echo "This script must be run as root or sudo."
  exit 1
fi
}
###
#

#
### Ensure we are running at least OS X 10.10.x ###
OSXVersioncheck () {
/bin/echo OSXVersioncheck
if [ "$sw_vers_MajorNumber" -lt 10 ]; then
  /bin/echo "This script requires OS X 10.10 or greater."
  exit 2
fi
}
###
#

#
### Check to see if the current user's UID is greater than 999. ###
CurrentUserIDcheck () {
/bin/echo CurrentUserIDcheck
if [ "$currentuserID" -lt 1000 ]; then
	/bin/echo "This user is already a local account."
	DisplayDialogMessage="This user is already a local account."
	/usr/bin/sudo -u "$currentuser" /usr/bin/osascript -e "display dialog \"$DisplayDialogMessage\" with icon stop buttons {\"End\"} default button 1"
	/usr/bin/killall Self\ Service
	exit 3
fi
}
###
#

#
### Check to see if the current user is a mobile account ###
MobileAccountcheck () {
/bin/echo MobileAccountcheck
accountAuthAuthority="$(/usr/bin/dscl . read /Users/$currentuser AuthenticationAuthority)"
if [[ ! "$accountAuthAuthority" =~ "LocalCachedUser" ]] ; then
	/bin/echo "This is not an Active Directory mobile account."
	DisplayDialogMessage="This is not an Active Directory mobile account."
	/usr/bin/sudo -u "$currentuser" /usr/bin/osascript -e "display dialog \"$DisplayDialogMessage\" with icon stop buttons {\"End\"} default button 1"
	/usr/bin/killall Self\ Service
	exit 4
fi
}
###
#

#
### Message to user, explaining what this script will do. ###
MessageToUser () {
/bin/echo MessageToUser
DisplayDialogMessage="This will convert your current network user account to a local account.

Please SAVE all files and QUIT all apps before proceeding.

When complete, your computer will REBOOT.

Your system MUST be connected to AC power to continue."
/usr/bin/sudo -u "$currentuser" /usr/bin/osascript -e "display dialog \"$DisplayDialogMessage\" with title \"Reboot Warning\" with icon caution" >/dev/null 2>&1
	# Stop everything if the cancel button is pressed.
if [ $? -eq 1 ];
	then /bin/echo "User canceled policy.";
	/usr/bin/killall Self\ Service
	exit 5
fi
}
###
#

#
### Check to see if the system is connected to AC power. ###
pmsetPowerStatus () {
/bin/echo pmsetPowerStatus
PowerDraw=$(/usr/bin/pmset -g ps | /usr/bin/awk -F "'" '{ print $2;exit }')

until [ "$PowerDraw" == "AC Power" ]; do
	/bin/echo "Now drawing from 'Battery Power'"
	DisplayDialogMessage="Please connected your system to AC power."
	/usr/bin/sudo -u "$currentuser" /usr/bin/osascript -e "display dialog \"$DisplayDialogMessage\" with title \"Power Warning\" with icon stop" >/dev/null 2>&1
	# Stop everything if the cancel button is pressed.
	if [ $? -eq 1 ];
		then /bin/echo "User canceled policy.";
		/usr/bin/killall Self\ Service
		exit 6
	fi
	/bin/sleep 2
	PowerDraw=$(/usr/bin/pmset -g ps | /usr/bin/awk 'NR>1{exit};1' | /usr/bin/awk '{print $4,$5}' | /usr/bin/sed "s/'//g")
done
/bin/echo "Now drawing from 'AC Power'"
}
###
#

#
### For creating a User we need some input ###
UserInfo () {
/bin/echo UserInfo
USERNAME="$currentuser"
/bin/echo "USERNAME: 	$USERNAME"
#
FULLNAME=$(/usr/bin/id -F $USERNAME)
/bin/echo "FULLNAME: 	$FULLNAME"
#
USERNAMEGROUPS=$(/usr/bin/id $USERNAME)
/bin/echo "USERNAMEGROUPS: 	$USERNAMEGROUPS"
}
###
#

#
### Begin Password stuff ###
CaptureUserPassword () {
/bin/echo CaptureUserPassword
# Display Dialog to capture user password.
DisplayDialogMessage="Please enter the password for user account - $USERNAME."
PASSWORD=$(/usr/bin/sudo -u "$currentuser" /usr/bin/osascript -e "text returned of (display dialog \"$DisplayDialogMessage\" default answer \"\" buttons {\"Ok\" , \"Cancel\"} default button 1 with title\"Password\" with hidden answer)") >/dev/null 2>&1
# Stop everything if the cancel button is pressed.
if [ $? -eq 1 ];
	then /bin/echo "User canceled policy.";
	/usr/bin/killall Self\ Service
	exit 7
fi
# Blank passwords don't work.
while [ "$PASSWORD" == "" ];
do
	/bin/echo "Password is blank";
	DisplayDialogMessage="A BLANK PASSWORD IS INVALID.
	Please enter the password for user account - $USERNAME."
	PASSWORD=$(/usr/bin/sudo -u "$currentuser" /usr/bin/osascript -e "text returned of (display dialog \"$DisplayDialogMessage\" default answer \"\" buttons {\"Ok\" , \"Cancel\"} default button 1 with title\"Password\" with hidden answer)") >/dev/null 2>&1
	# Stop everything if the cancel button is pressed.
	if [ $? -eq 1 ];
		then /bin/echo "User canceled policy.";
		/usr/bin/killall Self\ Service
		exit 8
	fi
done

# Verify user Password is correct
PASSWORDCHECK=$(/usr/bin/dscl /Local/Default -authonly $USERNAME $PASSWORD)
until [ "$PASSWORDCHECK" == "" ];
do
	/bin/echo "Incorrect password, please retry."
	DisplayDialogMessage="INCORRECT PASSWORD
	Please re-enter the password for user account - $USERNAME."
	PASSWORD=$(/usr/bin/sudo -u "$currentuser" /usr/bin/osascript -e "text returned of (display dialog \"$DisplayDialogMessage\" default answer \"\" buttons {\"Ok\" , \"Cancel\"} default button 1 with title\"Password\" with hidden answer)") >/dev/null 2>&1
	# Stop everything if the cancel button is pressed.
	if [ $? -eq 1 ];
		then /bin/echo "User canceled policy.";
		/usr/bin/killall Self\ Service
		exit 7
	fi
	# Blank passwords don't work.
	while [ "$PASSWORD" == "" ];
	do
		/bin/echo "Password is blank";
		DisplayDialogMessage="A BLANK PASSWORD IS INVALID.
		Please enter the password for user account - $USERNAME."
		PASSWORD=$(/usr/bin/sudo -u "$currentuser" /usr/bin/osascript -e "text returned of (display dialog \"$DisplayDialogMessage\" default answer \"\" buttons {\"Ok\" , \"Cancel\"} default button 1 with title\"Password\" with hidden answer)") >/dev/null 2>&1
		# Stop everything if the cancel button is pressed.
		if [ $? -eq 1 ];
			then /bin/echo "User canceled policy.";
			/usr/bin/killall Self\ Service
			exit 8
		fi
	done
	PASSWORDCHECK=$(/usr/bin/dscl /Local/Default -authonly $USERNAME $PASSWORD)
done
}
### End Password stuff ###
#

#
### Begin jamfHelper stuff ###
jamfHelperCurtain () {
/bin/echo jamfHelperCurtain
# Display Full screen message to user
/bin/echo "Put up the curtain."
#/usr/bin/sudo -u "$currentuser"
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType fs -title "Convert to Local User" -heading "Reboot Warning" -description "This system will reboot when the process is complete.
Thank you for your patience." -icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns &
}
### End jamfHelper stuff ###
#

#
### Begin FileVault stuff ###
FileVaultStuff () {
/bin/echo FileVaultStuff
# Check the status of FileVault
FV2Stat=$(/usr/bin/fdesetup status)
/bin/echo "FV2Stat: $FV2Stat"
# Check the currently logged in user a FileVault user.
FVUserCheck=$(/usr/bin/fdesetup list | /usr/bin/grep "$USERNAME," |  /usr/bin/awk -F',' '{print $1}')
#/bin/echo "FVUserCheck: $FVUserCheck"
#
if [[ "$FV2Stat" =~ "FileVault is On" ]] && [[ ! "$FV2Stat" =~ "Encryption in progress" ]] && [[ "$FVUserCheck" == "$USERNAME" ]]; then
	/bin/echo "Do FileVault Stuff"
	# Create a tmp filevault account
	# This is a very complex password in case a complex local password profile is in use.
	# Do not use any special characters beside "@". Otherwise the plist does not like it.
	# This also does not use any repeating characters.
	# If this script fails, the most likely problem is this password does not meet the password rules.
	FVtmpUserPASSWORD="L0tsOf3ntropy4AT3mpP@5SwordFrom1970"
	FVtmpUser="fvtmpuser"
	# Delete FVtmpUser just in case it already exists
	/usr/sbin/sysadminctl -deleteUser $FVtmpUser
	# Clear the list of deleted user accounts
	/bin/rm -f /Library/Preferences/com.apple.preferences.accounts.plist
    #
	/bin/echo "Creating $FVtmpUser account."
	/usr/sbin/sysadminctl -addUser $FVtmpUser -fullName $FVtmpUser -password $FVtmpUserPASSWORD -UID 456 -home /private/tmp/$FVtmpUser
	#
	# create the plist file:
	/bin/echo '<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
	<key>Password</key>
	<string>'$PASSWORD'</string>
	<key>AdditionalUsers</key>
	<array>
		<dict>
			<key>Username</key>
			<string>'$FVtmpUser'</string>
			<key>Password</key>
			<string>'$FVtmpUserPASSWORD'</string>
		</dict>
	</array>
	</dict>
	</plist>' > /private/tmp/fvenable.plist
	#
	/usr/bin/fdesetup add -inputplist < /tmp/fvenable.plist -verbose
	# clean up
	/bin/rm -f /tmp/fvenable.plist
	#
	# make sure it all worked.
	FVtmpUserCheck=$(/usr/bin/fdesetup list | /usr/bin/grep "$FVtmpUser," |  /usr/bin/awk -F',' '{print $1}')
	/bin/echo "FVtmpUserCheck: $FVtmpUserCheck"
	/bin/echo "FVtmpUser: $FVtmpUser"
	if [[ ! "$FVtmpUserCheck" == "$FVtmpUser" ]]; then
		/bin/echo "Error creating $FVtmpUser account."
		exit 9
	else
		FVtmpUserCreated="yes"
	fi
else
    /bin/echo "Nothing needs to happen with FileVault. Proceeding..."
fi
}
### End FileVault stuff ###
#

#
### Begin Account stuff ###
AccountStuff () {
/bin/echo AccountStuff
# Is this an admin user?
/bin/echo "Is $USERNAME an admin user?"
if [[ "$USERNAMEGROUPS" == *"80(admin)"* ]];then
	/bin/echo "$USERNAME is an admin user."
	MAKE_ADMIN="-admin"
else
    /bin/echo "$USERNAME is NOT an admin user."
    MAKE_ADMIN=""
fi

# Do Account stuff
/bin/echo "Delete network user account. Keep home directory"
/usr/sbin/sysadminctl -deleteUser $USERNAME -keepHome
/bin/echo "Clear the list of deleted user accounts"
/bin/rm -f /Library/Preferences/com.apple.preferences.accounts.plist
/bin/echo "Create new local user account."
/usr/sbin/sysadminctl -addUser $USERNAME -fullName "$FULLNAME" -password $PASSWORD $MAKE_ADMIN # -UID $LOCALUSERID

# be sure to get $LOCALUSERID from dscl
LOCALUSERID=$(/usr/bin/dscl . -read /Users/$USERNAME UniqueID | /usr/bin/awk '{print $2}')
/bin/echo "LOCALUSERID: $LOCALUSERID"

#chown Home Directory to new UID
/usr/bin/chflags -R nouchg /Users/$USERNAME/
/usr/sbin/chown -R $LOCALUSERID:staff /Users/$USERNAME/
/bin/ls -al /Users/ | /usr/bin/grep $USERNAME
/bin/ls -aln /Users/ | /usr/bin/grep $USERNAME

/bin/echo "Run id command for $USERNAME"
/usr/bin/id $USERNAME

# Add new local account to FileVault
/bin/echo "FVtmpUserCheck: $FVtmpUserCheck"
/bin/echo "FVtmpUser: $FVtmpUser"

if [[ "$FVtmpUserCreated" == "yes" ]]; then
	# create the plist file:
	/bin/echo '<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
	<key>Password</key>
	<string>'$FVtmpUserPASSWORD'</string>
	<key>AdditionalUsers</key>
	<array>
		<dict>
			<key>Username</key>
			<string>'$USERNAME'</string>
			<key>Password</key>
			<string>'$PASSWORD'</string>
		</dict>
	</array>
	</dict>
	</plist>' > /private/tmp/fvenable.plist
	#
	/usr/bin/fdesetup add -inputplist < /tmp/fvenable.plist -verbose
	# clean up
	/bin/rm -f /tmp/fvenable.plist
	# Delete FVtmpUser
	/usr/sbin/sysadminctl -deleteUser $FVtmpUser
	# Clear the list of deleted user accounts
	/bin/rm -f /Library/Preferences/com.apple.preferences.accounts.plist
fi
}
### End Account stuff ###
#

#
### Begin Cleanup ###
CleanupStuff () {
/bin/echo CleanupStuff
# Clear the password variables to cleanup.
PASSWORD=""
FVtmpUserPASSWORD=""
# Clear any FileVault plists
/bin/rm -f /tmp/fvenable.plist
# Clear the list of deleted user accounts
/bin/rm -f /Library/Preferences/com.apple.preferences.accounts.plist
# Clear the user's ByHost MicrosoftLyncRegisttionDB plists. This can cause Lync to crash after converting the user account.
# There may be other ByHost plist files that may also misbehave after converting the user account.
/bin/rm -Rf /Users/$USERNAME/Library/Preferences/ByHost/MicrosoftLyncRegisttionDB.*
}
### End Cleanup ###
#

#
### Logout Current User ###
# This can potentially be used instead of a restart.
# It takes 60 seconds to log the current user out.
LogoutCurrentUser () {
/bin/echo LogoutCurrentUser
/usr/bin/osascript << EOF
ignoring application responses
tell application "loginwindow" to «event aevtlogo»
end ignoring
EOF
}
### End Cleanup ###
#

#
### Reboot Mac using jamf command ###
JamfRebootMacImmediately () {
/bin/echo JamfRebootMacImmediately
jamf manage
jamf recon
jamf fixByHostFiles 
jamf flushCaches -flushSystem -flushUsers
jamf reboot -background -immediately
# The jamf command cannot do a File Vault authenticated restart. Call a separate policy for File Vault authenticated restart.
}
### End Cleanup ###
#

####################################################################################################
#
# SCRIPT CONTENTS
#
####################################################################################################

rootcheck

OSXVersioncheck

CurrentUserIDcheck

MobileAccountcheck

MessageToUser

pmsetPowerStatus

UserInfo

CaptureUserPassword

jamfHelperCurtain

FileVaultStuff

AccountStuff

CleanupStuff

#JamfRebootMacImmediately

####################################################################################################
#
# Reboot and logout options
#
####################################################################################################

#LogoutCurrentUser # This can potentially be used instead of a restart. It takes 60 seconds to log the current user out.

#shutdown -r now # uncomment this line if you are running the script manually.

# You can include a restart in the Jamf Policy. However, this will restart the Mac even if the user cancels the self Service mid stream.
# Ideally you should have this script call a separate Jamf policy to reboot the Mac. You can use a customer trigger for this.
# This also give you the capability to do an FileVault authenticated restart.

# Because we are restarting via a separate policy, we have to initiate the recon from this script.
jamf manage
jamf recon
jamf policy -event $RebootTrigger

exit 0

