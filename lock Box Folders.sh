#!/bin/sh

#Get logged in user
loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

#Recursivly lock all files and folders in Box Sync Folder
/usr/bin/chflags -Rv schg "/Users/$loggedInUser/Box Sync"
