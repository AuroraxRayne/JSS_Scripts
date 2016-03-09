#!/bin/sh

#Adding Search domains for each default interface
if networksetup -listallnetworkservices | grep -q -E "Wi-Fi"; then
    echo 'Wi-Fi found'
    /usr/sbin/networksetup -setsearchdomains "Wi-Fi" dealerdotcom.corp dealer.ddc dt.inc dealertrack.com hq.dt.inc int.dealer.com
    sleep 1
else
    sleep 1
fi

if networksetup -listallnetworkservices | grep -q -E "Thunderbolt Ethernet"; then
    echo 'Thunderbolt Ethernet found'
    /usr/sbin/networksetup -setsearchdomains "Thunderbolt Ethernet" dealerdotcom.corp dealer.ddc dt.inc dealertrack.com hq.dt.inc int.dealer.com
    sleep 1
else
    sleep 1
fi

if networksetup -listallnetworkservices | grep -q -E "Display Ethernet"; then
    echo 'Display Ethernet found'
    /usr/sbin/networksetup -setsearchdomains "Display Ethernet" dealerdotcom.corp dealer.ddc dt.inc dealertrack.com hq.dt.inc int.dealer.com
    sleep 1
else
    sleep 1
fi

if networksetup -listallnetworkservices | grep -q -E "USB Ethernet"; then
    echo 'USB Ethernet found'
    /usr/sbin/networksetup -setsearchdomains "USB Ethernet" dealerdotcom.corp dealer.ddc dt.inc dealertrack.com hq.dt.inc int.dealer.com
    sleep 1
else
    sleep 1
fi