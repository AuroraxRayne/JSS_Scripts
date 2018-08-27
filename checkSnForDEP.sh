#!/bin/sh

GetSerialNumber () {
#Get the SN of this device
sn=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
echo "The SN is: $sn"
}

CheckSerialForDEP () {
#Lets curl the SN to get some group info
list=$(curl -k -H "Accept: application/xml" dennisbrowning.me/devices.xml | xpath /computer_group/computers/computer/serial_number)

snList=$(echo $list | sed 's/<serial_number>//g' | sed 's/<\/serial_number>/\'$'\n/g')

if echo $snList | grep -q -w "$sn"; then
	echo "Mac is DEP Enabled"
	/usr/bin/osascript -e'tell app "System Events" to display dialog "This mac is enabled for autoMac Deployment.  Please boot to the recovery partition and wipe/reinstall the OS." with title "autoMac Enabled"'
	/bin/sleep 5
	killall "Terminal"
	exit 0
else
	echo "Mac is not DEP Enabled"
	sh /private/var/root/Desktop/Run_Me_First.command
fi
}