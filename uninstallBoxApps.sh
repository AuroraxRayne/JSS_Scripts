#!/bin/sh

#Getting Logged in Users
loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`





#Lets first kill Box Sync and Box Drive if they are running

if ( pgrep "Box" > /dev/null ); then
    echo "Killing Box"
    killall "Box"
else
    echo "Box is not running"
fi

if ( pgrep "Box Sync" > /dev/null ); then
    echo "Killing Box Sync"
    killall "Box Sync"
else
    echo "Box Sync is not running"
fi


#Lets uninstall Box App
if [[ -f "/Applications/Box.app" ]]; then
	echo "Running Box.app Uninstaller"
	/Library/Application Support/Box/uninstall_box_drive
else
	echo "Box.app is not installed"
fi

#Lets clean up Box Sync files
if [[ -f "/Applications/Box Sync.app" ]]; then
	echo "Removing Box Sync Files"
	rm -rf "/Applications/Box Sync.app"
	rm -rf "/Users/$loggedInUser/Library/Logs/Box/Box Sync/"
	rm -rf "/users/$loggedInUser/Library/Application Support/Box/Box Sync/"
	rm -rf "/Library/PrivilegedHelperTools/com.box.sync.bootstrapper"
	rm -rf "/Library/PrivilegedHelperTools/com.box.sync.iconhelper"
else
	echo "Box Sync is not installed"
fi
