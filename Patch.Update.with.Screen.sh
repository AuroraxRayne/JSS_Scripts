#!/bin/sh

LoggedInUser=`ls -l /dev/console | cut -d " " -f4`

#Check for FOLDER if not create and chmod (create your own place holder)
if [ -d /Library/Application\ Support/FOLDER ]; then
    echo "Directory already exist"
else
    echo "Lets make the directory"
    mkdir /Library/Application\ Support/FOLDER && chmod 777 /Library/Application\ Support/FOLDER
fi

# Set check File in $4 variable
if [[ "$4" != "" ]]; then
check="$4"
fi
# Have we run this already?
if [ -f /Library/Application\ Support/FOLDER/.$check ]; then
    echo "Patches already ran"
    exit 2
fi

if [ ! -e /Library/Application\ Support/JAMF/.SoftwareUpdateTimer.txt ]; then
    echo "10" > /Library/Application\ Support/JAMF/.SoftwareUpdateTimer.txt
fi

Timer=`cat /Library/Application\ Support/JAMF/.SoftwareUpdateTimer.txt`

fRunUpdates ()
{
    echo "Timer is currently $Timer"
    echo "10" > /Library/Application\ Support/JAMF/.SoftwareUpdateTimer.txt
    
   #/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType fs -heading 'Software Updates' -description 'Software Updates are being performed.  Please do not turn off this computer. It will reboot when updates are completed.  Please be sure to plug your computer into power.' -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns > /dev/null 2>&1 &
    mirror=`/Users/Shared/mirror -q`

	if [[ ${mirror} == "off" ]]; then
		echo "Toggle Mirror Mode On"
		/Users/Shared/mirror -t
		open /Users/Shared/ProgressScreen.app
		mirror2="on"
	else
		echo "Mirror mode on"
		open /Users/Shared/ProgressScreen.app
	fi
    ## In case we need the process ID for the jamfHelper
    JHPID=`echo "$!"`
    /usr/local/jamf/bin/jamf policy -trigger killapple
    ## Run the update policy
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger App1
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger App2
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger App3
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger App4
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger App5
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger App6
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger App7
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger App8
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger App9
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger App10
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger App11
    echo `date +"%Y-%m-%d %H:%M:%S"`
    touch /Library/Application\ Support/DT/.$check
    sleep 2
    TimerReset=`cat /Library/Application\ Support/JAMF/.SoftwareUpdateTimer.txt`
    echo "Timer reset to $TimerReset"
    sleep 2
    #killall jamfHelper
    echo "Finishing Updates..."
	sleep 2
    /usr/local/jamf/bin/jamf recon
    sleep 2
	/usr/local/jamf/bin/jamf policy -trigger "test"
	if [[ $mirror2 == "on" ]]; then
		echo "Toggle Mirror Mode off"
		/Users/Shared/mirror -t
		sleep 1
	fi
    exit 0
}

if [ "$LoggedInUser" == "" ]; then
    fRunUpdates
else
    if [ $Timer -gt 0 ]; then
        HELPER=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "Software Updates are available for your Mac" -description "If you would like to install updates now, save all your work then click Install (Then go grab a coffee or snack as you won't be able to use your computer).
        
If you would NOT like to install updates now, click Cancel.
        
You may choose to not install updates $Timer more time(s) before this computer will forcibly install them.
        
A reboot MAYBE required.  Please be sure to plug your computer into power.

BE SURE TO QUIT OUT OF ALL APPLICATIONS BEFORE CLICKING INSTALL!
        
You may also choose to manually run these updates.  Simply open Self Service and click on the Monthly Patching Self Service option.


" -button1 "Install" -button2 "Cancel" -defaultButton "2" -cancelButton "2" -timeout 900 -countdown -alignCountdown center -alignDescription justified`


        echo "jamf helper result was $HELPER";

        if [ "$HELPER" == "0" ]; then
            fRunUpdates
        else
            let CurrTimer=$Timer-1
            echo "$LoggedInUser clicked Cancel"
            echo "Timer is currently $CurrTimer"
            echo "$CurrTimer" > /Library/Application\ Support/JAMF/.SoftwareUpdateTimer.txt
            exit 0
        fi
    fi
fi
## If Timer is already 0, run the updates automatically, the user has been warned!
if [ $Timer -eq 0 ]; then
    echo "Final warning given"
    /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "Software Updates Starting" -description "The max amount of install deferments (10) has past.  Updates will automatically be installed in 3 minutes . (Go grab a coffee or snack as you won't be able to use your computer).  Please be sure to plug your computer into power." -button1 "OK" -defaultButton "1" -timeout 180 -countdown -alignDescription justified -alignCountdown center
    
    fRunUpdates
fi
