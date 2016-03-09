#!/bin/sh

/usr/sbin/chown -R root:wheel /usr/local/jamf/

sleep 2

/usr/sbin/chown -R root:wheel /usr/local/bin/jamf

sleep 2

/usr/sbin/chown -R root:wheel /usr/local/bin/jamfAgent