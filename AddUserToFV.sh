#!/bin/sh

# Your company's logo, in PNG format. (For use in jamfHelper messages.)
# Use standard UNIX path format:  /path/to/file.png
LOGO_PNG="/Library/User Pictures/Custom/CoxAuto.tif"

# Your company's logo, in ICNS format. (For use in AppleScript messages.)
# Use standard UNIX path format:  /path/to/file.icns
LOGO_ICNS="/Library/User Pictures/Custom/CoxAuto.tif"

# The title of the message that will be displayed to the user.
# Not too long, or it'll get clipped.
PROMPT_TITLE="FileVault Login Fix"

# The body of the message that will be displayed before prompting the user for
# their password. All message strings below can be multiple lines.
PROMPT_MESSAGE=" Your Cox Automotive issued computer is currently encrypted.  Your FileVault and Login passwords maybe out of sync.  This process will help allow us to sync up those password.

Click the Next button to begin the process and you will be prompted for your Login (newest) Password."

# The body of the message that will be displayed before prompting the user for
# their password. All message strings below can be multiple lines.
PROMPT_MESSAGE2="Click the Next button to continue the process and you will be prompted for your FileVault Password (The first password you type in after a reboot)."

# The body of the message that will be displayed after 3 incorrect passwords.
FORGOT_PW_MESSAGE="You made three incorrect password attempts.

Please contact your local Desktop Support for help with your Mac password or try running this again from self service."

# The body of the message that will be displayed after successful completion.
SUCCESS_MESSAGE="Your FileVault login has been synced!"

FAIL_MESSAGE="Something has not worked right.  Please visit your local Desktop Support Group to help resolve the issue or try running this again from self service."


###############################################################################
######################### DO NOT EDIT BELOW THIS LINE #########################
###############################################################################


######################## VALIDATION AND ERROR CHECKING ########################

# Suppress errors for the duration of this script. (This prevents JAMF Pro from
# marking a policy as "failed" if the words "fail" or "error" inadvertently
# appear in the script output.)
exec 2>/dev/null

BAIL=false

# Make sure the custom logos have been received successfully
if [[ ! -f "$LOGO_ICNS" ]]; then
    echo "[ERROR] Custom logo icon not present: $LOGO_ICNS"
    BAIL=true
fi
if [[ ! -f "$LOGO_PNG" ]]; then
    echo "[ERROR] Custom logo PNG not present: $LOGO_PNG"
    BAIL=true
fi

# Convert POSIX path of logo icon to Mac path for AppleScript
LOGO_ICNS="$(osascript -e 'tell application "System Events" to return POSIX file "'"$LOGO_ICNS"'" as text')"

# Bail out if jamfHelper doesn't exist.
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
if [[ ! -x "$jamfHelper" ]]; then
    echo "[ERROR] jamfHelper not found."
    BAIL=true
fi

# Most of the code below is based on the JAMF reissueKey.sh script:
# https://github.com/JAMFSupport/FileVault2_Scripts/blob/master/reissueKey.sh

# Check the OS version.
OS_MAJOR=$(sw_vers -productVersion | awk -F . '{print $1}')
OS_MINOR=$(sw_vers -productVersion | awk -F . '{print $2}')
if [[ "$OS_MAJOR" -ne 10 || "$OS_MINOR" -lt 9 ]]; then
    echo "[ERROR] OS version not 10.9+ or OS version unrecognized."
    sw_vers -productVersion
    BAIL=true
fi

# Check to see if the encryption process is complete
FV_STATUS="$(fdesetup status)"
if grep -q "Encryption in progress" <<< "$FV_STATUS"; then
    echo "[ERROR] The encryption process is still in progress."
    echo "$FV_STATUS"
    BAIL=true
elif grep -q "FileVault is Off" <<< "$FV_STATUS"; then
    echo "[ERROR] Encryption is not active."
    echo "$FV_STATUS"
    BAIL=true
elif ! grep -q "FileVault is On" <<< "$FV_STATUS"; then
    echo "[ERROR] Unable to determine encryption status."
    echo "$FV_STATUS"
    BAIL=true
fi

# Get the logged in user's name
CURRENT_USER="$(stat -f%Su /dev/console)"

# This first user check sees if the logged in account is already authorized with FileVault 2
FV_USERS="$(fdesetup list)"
if ! egrep -q "^${CURRENT_USER}," <<< "$FV_USERS"; then
    echo "[ERROR] $CURRENT_USER is not on the list of FileVault enabled users:"
    echo "$FV_USERS"
    #BAIL=true
fi

# If any error occurred above, bail out.
if [[ "$BAIL" == "true" ]]; then
    exit 1
fi

################################ MAIN PROCESS #################################

# Get information necessary to display messages in the current user's context.
USER_ID=$(id -u "$CURRENT_USER")
if [[ "$OS_MAJOR" -eq 10 && "$OS_MINOR" -le 9 ]]; then
    L_ID=$(pgrep -x -u "$USER_ID" loginwindow)
    L_METHOD="bsexec"
elif [[ "$OS_MAJOR" -eq 10 && "$OS_MINOR" -gt 9 ]]; then
    L_ID=USER_ID
    L_METHOD="asuser"
fi

