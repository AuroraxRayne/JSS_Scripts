#!/bin/bash

# The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
# MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
# THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
# OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
#
# IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
# MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
# AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
# STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# Password change sample script
# 
# This script shows how to perform various operations against a user's keychain after a 
# password change with Enterprise Connect. It should not be used "as is" - you will need 
# to customize it for your environment. It is simply intended to be used as a starting
# point. Also, this script is UNSUPPORTED by Apple or Apple Professional Services. You are
# responsible for tailoring it for use on your network.
# 
# This script has been simplified from previous versions into a form that should be more 
# directly applicable to most users. Also, this script does not attempt to re-create 
# keychain entries with the new password - it just removes existing Keychain entries. 
#
# You can potentially use this script to create new keychain entries with the user's new 
# Active Directory password. Doing so entails some security risk and is generally
# only for advanced administrators who have considered these risks.
# 
# You could use the "security" command to get the password from Enterprise 
# Connect's keychain entry and use it to update other keychain entries.
# This approach is convenient for the end user, but the problem with this approach is that
# the user will be prompted to allow the "security" command access to Enterprise Connect's
# keychain item. You generally don't want to encourage your users to click "Allow" when 
# the keychain presents these dialogs. If the user clicks the "Always allow" button
# Enterprise Connect 1.6.4 will remove the security command's access to its keychain entry
# immediately after executing the password change script. Still, users should be
# discouraged from clicking the "Always Allow" button.
#
# You can get Enterprise Connect's keychain password by running:
# UserName=`/usr/bin/security find-generic-password -l "Enterprise Connect" | grep "acct" | awk -F "=" '{print $2}' | tr -d "\""`
# UserPW=`/usr/bin/security find-generic-password -l "Enterprise Connect" -w`
# 
# Another less convenient, but more secure possibility is to use the third party 
# cocoaDialog tool to ask for the user's password, validate it, then use it as needed 
# later in your script. This method requires you to ask the user for their password again,
# but doesn't read the Enterprise Connect password from the keychain. Here's an example:
#
## Change this to point to cocoaDialog
# CD="/Applications/CocoaDialog.app/Contents/MacOS/CocoaDialog"
#
## Get the user's UPN
# userPrinc=`klist|grep "Principal:" | awk '{print $2}'`
# passText="Enter your new password:"
# pass=""
# if [ "$userPrinc" != "" ]; then
#        success=0
#        while [ $success -eq 0 ];do
#                # This is an easy way to see if the user provided a valid password
#				 pass=`$CD standard-inputbox --no-show --title "Password updates" --informative-text "$passText" -no-newline | tail +2 `
#				 echo $pass | kinit --password-file=STDIN $userPrinc
#                if [ $? -eq 0 ]; then
#                        success=1
#                else
#                        passText="You entered your password incorrectly. Re-enter your new password:"
#                fi
#        done
# fi
#
# The above method will still momentarily expose the user's password in a process listing. 
# If you can accept this risk it should work well.
# 
# Once you get the password, you'll need to take appropriate precautions to keep it secure.
#
# Thanks to Jeffrey Compton for providing much of the content of this script.


# Script-wide VARS
#
# Gets the path to your login keychain. We do this since the name of the
# login keychain changed in Sierra. If you want to search some other keychain
# modify this as needed.
if [ -e $HOME/Library/Keychains/login.keychain-db ]; then
	userKeychain=$HOME/Library/Keychains/login.keychain-db
else
	userKeychain=$HOME/Library/Keychains/login.keychain
fi

# Used to write logs. Make sure this directory exists or specify another directory
log_dir="$HOME/Library/Logs/passwordChange"
log_file="pwChangeCleanup.log"
log_location="$log_dir/$log_file"

if [[ -d “$log_dir” ]]; then
	if [[ -f $log_file ]]; then
		echo “Log file exists”
	else
		touch $log_file
	fi
	else
	echo “Making Log folder and file”
	mkdir $log_dir
	cd $log_dir
	touch $log_file
fi

# Replace this with the name of your SSID
ssidName=("ddc" "Dealertrack-TM" "Dealertrack-Mobile" "CAI-Mobile" "MANSWN")

# Setting IFS Env to only use new lines as field seperator 
IFS=$'\n'

# This function finds and deletes any Outlook Exchange passwords from the user's keychain.
exchangeRemove ()
{
echo "\n----------------------------------------------"
if [[ `/usr/bin/security find-generic-password -l Exchange $userKeychain` ]]
	then
		exchangePasswordClearStatus=0
		until (( $exchangePasswordClearStatus == 1 ))
			do
				echo "Looking for existing entry for exchange password..."
				if [[ `/usr/bin/security find-generic-password -l Exchange $userKeychain` ]]
					then 
						echo "Found an existing password in user keychain for exchange.  Attempting to delete..."
						/usr/bin/security delete-generic-password -l Exchange $userKeychain
							if (( $? == 0 ))
								then 
									echo "Exchange password deleted"
							fi
					else
						echo "Did NOT find any more passwords in user keychain for Exchange."
						exchangePasswordClearStatus=1
				fi
			done
	else 
		echo "Did not find a saved password for Exchange"
fi
}

# This function removes Skype for Business passwords and associated data
sfBRemove ()
{
echo "\n----------------------------------------------"
if [[ `/usr/bin/security find-generic-password -l "Skype for Business" $userKeychain` ]]
	then
		SFBPasswordClearStatus=0
		until (( $SFBPasswordClearStatus == 1 ))
			do
				echo "Looking for existing entry for SFB password..."
				if [[ `/usr/bin/security find-generic-password -l "Skype for Business" $userKeychain` ]]
					then 
						echo "Found an existing password in user keychain for SFB.  Attempting to delete..."
						/usr/bin/security delete-generic-password -l "Skype for Business" $userKeychain
							if (( $? == 0 ))
								then 
									echo "SFB password deleted"
							fi
					else
						echo "Did NOT find any more passwords in user keychain for SFB."
						SFBPasswordClearStatus=1
				fi
			done
	else 
		echo "Did not find a saved password for SFB"
fi
}
# Removes the 802.1x/PEAP password for a given wi-fi network.
peapRemove ()
{
echo "\n----------------------------------------------"

for ssid in ${ssidName[@]}; do
	if [[ `/usr/bin/security find-generic-password -s "com.apple.network.eap.user.item.wlan.ssid.$ssid" $userKeychain` ]]
		then
			peapPasswordClearStatus=0
			until (( $peapPasswordClearStatus == 1 ))
				do
					echo "Looking for existing entries for $ssid password..."
					if [[ `/usr/bin/security find-generic-password -s "com.apple.network.eap.user.item.wlan.ssid.$ssid" $userKeychain` ]]
						then
							echo "Found an existing password in user keychain for $ssid.  Attempting to delete..."
							/usr/bin/security delete-generic-password -s "com.apple.network.eap.user.item.wlan.ssid.$ssid"
								if (( $? == 0 ))
									then 
										echo "SSID password for $ssid deleted"
								fi
						else
							echo "Did NOT find any more passwords in user keychain for SSID $ssid."
                        	peapPasswordClearStatus=1
					fi
				done
		else 
			echo "Did not find a saved password for SSID"
	fi
done	
}

peapRemove >> $log_location 2>&1
exchangeRemove >> $log_location 2>&1
lyncRemove >> $log_location 2>&1

##### Restoring IFS to original 
unset IFS

exit 0
