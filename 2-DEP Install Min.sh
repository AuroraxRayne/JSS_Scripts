#!/bin/sh

/bin/mkdir /usr/local/jamfps

/bin/echo "#!/bin/bash
## First Run Script to Open Self Service.
open -a \"Self Service\"
/bin/sleep 2
open -a \"Enterprise Connect\"
/bin/sleep 2
##UnLoad and disable LaunchAgent
/bin/launchctl unload -w /Library/LaunchAgents/com.jamfps.runSelfService.plist
exit 0" > /usr/local/jamfps/runSelfService.sh

/usr/sbin/chown root:admin /usr/local/jamfps/runSelfService.sh
/bin/chmod 755 /usr/local/jamfps/runSelfService.sh

echo $(ls -hal /usr/local/jamfps)
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# LAUNCH DAEMON
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
cat << EOF > /Library/LaunchAgents/com.jamfps.runSelfService.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.jamfps.runSelfService</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/sh</string>
        <string>/usr/local/jamfps/runSelfService.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

##Set the permission on the file just made.
/usr/sbin/chown root:wheel /Library/LaunchAgents/com.jamfps.runSelfService.plist
/bin/chmod 644 /Library/LaunchAgents/com.jamfps.runSelfService.plist