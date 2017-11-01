#!/bin/sh

#Lets make sure Jamf Imaging is closed

killall "Jamf Imaging"

/bin/sleep 1.5

#Check to see if computer to be imaged is already APFS formatted
apfsCheck=$(/usr/sbin/diskutil list | grep "Apple_APFS")
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
		/usr/sbin/diskutil apfs createContainer /dev/disk0s2
		echo "We are half way there!!"
		/bin/sleep 3
		#lets add a new Volume with name Macintosh HD
		/usr/sbin/diskutil apfs addVolume disk1 APFS "Macintosh HD"
		echo "All done!!  Let me open Jamf Imaging for you...."
		/bin/sleep 3
	fi
	
fi


#Lets relaunch Jamf Imaging

/usr/bin/open -a "Jamf Imaging"

killall "Terminal"

