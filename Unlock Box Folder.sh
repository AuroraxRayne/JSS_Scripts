#!/bin/sh

loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`


if [ -d "/Users/$loggedInUser/Box Sync" ]; then
	echo "Box Folder exist"
	/usr/bin/chflags -Rv noschg "/Users/$loggedInUser/Box Sync"
    exit 0
else
	echo "Folder doesn't exist"
	exit 0
fi