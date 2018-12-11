#!/bin/bash

wifi=`networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/,/Ethernet/' | awk 'NR==2' | cut -d " " -f 2`
ssid=`networksetup -getairportnetwork $wifi | cut -d " " -f 4`

case $ssid in
    GuestWiFi|GuestWiFi|Dealertrack-Guest)
        echo "Removing $ssid from Preferred Wireless list" >> /var/log/jamf.log
        echo "Turning off $wifi" >> /var/log/jamf.log
        networksetup -setairportpower $wifi off
        echo "wifi is equal to $wifi" >> /var/log/jamf.log
        networksetup -removepreferredwirelessnetwork $wifi $ssid
        echo "Turning $wifi back on" >> /var/log/jamf.log
        sleep 1
        networksetup -setairportpower $wifi on
        ;;
esac