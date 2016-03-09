#!/bin/sh

sleep 3
# Unjoin existing Domain
echo "Unjoining Domain"
dsconfigad -remove -username UNAME -password PASSWORD

sleep 5

#un=`ls -l /dev/console | cut -d " " -f4`

# Remove Local account
#echo "Deleteing local User but not Home Dir"
#/usr/bin/dscl . -delete /Users/$un

sleep 5

# Join New Domain
echo "Joining New Domain"
/usr/local/jamf/bin/jamf policy -trigger ADBIND_Policy




