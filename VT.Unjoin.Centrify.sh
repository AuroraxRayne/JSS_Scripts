#!/bin/sh

#Copy over silent uninstall for centrify from LDMS and change premissions
/usr/bin/curl -o /tmp/uninstall.sh http://vt1hs1-ldms01.dealerdotcom.corp/appdeploy/scripts/centrify-remove/uninstall.sh
/bin/chmod a+x /tmp/uninstall.sh

sleep 1

#Unjoin Domain
/usr/sbin/adleave -u adjoin -p J0inP@ssWrd -r

sleep 15

#Call Casper Policy to join Domain
/usr/local/jamf/bin/jamf policy -trigger VTADBind

sleep 5

#Run Script to uninstall Centrify silently and clean up the files.
/tmp/uninstall.sh
/bin/rm -f /tmp/uninstall.sh


#Fix printer Mappings from CDCSMB to SMB
/usr/local/jamf/bin/jamf policy -trigger fixprinters

sleep 2

/usr/local/jamf/bin/jamf recon
