#!/bin/sh
sn=""


GetSerialNumber () {
#Get the SN of this device
sn=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
echo "The SN is: $sn"
}

PromptForSerialNumber () {
	#Popup input window for Serial Number
	sn=$(/usr/bin/osascript <<EOT
tell application "System Events"
    activate
    with timeout of 600 seconds
        set sn to text returned of (display dialog "Please enter Serial Number you would like to check:" default answer "")
    end timeout
end tell
EOT)
echo "The SN is: $sn"
}

CheckSerialForDEP () {
#Lets curl the SN to get some group info
list=$(curl -k -H "Accept: application/xml" dennisbrowning.me/devices.xml | xpath /computer_group/computers/computer/serial_number)

#check if SN is blank.  If so exit.

if [[ "$sn" == "" ]]; then
	echo "SN is blank.  Exiting."
	exit 1
fi

snList=$(echo $list | sed 's/<serial_number>//g' | sed 's/<\/serial_number>/\'$'\n/g')

if echo $snList | grep -q -w "$sn"; then
	echo "Mac is DEP Enabled"
	/usr/bin/osascript -e 'tell app "System Events" to display dialog "Serial Number: '$sn'
This mac is enabled for autoMac Deployment. :-)
	
	Let me craft an email to Dennis for you!"'
    #open "mailto:Dennis.Browning@coxautoinc.com?subject=Please%20add%20to%20Pre-Stage&body=SN%3A$sn"
	osascript -e 'tell app "Microsoft Outlook"' -e 'set newMessage to make new outgoing message with properties {subject:"Please add to Pre-stage"}' -e 'make new recipient at newMessage with properties {email address:{name:"Dennis Browning", address:"dennis.browning@coxautoinc.com"}}' -e 'set content of newMessage to "Please add the following Serial Number to the pre-starge for autoMac.  Thanks!  SN: '$sn'"' -e 'open newMessage' -e 'end tell'
	exit 0
else
	echo "Mac is not DEP Enabled"
	/usr/bin/osascript -e 'tell app "System Events" to display dialog "Serial Number: '$sn'
    This mac is NOT enabled for autoMac Deployment. :-("'
	exit 0
fi
exit 0
}

#Running the Main Process

#Ask if running from local machine or orther machine
HELPER=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -heading "autoMac Assistant" -description "Are you running this from the mac you are checking autoMac eligibility or a different mac?" -button1 "This mac" -button2 "Enter SN" -defaultButton "2" -alignDescription justified`


        echo "jamf helper result was $HELPER";

        if [ "$HELPER" == "0" ]; then
            echo "Run SN Find"
			GetSerialNumber
			CheckSerialForDEP
            sleep 2
            exit 0
        else
            echo "Pass Popup Window"
			PromptForSerialNumber
			CheckSerialForDEP
            sleep 2
            exit 0
        fi
exit 0
        
#!/bin/sh

GetSerialNumber () {
#Get the SN of this device
sn=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
echo "The SN is: $sn"
}

PromptForSerialNumber () {
	#Popup input window for Serial Number
	sn=$(/usr/bin/osascript <<EOT
tell application "System Events"
    activate
    with timeout of 600 seconds
        set sn to text returned of (display dialog "Please enter Serial Number you would like to check:" default answer "")
    end timeout
end tell
EOT)
echo "The SN is: $sn"
}

CheckSerialForDEP () {
#Lets curl the SN to get some group info
list=$(curl -k -H "Accept: application/xml" dennisbrowning.me/devices.xml | xpath /computer_group/computers/computer/serial_number)

#check if SN is blank.  If so exit.

if [[ "$sn" == "" ]]; then
	echo "SN is blank.  Exiting."
	exit 1
fi

snList=$(echo $list | sed 's/<serial_number>//g' | sed 's/<\/serial_number>/\'$'\n/g')

if echo $snList | grep -q -w "$sn"; then
	echo "Mac is DEP Enabled"
	/usr/bin/osascript -e 'tell app "System Events" to display dialog "This mac is enabled for autoMac Deployment. :-)"'
	exit 0
else
	echo "Mac is not DEP Enabled"
	/usr/bin/osascript -e 'tell app "System Events" to display dialog "This mac is NOT enabled for autoMac Deployment. :-("'
	exit 0
fi
exit 0
}

#Running the Main Process

#Ask if running from local machine or orther machine
HELPER=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -heading "autoMac Assistant" -description "Are you running this from the mac you are checking autoMac eligibility or a different mac?" -button1 "This mac" -button2 "Enter SN" -defaultButton "2" -alignDescription justified`


        echo "jamf helper result was $HELPER";

        if [ "$HELPER" == "0" ]; then
            echo "Run SN Find"
			GetSerialNumber
			CheckSerialForDEP
            sleep 2
            exit 0
        else
            echo "Pass Popup Window"
			PromptForSerialNumber
			CheckSerialForDEP
            sleep 2
            exit 0
        fi
exit 0
        