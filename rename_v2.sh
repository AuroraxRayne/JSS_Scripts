#!/bin/sh

osascript <<EOT

set locations to {"Main Campus Atlanta", "Summit Campus Atlanta", "Burlington", "North Hills", "Dallas", "Austin", "Groton", "Mississauga", "South Jordan", "HomeNet", "Vin Solutions", "NextGear Capital", "Ready Logistics", "KBB Irvine", "xTime", "Other"}

set choice to (choose from list locations with prompt "Please select the Office that best describes your location")
set city to the result
set code to city as text

if (code = "Main Campus Atlanta") then
	set nameCode to "man"
else if (code = "Summit Campus Atlanta") then
	set nameCode to "atl"
else if (code = "Burlington") then
	set nameCode to "bur"
else if (code = "North Hills") then
	set nameCode to "nhp"
else if (code = "Dallas") then
	set nameCode to "dal"
else if (code = "Austin") then
	set nameCode to "vat"
else if (code = "Groton") then
	set nameCode to "gro"
else if (code = "Mississauga") then
	set nameCode to "mis"
else if (code = "South Jordan") then
	set nameCode to "slc"
else if (code = "HomeNet") then
	set nameCode to "hmn"
else if (code = "Vin Solutions") then
	set nameCode to "vin"
else if (code = "NextGear Capital") then
	set nameCode to "ngc"
else if (code = "Ready Logistics") then
	set nameCode to "rdl"
else if (code = "KBB Irvine") then
	set nameCode to "kbb"
else if (code = "xTime") then
	set nameCode to "rwc"
else
	set nameCode to "cai"
end if


set sn to (do shell script ("system_profiler SPHardwareDataType | awk '/Serial/ {print $4}' | cut -c 5-"))
set model to (do shell script ("system_profiler SPHardwareDataType | awk '/Model Name/ {print $3}'"))
if (model = "MacBook") then
	set modelCode to "L"
else
	set modelCode to "W"
end if

set computerName to modelCode & nameCode & "MAC" & sn

do shell script "networksetup -setcomputername " & computerName
do shell script "scutil --set LocalHostName " & computerName
do shell script "scutil --set HostName " & computerName
do shell script "defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName " & computerName 
EOT