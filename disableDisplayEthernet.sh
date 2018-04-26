#!/bin/bash

services=$(networksetup -listnetworkserviceorder | grep 'Hardware Port: Display Ethernet')

while read line; do
    sname=$(echo $line | awk -F  "(, )|(: )|[)]" '{print $2}')
    sdev=$(echo $line | awk -F  "(, )|(: )|[)]" '{print $4}')
    #echo $sname
    echo "sdev: $sdev"
    ifconfig $sdev down
done <<< "$(echo "$services")"