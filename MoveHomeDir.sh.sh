#!/bin/sh

touch /tmp/sync_log.log
status="/tmp/sync_log.log"

systemsetup -setcomputersleep Never

sleep 2

user="$(/usr/bin/osascript -e 'Tell application "System Events" to display dialog "Please enter username to move:" default answer "" with title "Username" with text buttons {"Ok"} default button 1' -e 'text returned of result')"

sleep 2

open /tmp/sync_log.log

sleep 2

rm -fRv /Volumes/Macintosh\ HD\ 1/Users/$user/Documents/Microsoft\ User\ Data/Office\ 2011\ Identities/ | tee -a $status

sleep 2

rm -fRv /Volumes/Macintosh\ HD\ 1/Users/$user/Library/Group\ Containers/UBF8T346G9.* | tee -a $status

sleep 2

mv /Volumes/Macintosh\ HD\ 1/Users/$user/Google\ Drive/ /Volumes/Macintosh\ HD\ 1/Users/Shared/GDrive/| tee -a $status

sleep 2

rm -fRv /Volumes/Macintosh\ HD\ 1/Users/$user/Library/Application\ Support/Google\ Drive | tee -a $status

sleep 2

rm -fRv /Volumes/Macintosh\ HD\ 1/Users/$user/.Trash | tee -a $status

sleep 2

rsync -aEv --progress --stats /Volumes/Macintosh\ HD\ 1/Users/$user/ /Users/$user/ | tee -a $status

sleep 2

chown -R $user /Users/$user/ | tee -a $status

sleep 2

systemsetup -setcomputersleep 120 | tee -a $status

sleep 2

killall Console

exit 0

