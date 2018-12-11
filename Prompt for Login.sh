#!/bin/bash

userName="$(/usr/bin/osascript -e 'with timeout of 600 seconds' -e 'Tell application "System Events" to display dialog "Please enter your login Username:" default answer "" with title "Login Username" with text buttons {"Ok"} default button 1' -e 'end timeout' -e 'text returned of result')"


## Get the OS version
OS=`/usr/bin/sw_vers -productVersion | awk -F. {'print $2'}`

userPass="$(/usr/bin/osascript -e 'with timeout of 600 seconds' -e 'Tell application "System Events" to display dialog "Please enter your login password:" default answer "" with title "Login Password" with text buttons {"Ok"} default button 1 with hidden answer' -e 'end timeout' -e 'text returned of result')"

echo “Logging in as {${userName}}”

if [[ $OS -ge 9  ]]; then
	expect -c "
	log_user 0
	spawn login {${userName}}
	expect "\"Password:"\"
	send "{${userPass}}"
	send \r
	log_user 1
	expect eof
	"
	/bin/pwd
else
	echo "OS version not 10.9+ or OS version unrecognized"
	echo "$(/usr/bin/sw_vers -productVersion)"
	exit 5
fi