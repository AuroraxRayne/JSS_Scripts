#!/bin/sh

#Get Logged in User
un=`ls -l /dev/console | cut -d " " -f4`

echo "Running recon for $un"

sleep 2

/usr/local/jamf/bin/jamf recon -endUsername $un