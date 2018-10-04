#!/bin/sh

#Create Function to run Setup
function runDEPSetup () {
    
/usr/local/bin/jamf flushPolicyHistory
sleep 5
open -a /Library/Application\ Support/CAI/CAI\ DEP\ Enrollment\ Min.app
sleep 5
#Computer Rename
echo "running Computer Rename"
/usr/local/bin/jamf policy -trigger depComputerRename
#Finder Prefs
/usr/local/bin/jamf policy -trigger depinstallFinder
#globalprefs
/usr/local/bin/jamf policy -trigger depinstallGlobal
#Menubar
/usr/local/bin/jamf policy -trigger depinstallMenu
#Screen Saver
/usr/local/bin/jamf policy -trigger depinstallScreenSaver
#sidebar
/usr/local/bin/jamf policy -trigger depinstallSidebar
#Update Window
/usr/local/bin/jamf policy -trigger depinstallUpdateWindow
#Chrome
/usr/local/bin/jamf policy -trigger depinstallGoogleChrome
#Slack
/usr/local/bin/jamf policy -trigger depinstallSlack
#Office
/usr/local/bin/jamf policy -trigger depinstallOffice2016
#MS Teams
/usr/local/bin/jamf policy -trigger "depinstallMicrosoft Teams"
#Pulse
/usr/local/bin/jamf policy -trigger depinstallPulse
#SEP
/usr/local/bin/jamf policy -trigger depinstallSEP
#SFB
/usr/local/bin/jamf policy -trigger "depinstallSkype For Business"
#Casper Check
/usr/local/bin/jamf policy -trigger depinstallCasperCheck
#coxPictures
/usr/local/bin/jamf policy -trigger depinstallCoxPics
#Policy Banner
/usr/local/bin/jamf policy -trigger depinstallPolicyBanner
#Outlook Default
/usr/local/bin/jamf policy -trigger depinstallOutlookDefault
#Fixme Account
/usr/local/bin/jamf policy -trigger depinstallFixme
#Administrator
/usr/local/bin/jamf policy -trigger depinstallAdmins
#Base Bread Crumb
/usr/local/bin/jamf policy -trigger depinstallBase
#Build Bread Crumb
/usr/local/bin/jamf policy -trigger depinstallDEP
#Office Whats new
/usr/local/bin/jamf policy -trigger depinstallWhatsnew
#Dock
/usr/local/bin/jamf policy -trigger depinstallDockmin
#Enterprise Connect
/usr/local/bin/jamf policy -trigger depenterpriseConnect
#CAI System Info Tool
/usr/local/bin/jamf policy -trigger depInstallSysInfo
sleep 2
touch /Library/Application\ Support/CAI/DEPSetupComplete.receipt
sleep 2
/usr/local/bin/jamf policy -trigger test
}

#Running main 

if [ -e "/Library/Application Support/CAI/DEPSetupComplete.receipt" ]; then
	echo "Setup has already been run"
	exit 0
else
	echo "Setup has not been run"
	echo "Starting to Run DEP Setup"
	runDEPSetup
	exit 0
fi