#!/bin/sh

LoggedInUser=`who | grep console | awk '{print $1}'`

if [ -d /Library/Application\ Support/DT ]; then
    echo "Directory already exist"
else
    echo "Lets make the directory"
    mkdir /Library/Application\ Support/DT && chmod 777 /Library/Application\ Support/DT
fi

if [[ "$4" != "" ]]; then
check="$4"
fi
# Have we run this already?
if [ -f /Library/Application\ Support/DT/.$check ]; then
    echo "Patches already ran"
fi

fRunUpdates ()
{
   echo "Timer is currently $Timer"
    echo "10" > /Library/Application\ Support/JAMF/.SoftwareUpdateTimer.txt
    
   /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType fs -heading 'Software Updates' -description 'Software Updates are being performed.  Please do not turn off this computer. It will reboot when updates are completed.  Please be sure to plug your computer into power.' -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns > /dev/null 2>&1 &
    
    ## In case we need the process ID for the jamfHelper
    JHPID=`echo "$!"`
    /usr/local/jamf/bin/jamf policy -trigger killapple
    ## Run the update policy
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger installAdobeFlashPlayer
    echo `date +"%Y-%m-%d %H:%M:%S"`
    #/usr/local/jamf/bin/jamf policy -trigger installFireFox
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger installADPassMon
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger installGoogleChrome
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger "installGoogle Drive"
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger installHipChat
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger installOffice2011Update
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger installOracleJava8
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger installSilverlight
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger "2016cacheinstall"
    echo `date +"%Y-%m-%d %H:%M:%S"`
    /usr/local/jamf/bin/jamf policy -trigger osupdates
    echo `date +"%Y-%m-%d %H:%M:%S"`
    touch /Library/Application\ Support/DT/.$check
    sleep 2
    TimerReset=`cat /Library/Application\ Support/JAMF/.SoftwareUpdateTimer.txt`
    echo "Timer reset to $TimerReset"
    sleep 2
    killall jamfHelper
    sleep 2
    exit 0
}

## Just run updates
   echo "10" > /Library/Application\ Support/JAMF/.SoftwareUpdateTimer.txt
   sleep 2
    fRunUpdates
