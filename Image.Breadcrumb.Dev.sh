#!/bin/bash

plistName="com.dtinccasper.image" # Name of the plist - ex: com.company.image.plist

plistPath="/Library/Preferences" # Path to store the plist (default is /Library/Preferences)

currentDate=`date +"%Y-%m-%d %H:%M:%S"`

Buildid="DEV"

buildv="2015.12b"

method="Casper"

defaults write $plistPath/$plistName date "$currentDate"

sleep 2

defaults write $plistPath/$plistName buildId "$Buildid"

sleep 2 

defaults write $plistPath/$plistName deploymentMethod "$method"

sleep 2 

defaults write $plistPath/$plistName buildVersion "$buildv"

exit 0