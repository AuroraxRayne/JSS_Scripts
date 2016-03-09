#!/bin/sh

echo "adding ssh user"
dseditgroup -o edit -t user -a ddcdennisb com.apple.access_ssh

sleep 2

dseditgroup -o edit -t user -a admin com.apple.access_ssh

sleep 2

dseditgroup -o edit -t user -a administrator com.apple.access_ssh

sleep 2

dseditgroup -o edit -t user -a ddcdennisb admin

exit 0