#!/bin/sh

## Outlook
/usr/bin/defaults write /Library/Preferences/com.microsoft.Outlook kSubUIAppCompletedFirstRunSetup1507 -bool true
/usr/bin/defaults write /Library/Preferences/com.microsoft.Outlook FirstRunExperienceCompletedO15 -bool true
/usr/bin/defaults write /Library/Preferences/com.microsoft.Outlook OUIWhatsNewLastShownLink -integer 623900

## Powerpoint
/usr/bin/defaults write /Library/Preferences/com.microsoft.PowerPoint kSubUIAppCompletedFirstRunSetup1507 -bool true
/usr/bin/defaults write /Library/Preferences/com.microsoft.PowerPoint OUIWhatsNewLastShownLink -integer 620749

## Excel
/usr/bin/defaults write /Library/Preferences/com.microsoft.Excel kSubUIAppCompletedFirstRunSetup1507 -bool true

## Word
/usr/bin/defaults write /Library/Preferences/com.microsoft.Word kSubUIAppCompletedFirstRunSetup1507 -bool true

## OneNote
/usr/bin/defaults write /Library/Preferences/com.microsoft.onenote.mac kSubUIAppCompletedFirstRunSetup1507 -bool true

# Location of the lsregister binary
lsregister_bin="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

# Trust the MAU App
echo " - Trusting the MAU app"
$lsregister_bin -R -f -trusted "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app"

# Trust the MAU Daemon app
echo " - Trusting the MAU Daemon app"
$lsregister_bin -R -f -trusted "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/Microsoft AU Daemon.app"


#/usr/local/jamf/bin/jamf policy -trigger officelicense