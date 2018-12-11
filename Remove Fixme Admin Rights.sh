#!/bin/sh

if groups fixme | grep -q -w admin; then 
    echo "Is an admin.  Lets remove that"
	dseditgroup -o edit -d fixme -t user admin
else 
    echo "Not an admin"
fi