#!/bin/sh

if [[ "$4" != "" ]]; then
version="$4"
fi

#Resetting Ignore List
echo "Resetting Ignore List"
/usr/sbin/softwareupdate --reset-ignore

/bin/sleep 5

#Add new version to list
echo "Adding New Version to Ignore List"
/usr/sbin/softwareupdate --ignore "Xcode $version"