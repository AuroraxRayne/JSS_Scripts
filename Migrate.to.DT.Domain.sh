#!/bin/sh

sleep 3
# Unjoin Dealerdotcom.corp Domain
echo "Unjoingin DDC"
dsconfigad -remove -username adjoin -password J0inP@ssWrd

sleep 5

#un=`ls -l /dev/console | cut -d " " -f4`

# Remove Local account
#echo "Deleteing local User but not Home Dir"
#/usr/bin/dscl . -delete /Users/$un

sleep 5

# Join DT.inc Domain
echo "Joining DT Domain"
/usr/local/jamf/bin/jamf policy -trigger VTDTBind

# Check and see if user has CVS
#echo "Checking if CVS exist"
#directory=/cvs

#if [ -d "$directory" ]; then
  #  sudo chown -R $un $directory
#else
   # echo "cvs doesn't exist"
#fi