addUser ()
{
# Get the logged in user's password via a prompt.
echo "Prompting $CURRENT_USER for their Mac password..."
USER_PASS="$(launchctl "$L_METHOD" "$L_ID" osascript -e 'display dialog "Please enter the password your current network password (E-mail, Fuel, join.me, etc):" default answer "" with title "'"${PROMPT_TITLE//\"/\\\"}"'" giving up after 86400 with text buttons {"OK"} default button 1 with hidden answer with icon file "'"${LOGO_ICNS//\"/\\\"}"'"' -e 'return text returned of result')"

# Thanks to James Barclay (@futureimperfect) for this password validation loop.
TRY=1
until dscl /Search -authonly "$CURRENT_USER" "$USER_PASS" &>/dev/null; do
    (( TRY++ ))
    echo "Prompting $CURRENT_USER for their Mac password (attempt $TRY)..."
    USER_PASS="$(launchctl "$L_METHOD" "$L_ID" osascript -e 'display dialog "Sorry, that password was incorrect. Please try again:" default answer "" with title "'"${PROMPT_TITLE//\"/\\\"}"'" giving up after 86400 with text buttons {"OK"} default button 1 with hidden answer with icon file "'"${LOGO_ICNS//\"/\\\"}"'"' -e 'return text returned of result')"
    if (( TRY >= 3 )); then
        echo "[ERROR] Password prompt unsuccessful after 3 attempts. Displaying \"forgot password\" message..."
        launchctl "$L_METHOD" "$L_ID" "$jamfHelper" -windowType "utility" -icon "$LOGO_PNG" -title "$PROMPT_TITLE" -description "$FORGOT_PW_MESSAGE" -button1 'OK' -defaultButton 1 -timeout 30 -startlaunchd &>/dev/null &
        exit 1
    fi
done
echo "Successfully prompted for Mac password."

echo "Alerting user $CURRENT_USER about incoming password prompt...(FV Password)"
launchctl "$L_METHOD" "$L_ID" "$jamfHelper" -windowType "utility" -icon "$LOGO_PNG" -title "$PROMPT_TITLE" -description "$PROMPT_MESSAGE2" -button1 "Next" -defaultButton 1 -startlaunchd &>/dev/null

# Get the logged in user's password via a prompt.
echo "Prompting $CURRENT_USER for their Mac password..."
FV_PASS="$(launchctl "$L_METHOD" "$L_ID" osascript -e 'display dialog "Please enter the password you use when you first boot your computer:" default answer "" with title "'"${PROMPT_TITLE//\"/\\\"}"'" giving up after 86400 with text buttons {"OK"} default button 1 with hidden answer with icon file "'"${LOGO_ICNS//\"/\\\"}"'"' -e 'return text returned of result')"

# If needed, unload FDERecoveryAgent and remember to reload later.
FDERA=false
if launchctl list | grep -q "com.apple.security.FDERecoveryAgent"; then
    FDERA=true
    echo "Unloading FDERecoveryAgent..."
    launchctl unload /System/Library/LaunchDaemons/com.apple.security.FDERecoveryAgent.plist
fi
echo "running fdesetup commands"

sleep 2

    expect -c "
    log_user 0
    spawn fdesetup add -usertoadd {${CURRENT_USER}}
    expect \"Enter a password for '/', or the recovery key:\"
    send "{${FV_PASS}}"
    send \r
    expect \"Enter the password for the added user '{${CURRENT_USER}}':\"
    send "{${USER_PASS}}"
    send \r
    log_user 1
    expect eof
    "
sleep 2

echo "finished fdesetup commands"
# Test success conditions.
FV_USERS2="$(fdesetup list)"
sleep 2
if ! egrep -q "^${CURRENT_USER}," <<< "$FV_USERS2"; then
    echo "[ERROR] $CURRENT_USER is not on the list of FileVault enabled users:"
    echo "Failed Users are: $FV_USERS2"
	echo "Displaying failure message..."
    launchctl "$L_METHOD" "$L_ID" "$jamfHelper" -windowType "utility" -icon "$LOGO_PNG" -title "$PROMPT_TITLE" -description "$FAIL_MESSAGE" -button1 'OK' -defaultButton 1 -timeout 30 -startlaunchd &>/dev/null &
	exit 1
else
	echo "Enabled Users are: $FV_USERS2"
	echo "Displaying success message..."
    launchctl "$L_METHOD" "$L_ID" "$jamfHelper" -windowType "utility" -icon "$LOGO_PNG" -title "$PROMPT_TITLE" -description "$SUCCESS_MESSAGE" -button1 'OK' -defaultButton 1 -timeout 30 -startlaunchd &>/dev/null &
    fdesetup sync
fi

# Reload FDERecoveryAgent, if it was unloaded earlier.
if [[ "$FDERA" == "true" ]]; then
    # Only if it wasn't automatically reloaded by `fdesetup`.
    if ! launchctl list | grep -q "com.apple.security.FDERecoveryAgent"; then
        echo "Loading FDERecoveryAgent..."
        launchctl load /System/Library/LaunchDaemons/com.apple.security.FDERecoveryAgent.plist
    fi
fi
}

# Display a branded prompt explaining the password prompt.
echo "Alerting user $CURRENT_USER about incoming password prompt..."
prompt=$("$jamfHelper" -windowType "utility" -icon "$LOGO_PNG" -title "$PROMPT_TITLE" -description "$PROMPT_MESSAGE" -timeout 300 -button1 "Next" -defaultButton "2")

if [ "$prompt" == "0" ]; then
	echo "Lets run addUser"
	addUser
else
	echo "5 min timer ran out"
	exit 1
fi