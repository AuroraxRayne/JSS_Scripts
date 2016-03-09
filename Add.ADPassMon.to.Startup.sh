#!/bin/sh

cat > /Library/LaunchAgents/com.ADPassMon.plist << EOT
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>KeepAlive</key>
	<true/>
	<key>Label</key>
    <string>com.ADPassMon.agent</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Applications/ADPassMon.app/Contents/MacOS/ADPassMon</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOT

sleep 2

launchctl load /Library/LaunchAgents/com.ADPassMon.plist
sleep 10

open /Applications/ADPassMon.app