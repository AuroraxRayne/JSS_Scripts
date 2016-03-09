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

# HARDCODED VALUES ARE SET HERE
autoProxyURL="http://pac.dt.inc:8080/accelerated_pac_base.pac"

# CHECK TO SEE IF A VALUE WAS PASSED FOR $4, AND IF SO, ASSIGN IT

	autoProxyURL="http://pac.dt.inc:8080/accelerated_pac_base.pac"

# Detects all network hardware & creates services for all installed network hardware
/usr/sbin/networksetup -detectnewhardware

IFS=$'\n'

	#Loops through the list of network services
	for i in $(networksetup -listallnetworkservices | tail +2 );
	do
	
		# Get a list of all services beginning 'Ether' 'Air' or 'VPN' or 'Wi-Fi'
		# If your service names are different to the below, you'll need to change the criteria
		if [[ "$i" =~ 'Ether' ]] || [[ "$i" =~ 'Display' ]] || [[ "$i" =~ 'Thunderbolt' ]] || [[ "$i" =~ 'Wi-Fi' ]] ; then
			autoProxyURLLocal=`/usr/sbin/networksetup -getautoproxyurl "$i" | head -1 | cut -c 6-`
		
			# Echo's the name of any matching services & the autoproxyURL's set
			echo "$i Proxy set to $autoProxyURLLocal"
		
			# If the value returned of $autoProxyURLLocal does not match the value of $autoProxyURL for the interface $i, change it.
			if [[ $autoProxyURLLocal != $autoProxyURL ]]; then
				/usr/sbin/networksetup -setautoproxyurl $i $autoProxyURL
				echo "Set auto proxy for $i to $autoProxyURL"
			fi
		fi
		
		# Enable auto proxy once set
		/usr/sbin/networksetup -setautoproxystate "$i" on
		echo "Turned on auto proxy for $i" 
	
	done

unset IFS

# Echo that we're done
echo "Auto proxy present, correct & enabled for all targeted interfaces"