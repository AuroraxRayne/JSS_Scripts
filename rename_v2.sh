#!/bin/sh

nameCode=`/bin/launchctl asuser 0 /usr/bin/osascript <<EOT
set office to {"Main Campus Atlanta", "Summit Campus Atlanta", "Burlington", "North Hills", "Dallas", "vAuto Austin", "Groton", "Mississauga", "South Jordan", "HomeNet", "Vin Solutions", "NextGear Capital", "Ready Logistics", "KBB Irvine", "xTime", "Other"}

set choice to (choose from list office with prompt "Please select the Office that best describes your location")
set city to the result
set code to city as text

if (code = "Main Campus Atlanta") then
	set nameCode to "MAN"
else if (code = "Summit Campus Atlanta") then
	set nameCode to "ATL"
else if (code = "Burlington") then
	set nameCode to "BUR"
else if (code = "North Hills") then
	set nameCode to "NHP"
else if (code = "Dallas") then
	set nameCode to "DAL"
else if (code = "vAuto Austin") then
	set nameCode to "VAT"
else if (code = "Groton") then
	set nameCode to "GRO"
else if (code = "Mississauga") then
	set nameCode to "MIS"
else if (code = "South Jordan") then
	set nameCode to "SLC"
else if (code = "HomeNet") then
	set nameCode to "HMN"
else if (code = "Vin Solutions") then
	set nameCode to "VIN"
else if (code = "NextGear Capital") then
	set nameCode to "NGC"
else if (code = "Ready Logistics") then
	set nameCode to "RDL"
else if (code = "KBB Irvine") then
	set nameCode to "KBB"
else if (code = "xTime") then
	set nameCode to "RWC"
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

if [[ "$nameCode" == "VAT" ]]; then
	echo "Prompting for Computer Name"
	computerName="$(/usr/bin/osascript -e 'display dialog "Please enter Computer Name:" default answer "VAA-USERNAME-LT1" with title "Computer Name" giving up after 86400 with text buttons {"OK"} default button 1 ' -e 'return text returned of result')"
else
	echo "Use standard naming convention"
	computerName=$modelCode$nameCode$os$sn
fi
	echo "computerName has been set to: $computerName"

#networksetup -setcomputername $computerName
#scutil --set LocalHostName $computerName
#scutil --set HostName $computerName
#sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName $computerName