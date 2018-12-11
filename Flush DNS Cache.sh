#!/bin/sh

dscacheutil -flushcache

sleep 3

killall -HUP mDNSResponder

