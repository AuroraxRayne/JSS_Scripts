#!/bin/sh

nameCode=`/bin/launchctl asuser 0 /usr/bin/osascript <<EOT
set office to {"CA-ON-Mississauga", "US-AZ-Phoenix", "US-CA-Irvine", "US-CA-Redwood City","US-CA-Sacramento", "US-CT-Groton", "US-GA-Atlanta", "US-IN-Carmel", "US-KS-Kansas City", "US-NY-North Hills", "US-PA-Exton", "US-TX-Austin", "US-TX-Dallas", "US-UT-South Jordan", "US-VT-Burlington", "Loaner", "Other"}

set choice to (choose from list office with prompt "Please select the City that best describes your location")
set city to the result
set code to city as text

if (code = "US-GA-Atlanta") then
	set nameCode to "ATL"
else if (code = "US-VT-Burlington") then
	set nameCode to "BUR"
else if (code = "US-NY-North Hills") then
	set nameCode to "NHP"
else if (code = "US-TX-Dallas") then
	set nameCode to "DAL"
else if (code = "US-TX-Austin") then
	set nameCode to "VAA"
else if (code = "US-CT-Groton") then
	set nameCode to "GRO"
else if (code = "CA-ON-Mississauga") then
	set nameCode to "MIS"
else if (code = "US-UT-South Jordan") then
	set nameCode to "SLC"
else if (code = "US-CA-Sacramento") then
	set nameCode to "SAC"
else if (code = "US-PA-Exton") then
	set nameCode to "HMN"
else if (code = "US-KS-Kansas City") then
	set nameCode to "VIN"
else if (code = "US-IN-Carmel") then
	set nameCode to "NGC"
else if (code = "US-AZ-Phoenix") then
	set nameCode to "RDL"
else if (code = "US-CA-Irvine") then
	set nameCode to "KBB"
else if (code = "US-CA-Redwood City") then
	set nameCode to "RWC"
else if (code = "Loaner") then
	set nameCode to "Loaner"
else
	set nameCode to "CAI"
end if
EOT`

sn=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}' | cut -c 5-)
model=$(system_profiler SPHardwareDataType | awk '/Model Name/ {print $3}')

if [[ $model == "MacBook" ]]; then
	modelCode="L"
else
	modelCode="W"
fi
os="mac"

if [[ "$nameCode" == "VAA" ]] || [[ "$nameCode" == "Loaner" ]]; then
	echo "Prompting for Computer Name"
	computerName="$(/bin/launchctl asuser 0 /usr/bin/osascript -e 'display dialog "Please enter Computer Name:" default answer "VAA-USERNAME-LT1 or lBURmacLoaner01" with title "Computer Name" giving up after 86400 with text buttons {"OK"} default button 1 ' -e 'return text returned of result')"
else
	echo "Use standard naming convention"
	computerName=$modelCode$nameCode$os$sn
fi
	echo "computerName has been set to: $computerName"

networksetup -setcomputername $computerName
scutil --set LocalHostName $computerName
scutil --set HostName $computerName
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName $computerName