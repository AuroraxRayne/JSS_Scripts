#!/bin/sh

#Setup logging
CurrentDate=$(date +"%Y-%m-%d")
/bin/sleep 1
#Get Serial Number
sn=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')

if [ -d /var/root/log ]; then
echo "exist"
else
	echo "Creating log folder"
	mkdir /var/root/log
fi

/usr/bin/touch /var/root/log/"$sn"-"$CurrentDate".log

LOG=/var/root/log/"$sn"-"$CurrentDate".log

find /var/root/log/* -mtime +5 -exec rm {} \;

#Lets make sure Jamf Imaging is closed

killall "Jamf Imaging"

/bin/sleep 1.5

#Check to see if computer to be imaged is already APFS formatted
apfsCheck=$(/usr/sbin/diskutil list | grep "Apple_APFS")
echo "apfsCheck is: $apfsCheck" >> $LOG
ssdCheck=$(/usr/sbin/diskutil info /dev/disk0 | awk '/Solid State/{print $NF}')
echo "ssdCheck is: $ssdCheck" >> $LOG
if [[ "$ssdCheck" != "Yes" ]]; then
	echo "Not a SSD!.  I will quit Terminal and Open Jamf Imaging for you..." | tee -a $LOG
	/bin/sleep 6
	/usr/bin/open -a "Jamf Imaging"
	killall "Terminal"
	exit 0
else
	echo "We gots us an SSD!  Let me make sure it is APFS Formatted....." | tee -a $LOG
	/bin/sleep 5
	if [[ "$apfsCheck" == "" ]]; then
		#Drive is not APFS
		echo "Drive is not APFS" | tee -a $LOG
		#Lets Create a Container for APFS
		echo "Lets Create a Container for APFS" | tee -a $LOG
		/usr/sbin/diskutil eraseDisk JHFS+ Blah disk0 | tee -a $LOG
		/bin/sleep 2
		/usr/sbin/diskutil apfs create disk0s2 "Macintosh HD" | tee -a $LOG
		echo "We are half way there!!" | tee -a $LOG
		/bin/sleep 3
		#Lets install Firmware to read APFS
		echo "Lets install Firmware to read APFS" | tee -a $LOG
		/usr/sbin/installer -verbose -pkg /private/var/root/Desktop/FirmwareUpdateStandalone-1.0.pkg -target /Volumes/Macintosh\ HD | tee -a $LOG
		/bin/sleep 2		
		#Display Popup about Rebooting to install Firmware
		/usr/bin/osascript -e'tell app "System Events" to display dialog "This machine will reboot in 20 seconds to install a needed firmware update.  Please allow at least one reboot and then netboot again to image this machine." with title "Reboot Required" giving up after 20'
		/bin/sleep 2
		/sbin/shutdown -r now
	
	else
	
	#Drive is already APFS.  Lets trash it
	echo "Drive is already APFS.  Lets trash it." | tee -a $LOG
	/bin/sleep 5
	/usr/sbin/diskutil apfs eraseVolume disk1s1 -name "Macintosh HD" | tee -a $LOG
	
	fi
	
fi


#Lets relaunch Jamf Imaging

/usr/bin/open -a "Jamf Imaging"

killall "Terminal"

