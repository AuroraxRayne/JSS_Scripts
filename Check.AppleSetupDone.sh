#!/bin/sh

if [ -e /var/db/.AppleSetupDone ]; then
    echo "Setup already ran"
else
    echo "Setup not run. Making file"
    touch /var/db/.AppleSetupDone
fi