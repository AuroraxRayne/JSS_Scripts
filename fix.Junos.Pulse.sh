#!/bin/bash
# stop pulse access service
# remove local guid from connstore.dat
# restart service
sudo launchctl unload /Library/LaunchDaemons/net.juniper.AccessService.plist
sudo rm -rf /Library/Application\ Support/Juniper\ Networks/Junos\ Pulse/DeviceID
sudo sed -i .bak "/guid/d" /Library/Application\ Support/Juniper\ Networks/Junos\ Pulse/connstore.dat
sudo launchctl load /Library/LaunchDaemons/net.juniper.AccessService.plist