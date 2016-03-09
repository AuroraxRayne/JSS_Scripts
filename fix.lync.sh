#!/bin/bash

#gets user name as variable
user=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'` 

#closes microsoft lync
killall "Microsoft Lync" 

#pauses for 10 secs
sleep 10

#cache cleanup
rm -r /Users/$user/Library/Caches/*
#application state cleanup
rm -r /Users/$user/Library/Saved\ Application\ State/com.microsoft.Lync.savedState/
#plist cleanup
rm -r /Users/$user/Library/Preferences/Byhost/MicrosoftLyncRegistrationDB.*
rm -r /Users/$user/Library/Preferences/com.microsoft.Lync.plist
#microsoft identity cleanup
rm -r /Users/$user/Documents/Microsoft\ User\ Data/Microsoft\ Lync\ Data 
rm -r /Users/$user/Documents/Microsoft\ User\ Data/Microsoft\ Lync\ History

sleep 10

open -a "Microsoft Lync"