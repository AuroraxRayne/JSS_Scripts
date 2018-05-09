#!/bin/sh

nameCode=`/usr/bin/osascript <<EOT

set locations to {"Main Campus Atlanta", "Summit Campus Atlanta", "Burlington", "North Hills", "Dallas", "Austin", "Groton", "Mississauga", "South Jordan", "HomeNet", "Vin Solutions", "NextGear Capital", "Ready Logistics", "KBB Irvine", "xTime", "Other"}

set choice to (choose from list locations with prompt "Please select the Office that best describes your location")
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
else if (code = "Austin") then
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

if [[ model == "MacBook" ]]; then
	modelCode="L"
else
	modelCode="W"
fi
os="mac"

computerName=$modelCode$nameCode$os$sn

networksetup -setcomputername $computerName
scutil --set LocalHostName $computerName
scutil --set HostName $computerName
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName $computerName