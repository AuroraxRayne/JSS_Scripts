#!/bin/sh

#Get Username of currently logged in User
userName=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'` 


## Get the logged in user's password via a prompt
echo "Prompting ${userName} for their login password."
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "FileVault Decryption" -description "In order to prepare to migrate to the new Cox Auto Casper Server, we will need to decrypt your Mac.  Once on the new server, you will be prompted to re-encrypt your machine.

After clicking OK to this message, you will be prompted for your password.  You should type in the first password you would type when you reboot your computer.

If the wrong password is typed, you will be prompted one more time.  If that fails, please visit your local Desktop Support for assistance." -button1 "OK"

##Prompt for password
userPassword="$(/usr/bin/osascript -e 'with timeout of 600 seconds' -e 'Tell application "System Events" to display dialog "Please enter your login password:" default answer "" with title "Login Password" with text buttons {"Ok"} default button 1 with hidden answer' -e 'end timeout' -e 'text returned of result')"

sleep 2

## This "expect" block will populate answers for the fdesetup prompts that normally occur while hiding them from output
	expect -c "
	log_user 0
	spawn fdesetup disable
	expect \"Enter a password for '/', or the recovery key:\"
	send "{${userPassword}}"
	send \r
	log_user 1
	expect eof
	"

sleep 3

fvstatus=$(fdesetup status)

if [[ "$fvstatus" =~ "FileVault is Off" ]]; then
	/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "FileVault Decryption Success" -description "FileVault Decryption has started.  Your machine will reboot in 60 seconds." -button1 "OK" -timeout 60 -countdown
	sleep 2
	
	/usr/local/bin/jamf policy -trigger rebootnow
	
	exit 0
else
	echo "Incorrect Password"
	##Prompt for password
	userPassword="$(/usr/bin/osascript -e 'with timeout of 600 seconds' -e 'Tell application "System Events" to display dialog "Please enter your login password:" default answer "" with title "Login Password" with text buttons {"Ok"} default button 1 with hidden answer' -e 'end timeout' -e 'text returned of result')"
	
	sleep 2

	## This "expect" block will populate answers for the fdesetup prompts that normally occur while hiding them from output
		expect -c "
		log_user 0
		spawn fdesetup disable
		expect \"Enter a password for '/', or the recovery key:\"
		send "{${userPassword}}"
		send \r
		log_user 1
		expect eof
		"
		
		sleep 2
		
		fvstatus2=$(fdesetup status)
		
		if [[ "$fvstatus2" =~ "FileVault is Off" ]]; then
			echo "Success"
			
			/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "FileVault Decryption Success" -description "FileVault Decryption has started.  Your machine will reboot in 60 seconds." -button1 "OK" -timeout 60 -countdown
			sleep 2

			/usr/local/bin/jamf policy -trigger rebootnow

			exit 0
		else
        
            echo "failed"
			
		    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "FileVault Decryption Failed" -description "FileVault Decryption unsuccessful. Please reach out to your local Desktop Support." -button1 "OK"
		
		    exit 1			
		fi		
fi
