#!/bin/sh
####################################################################################################
#
# More information: https://macmule.com/2014/12/07/how-to-change-the-automatic-proxy-configuration-url-in-system-preferences-via-a-script/
#
# GitRepo: https://github.com/macmule/setAutomaticProxyConfigurationURL
#
# License: http://macmule.com/license/
#
####################################################################################################

# Detects all network hardware & creates services for all installed network hardware
/usr/sbin/networksetup -detectnewhardware

IFS=$'\n'

#Loops through the list of network services
for i in $(/usr/sbin/networksetup -listallnetworkservices | tail +2 ); 

	do	
		
		# Turn off auto proxy
		/usr/sbin/networksetup -setautoproxystate "$i" off
		echo "Turned off auto proxy for interface $i"
	
	done

unset IFS

echo "Auto proxy for all interfaces turned off"