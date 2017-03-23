#!/bin/sh

#Setting Variables to compare later on
mobileEnabled=$(dsconfigad -show | grep "Create mobile" | awk '{print $7}')

echo "Create mobile account is: $mobileEnabled"

confirmationEnabled=$(dsconfigad -show | grep "Require" | awk '{print $4}')

echo "Require confirmation is: $confirmationEnabled"


#Check to see if Create mobile account at login is enabled.  If so, exit out.  If not, set it to enable and disable confirmation
if [[ $mobileEnabled == "Enabled" ]]; then
	echo "Mobile account enabled"
	exit 0
else
	echo "Lets fix the mobile account settings"
	/usr/sbin/dsconfigad -mobile enable -mobileconfirm disable
fi

#Recheck to confirm new settings are set
mobileEnabledCheck=$(dsconfigad -show | grep "Create mobile" | awk '{print $7}')

echo "Checking Create mobile account is: $mobileEnabledCheck"

confirmationEnabledCheck=$(dsconfigad -show | grep "Require" | awk '{print $4}')

echo "Checking Require confirmation is: $confirmationEnabledCheck"