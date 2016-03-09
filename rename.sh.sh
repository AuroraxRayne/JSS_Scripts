#!/bin/sh

model=`/usr/bin/osascript <<EOT
tell application "System Events"
    activate
    set model to text returned of (display dialog "Please type 'L' for laptop or 'W' for Desktop" default answer "" with icon 2)
end tell
EOT`

office=`/usr/bin/osascript <<EOT
tell application "System Events"
    activate
    set office to text returned of (display dialog "Please type 3 letter Location Code BUR, DAL, NHP, etc" default answer "" with icon 2)
end tell
EOT`


OS=Mac

sn=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
newsn=$(echo "${sn:4}")


name=$model$office$OS$newsn

echo $name

networksetup -setcomputername $name 
scutil --set LocalHostName $name
scutil --set HostName $name
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName $name