#!/bin/sh

/usr/local/jamf/bin/jamf removeMdmProfile -verbose

sleep 2

/usr/local/jamf/bin/jamf manage -verbose

sleep 2