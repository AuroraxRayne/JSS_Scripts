#!/bin/sh

#Get Logged in User
un=`ls -l /dev/console | cut -d " " -f4`
un2=`defaults read /Library/Preferences/com.apple.loginwindow lastUserName`

echo "first call is $un and second call is $un2"

if [[ ${un} =~ "admin" ]] || [[ ${un} == "root" ]]; then
    unrecon=""
    echo "Running recon with Blank Username"
    /usr/local/jamf/bin/jamf recon -endUsername $unrecon
else
    echo "Running recon as $un"
    /usr/local/jamf/bin/jamf recon -endUsername $un
fi

