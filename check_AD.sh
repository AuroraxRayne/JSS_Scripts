#!/bin/sh

#check to be sure computer is bound to AD
domainCheck=$(dsconfigad -show | awk '/Active Directory Domain/{print $NF}')

runCheck ()
{
#Setting Variables to compare later on
mobileEnabled=$(dsconfigad -show | awk '/Create mobile account at login/{print $NF}')

echo "Create mobile account is: $mobileEnabled"

confirmationEnabled=$(dsconfigad -show | awk '/Require confirmation/{print $NF}')

echo "Require confirmation is: $confirmationEnabled"

#Check to see if Create mobile account at login is enabled.  If so, exit out.  If not, set it to enable and disable confirmation
if [[ ${mobileEnabled} == Enabled ]]; then
	echo "Mobile account enabled"
	exit 0
else
	echo "Lets fix the mobile account settings"
	/usr/sbin/dsconfigad -mobile enable -mobileconfirm disable
fi

#Recheck to confirm new settings are set
mobileEnabledCheck=$(dsconfigad -show | awk '/Create mobile account at login/{print $NF}')

echo "Checking Create mobile account is: $mobileEnabledCheck"

confirmationEnabledCheck=$(dsconfigad -show | awk '/Require confirmation/{print $NF}')

echo "Checking Require confirmation is: $confirmationEnabledCheck"
}


if [[ ${domainCheck} == man.co ]]; then
	echo "Sweet this computer is joined to man.co"
	runCheck
	exit 0
else
    echo "Computer is not joined"
	/usr/local/bin/jamf policy -trigger joinmanco
    runCheck
fi