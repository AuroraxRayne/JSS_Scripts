#!/bin/bash

launchctl unload -w /System/Library/LaunchDaemons/org.cups.cupsd.plist
cp /etc/cups/printers.conf /etc/cups/printers.conf.bak
sed -i '' 's/\/printers.dealerdotcom.corp\//\/vt1hs1-print01.dealerdotcom.corp\//g' /etc/cups/printers.conf
sed -i '' 's/\/dc2.dealerdotcom.corp\//\/vt1hs1-print01.dealerdotcom.corp\//g' /etc/cups/printers.conf
sed -i '' 's/\/printers\//\/vt1hs1-print01.dealerdotcom.corp\//g' /etc/cups/printers.conf
sed -i '' 's/\/dc2\//\/vt1hs1-print01.dealerdotcom.corp\//g' /etc/cups/printers.conf
sed -i '' 's/\/10.128.9.13\//\/vt1hs1-print01.dealerdotcom.corp\//g' /etc/cups/printers.conf
sed -i '' 's/\/nj1ts1-print01.dealerdotcom.corp\//\/Test.to.see.if.this.works\//g' /etc/cups/printers.conf
launchctl load -w /System/Library/LaunchDaemons/org.cups.cupsd.plist
