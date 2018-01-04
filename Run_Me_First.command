#!/bin/sh

/usr/bin/touch /var/log/Run_Me_First.log

LOG=/var/log/Run_Me_First.log


#Lets make sure Jamf Imaging is closed

killall "Jamf Imaging"

/bin/sleep 1.5

#Check to see if computer to be imaged is already APFS formatted
apfsCheck=$(/usr/sbin/diskutil list | grep "Apple_APFS") | tee -a $LOG
ssdCheck=$(/usr/sbin/diskutil info /dev/disk0 | awk '/Solid State/{print $NF}')

if [[ "$ssdCheck" != "Yes" ]]; then
	echo "Not a SSD!.  I will quit Terminal and Open Jamf Imaging for you..."
	/bin/sleep 6
	/usr/bin/open -a "Jamf Imaging"
	killall "Terminal"
	exit 0
else
	echo "We gots us an SSD!  Let me make sure it is APFS Formatted....."
	/bin/sleep 5
	if [[ "$apfsCheck" == "" ]]; then
		#Drive is not APFS
		echo "Drive is not APFS"
		#Lets Create a Container for APFS
		/usr/sbin/diskutil eraseDisk JHFS+ Blah disk0
		/bin/sleep 2
		/usr/sbin/diskutil apfs create disk0s2 "Macintosh HD"
		echo "We are half way there!!"
		/bin/sleep 3
		#Lets install Firmware to read APFS
		/usr/sbin/installer -verbose -pkg /private/var/root/Desktop/FirmwareUpdateStandalone-1.0.pkg -target /Volumes/Macintosh\ HD
		/bin/sleep 2		
		#Display Popup about Rebooting to install Firmware
		/usr/bin/osascript -e'tell app "System Events" to display dialog "This machine will reboot in 20 seconds to install a needed firmware update.  Please allow at least one reboot and then netboot again to image this machine." with title "Reboot Required" giving up after 20'
		/bin/sleep 2
		/sbin/shutdown -r now
		#echo "All done!!  Let me open Jamf Imaging for you...."
	
	else
	#Drive is already APFS.  Lets trash it
	echo "Drive is already APFS.  Lets trash it."
	/bin/sleep 5
	/usr/sbin/diskutil apfs eraseVolume disk1s1 -name "Macintosh HD"
	
	fi
	
fi


#Lets relaunch Jamf Imaging

/usr/bin/open -a "Jamf Imaging"

killall "Terminal"

