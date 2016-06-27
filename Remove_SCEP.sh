#!/bin/sh


#Kill all processes starting with SCEP
pkill scep*

sleep 10

#Remove Application
rm -rf "/Applications/System Center 2012 Endpoint Protection.app"
