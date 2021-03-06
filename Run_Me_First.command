#!/bin/sh

#Setup logging and variables
if [ ! -d /var/root/log ]; then
	/bin/mkdir /var/root/log
fi

CurrentDate=$(date +"%Y-%m-%d")
startTime=$(date +"%Y-%m-%d %T")
sn=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
bootROM=$(system_profiler SPHardwareDataType | awk '/Boot ROM Version:/{print $NF}' | tail -c4)
/usr/bin/touch /var/root/log/"$sn"-"$CurrentDate".log
LOG=/var/root/log/"$sn"-"$CurrentDate".log
csGroup=$(diskutil cs list | awk '/Logical Volume Group/{print $NF}')
ipAddy=$(ifconfig | grep "inet" |grep -Fv 127.0.0.1 |grep -Fv inet6 | awk '{print $2}')

#Remove any logs older than 5 days
find /var/root/log/* -mtime +5 -exec rm {} \;


echo "############Starting Log for imaging $startTime###############" | tee -a $LOG
#Lets make sure Jamf Imaging is closed
killall "Jamf Imaging"
/bin/sleep 1.5

#Check to see if computer to be imaged is already APFS formatted
apfsCheck=$(/usr/sbin/diskutil list | grep "Apple_APFS" | awk '{print $2}')
echo "apfsCheck is: $apfsCheck" >> $LOG
ssdCheck=$(/usr/sbin/diskutil info /dev/disk0 | awk '/Solid State/{print $NF}')
echo "ssdCheck is: $ssdCheck" >> $LOG

if [[ "$ssdCheck" != "Yes" ]]; then
	echo "Not a SSD!.  I will quit Terminal and Open Jamf Imaging for you..." | tee -a $LOG
	/bin/sleep 5
	/usr/bin/osascript -e'tell app "System Events" to display dialog "This machine will REQUIRE using the the HFS Formatted workflow, Please make sure to choose the Correct Work flow in Imaging." with title "HFS FORMATTED DRIVE"'
	/bin/sleep 5
	/usr/bin/open -a "Jamf Imaging"
	killall "Terminal"
	exit 0
else
	echo "We gots us an SSD!  Let me make sure it is APFS Formatted....." | tee -a $LOG
	/bin/sleep 5
	if [[ "$apfsCheck" == "" ]]; then
		#Drive is not APFS
		echo "Drive is not APFS" | tee -a $LOG
		
		#Check and delete CoreStorage if present
		echo "Checking for CoreStorage" | tee -a $LOG
		if [[ "$csGroup" == "" ]]; then
			echo "There is no CoreStorage" | tee -a $LOG
			/bin/sleep 2
		else
			echo "We have a CoreStorage Scheme." | tee -a $LOG
			echo "Let me take care of that first." | tee -a $LOG
			/usr/sbin/diskutil cs delete "$csGroup" | tee -a $LOG
			echo "That's finished lets continue" | tee -a $LOG
			/bin/sleep 3
		fi

		#Lets Create a Container for APFS
		echo "Lets Create a Container for APFS" | tee -a $LOG
		/usr/sbin/diskutil eraseDisk JHFS+ Blah disk0 | tee -a $LOG
		/bin/sleep 2
		/usr/sbin/diskutil apfs create disk0s2 "Macintosh HD" | tee -a $LOG
		/bin/sleep 2
		
		#Run check to make sure new Container has Macintosh HD Volume
		newDisk=$(/usr/sbin/diskutil list | awk '/APFS Container Scheme/{print $NF}')
		volumeCheck=$(/usr/sbin/diskutil info /dev/"$newDisk"s1 | awk '/Volume Name/{print $3" "$4}')
		echo "VolumeCheck is: $volumeCheck" >> $LOG
		if [[ "$volumeCheck" != "Macintosh HD" ]]; then
			/usr/sbin/diskutil eraseDisk JHFS+ Blah disk0 | tee -a $LOG
			/bin/sleep 2
			/usr/sbin/diskutil apfs create disk0s2 "Macintosh HD" | tee -a $LOG
		fi
		
		#Run another check to make sure new Container has Macintosh HD Volume
		newDisk=$(/usr/sbin/diskutil list | awk '/APFS Container Scheme/{print $NF}')
		volumeCheck=$(/usr/sbin/diskutil info /dev/"$newDisk"s1 | awk '/Volume Name/{print $3" "$4}')
		echo "VolumeCheck is: $volumeCheck" >> $LOG
		if [[ "$volumeCheck" != "Macintosh HD" ]]; then
			echo "Failed format.  Display message to reach out to Dennis" >> $LOG
			/usr/bin/osascript -e'tell app "System Events" to display dialog "There seems to be an issue with creating the APFS Volume.  Try running the command file again.  If problem persist, please reach out to Dennis with the IP address below so that he can take look.


$ipAddy" with title "Failed Format"'
			exit 1
		fi
		
		if [[ "$bootROM" == B00 ]] || [[ "$bootROM" == 00B ]]; then
			echo "Boot ROM is already updated to support APFS!  Lets continue to imaging!" | tee -a $LOG
			/usr/bin/open -a "Jamf Imaging"
			killall "Terminal"
			exit 0
		else
			echo "We need to install the Firmware Update!!" | tee -a $LOG
			/bin/sleep 3
			#Lets install Firmware to read APFS
			echo "Lets install Firmware to read APFS" | tee -a $LOG
			/usr/sbin/installer -verbose -pkg /private/var/root/Desktop/FirmwareUpdateStandalone-1.0.pkg -target /Volumes/Macintosh\ HD | tee -a $LOG
			/bin/sleep 2		
			#Display Popup about Rebooting to install Firmware
			/usr/bin/osascript -e'tell app "System Events" to display dialog "This machine will reboot in 20 seconds to install a needed firmware update.  Please allow at least one reboot and then netboot again to image this machine." with title "Reboot Required" giving up after 20'
			/bin/sleep 2
			/sbin/shutdown -r now
		fi
	
	else
		#Drive is already APFS.  Lets trash it
		echo "Drive is already APFS.  Lets trash it." | tee -a $LOG
		newDisk=$(/usr/sbin/diskutil list | awk '/APFS Container Scheme/{print $NF}')
		/bin/sleep 5
		/usr/sbin/diskutil apfs eraseVolume "$newDisk"s1 -name "Macintosh HD" | tee -a $LOG
		/usr/bin/open -a "Jamf Imaging"
		killall "Terminal"
		exit 0
	fi
	
fi



