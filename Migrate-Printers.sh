#!/bin/bash

launchctl unload -w /System/Library/LaunchDaemons/org.cups.cupsd.plist
cp /etc/cups/printers.conf /etc/cups/printers.conf.bak
sed -i '' 's/\/vt1hs1-print01.dealerdotcom.corp\//\/nhpvtprt001.man.co\//g' /etc/cups/printers.conf
sed -i '' 's/\/10.128.9.37\//\/nhpvtprt001.man.co\//g' /etc/cups/printers.conf
launchctl load -w /System/Library/LaunchDaemons/org.cups.cupsd.plist