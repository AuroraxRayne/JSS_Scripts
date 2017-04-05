#!/bin/sh

LOGO_PNG="/Library/User Pictures/Custom/CoxAuto.tif"

# Your company's logo, in ICNS format. (For use in AppleScript messages.)
# Use standard UNIX path format:  /path/to/file.icns
LOGO_ICNS="/Library/User Pictures/Custom/CoxAuto.tif"

# The title of the message that will be displayed to the user.
# Not too long, or it'll get clipped.
PROMPT_TITLE="FileVault key repair"

# The body of the message that will be displayed before prompting the user for
# their password. All message strings below can be multiple lines.
PROMPT_MESSAGE="Your Cox Automotive issued computer is currently encrypted.  A recovery key must be escrowed in order for Cox Automotive IT to be able to recover data from your hard drive in case of emergency.

Click the Next button below, then enter your Mac's password when prompted."

# The body of the message that will be displayed after 5 incorrect passwords.
FORGOT_PW_MESSAGE="You made three incorrect password attempts.

Please visit your local Desktop Support for help with your Mac password."

# The body of the message that will be displayed after successful completion.
SUCCESS_MESSAGE="Thank you! Your FileVault key has been regenerated."

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
if [[ ! -x "$jamfHelper" ]]; then
    echo "[ERROR] jamfHelper not found."
    BAIL=true
fi

OS_MAJOR=$(sw_vers -productVersion | awk -F . '{print $1}')
OS_MINOR=$(sw_vers -productVersion | awk -F . '{print $2}')
if [[ "$OS_MAJOR" -ne 10 || "$OS_MINOR" -lt 9 ]]; then
    echo "[ERROR] OS version not 10.9+ or OS version unrecognized."
    sw_vers -productVersion
    BAIL=true
fi

CURRENT_USER="$(stat -f%Su /dev/console)"

USER_ID=$(id -u "$CURRENT_USER")
if [[ "$OS_MAJOR" -eq 10 && "$OS_MINOR" -le 9 ]]; then
    L_ID=$(pgrep -x -u "$USER_ID" loginwindow)
    L_METHOD="bsexec"
elif [[ "$OS_MAJOR" -eq 10 && "$OS_MINOR" -gt 9 ]]; then
    L_ID=USER_ID
    L_METHOD="asuser"
fi


prompt=$("$jamfHelper" -windowType "hud" -icon "$LOGO_PNG" -title "$PROMPT_TITLE" -description "$PROMPT_MESSAGE" -button1 "Next" -timeout 5 -defaultButton "2")



#HELPER=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "Software Updates are available for your Mac" -description "If you would like to install updates now, save all your work then click Install (Then go grab a coffee or snack as you won't be able to use your computer).
        
#If you would NOT like to install updates now, click Cancel.
        
#You may choose to not install updates $Timer more time(s) before this computer will forcibly install them.
        
#A reboot MAYBE required.  Please be sure to plug your computer into power.

#BE SURE TO QUIT OUT OF ALL APPLICATIONS BEFORE CLICKING INSTALL!
        
#You may also choose to manually run these updates.  Simply open Self Service and click on the Monthly Patching Self Service option.


#" -button1 "Next" -defaultButton "2" -timeout 5 -countdown -alignCountdown center -alignDescription justified`

#echo "$HELPER"

echo "$prompt"



if 0 promtp password
	if 2 exit