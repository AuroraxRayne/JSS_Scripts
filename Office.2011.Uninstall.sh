#!/bin/sh

un=`ls -l /dev/console | cut -d " " -f4`

echo $un

	osascript -e 'tell application "Microsoft Database Daemon" to quit'
	osascript -e 'tell application "Microsoft AU Daemon" to quit'
	osascript -e 'tell application "Office365Service" to quit'
	osascript -e 'tell application "Microsoft Outlook" to quit'
	osascript -e 'tell application "Microsoft Word" to quit'
	osascript -e 'tell application "Microsoft Excel" to quit'
	osascript -e 'tell application "Microsoft PowerPoint" to quit'
	rm -R '/Applications/Microsoft Communicator.app/'
	rm -R '/Applications/Microsoft Messenger.app/'
	rm -R '/Applications/Microsoft Office 2011/'
	rm -R '/Applications/Remote Desktop Connection.app/'
	rm -R '/Library/Application Support/Microsoft/'
	#rm -Rv "/Users/$un/Documents/Microsoft User Data/Office 2011 Identities/"
	rm -R /Library/Automator/*Excel*
	rm -R /Library/Automator/*Office*
	rm -R /Library/Automator/*Outlook*
	rm -R /Library/Automator/*PowerPoint*
	rm -R /Library/Automator/*Word*
	rm -R /Library/Automator/*Workbook*
	rm -R '/Library/Automator/Get Parent Presentations of Slides.action'
	rm -R '/Library/Automator/Set Document Settings.action'
	rm -R /Library/Internet\ Plug-Ins/SharePoint*
	rm -R /Library/LaunchDaemons/com.microsoft.*
	rm -R /Library/Preferences/com.microsoft.*
	rm -R /Library/PrivilegedHelperTools/com.microsoft.*
	OFFICERECEIPTS=$(pkgutil --pkgs=com.microsoft.office.*)
	for ARECEIPT in $OFFICERECEIPTS
	do
		pkgutil --forget $ARECEIPT
	done
exit 0