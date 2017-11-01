#!/bin/sh

#Lets make sure Jamf Imaging is closed

killall "Jamf Imaging"

/bin/sleep 1.5

#Check to see if computer to be imaged is already APFS formatted
apfsCheck=$(/usr/sbin/diskutil list | grep "Apple_APFS")
ssdCheck=$(/usr/sbin/diskutil list disk0 | awk '/Solid State/{print $NF}')

if [[ "$ssdCheck" != "Yes" ]]; then
	echo "Not a SSD Drive"
	/usr/bin/open -a "Jamf Imaging"
	killall "Terminal"
	exit 0
else
	if [[ "$apfsCheck" == "" ]]; then
		#Drive is not APFS
		echo "Drive is not APFS"
		#Lets Create a Container for APFS
		/usr/sbin/diskutil apfs createContainer /dev/disk0s2
		/bin/sleep 1.5
		#lets add a new Volume with name Macintosh HD
		/usr/sbin/diskutil apfs addVolume disk1 APFS "Macintosh HD"
		/bin/sleep 1.5
	fi
	
fi


#Lets relaunch Jamf Imaging

/usr/bin/open -a "Jamf Imaging"

killall "Terminal"

