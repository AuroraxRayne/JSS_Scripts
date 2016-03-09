#!/bin/sh

# Create user record in directory services
dscl . -create /Users/fixme
dscl . -create /Users/fixme RealName "Fix Me"
dscl . -create /Users/fixme UniqueID 404  # Use something between 100 and 500 to hide the user
dscl . -create /Users/fixme PrimaryGroupID 20
dscl . -create /Users/fixme UserShell /bin/bash
dscl . -passwd /Users/fixme "fixme"  # Obviously, use something else here

# Set up a hidden home folder
dscl . -create /Users/fixme NFSHomeDirectory /var/fixme  # or other hidden location
cp -R /System/Library/User\ Template/English.lproj /var/fixme
chown -R fixme:staff /var/fixme

# Grant admin & ARD rights
#dseditgroup -o edit -t user -a fixme admin
