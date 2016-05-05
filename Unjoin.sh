#!/bin/sh

dsconfigad -force -remove -u UNAME -p PASSWORD

echo "first check after bind"
domain=$(dsconfigad -show | grep 'Active Directory Domain')

echo "results of first check $domain"

sleep 3

if [[ ${domain} == '' ]]; then
	echo "Sweet you are off DT.inc You are all set"
	sleep 2
prompt1=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "Disjoin Complete" -description "The disjoin from DT.INC has completed successfully." -button1 "OK"`
    	
else
	prompt3=`/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType utility -icon /System/Library/CoreServices/Installer.app/Contents/Resources/Installer.icns -heading "Disjoin Failed" -description "The disjoin form DT.INC has failed. Please run the disjoin manually.  If you continue to have issues reach out to Dennis Browning." -button1 "OK"`

fi
