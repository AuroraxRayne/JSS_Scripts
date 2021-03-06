# DEFINE VARIABLES & READ IN PARAMETERS

property ExchangeServer : "https://outlook.office365.com/EWS/Exchange.asmx"

property emailDomain : "coxautoinc.com"

property WindowsDomain : "Cox Auto Inc"


############## Do Not Edit Below This Line ############## 

--The fullName and shortName properties are populated automatically
property shortName : ""
property FullName : ""
property ecStatus : ""
property fname : ""
property lname : ""
property emailAddress : ""

--Get the user's short name and full name
set shortName to do shell script ("/bin/ps -ajx | /usr/bin/grep -m 1 'Finder.app' | /usr/bin/awk '{print $1}'")
set FullName to do shell script ("/usr/bin/dscl /Search -read \"/Users/" & shortName & "\" RealName 2>/dev/null | grep \" \" | tail -1 | sed 's/^ *//' | sed 's/RealName: //g'")
set ecStatus to do shell script ("/Applications/Enterprise\\ Connect.app/Contents/SharedSupport/eccl -p signedInStatus | awk '/signedInStatus/{print $NF}'")

if (ecStatus = "true") then
	set fname to do shell script ("/Applications/Enterprise\\ Connect.app/Contents/SharedSupport/eccl -a givenName | awk '/givenName/{print $NF}'")
	set lname to do shell script ("/Applications/Enterprise\\ Connect.app/Contents/SharedSupport/eccl -a sn | awk '/sn/{print $NF}'")
	set emailAddress to fname & "." & lname & "@" & emailDomain
else
	try
		with timeout of 600 seconds
			tell application "System Events" to display dialog "Please enter your CAI email address." buttons {"OK"} default button "OK" default answer "@coxautoinc.com"
			set the_result to the result
			set emailAddress to text returned of the_result
		end timeout
	end try
end if

--Enable Access for Assisted Devices (for GUI scripting)
do shell script "/usr/bin/touch /private/var/db/.AccessibilityAPIEnabled" with administrator privileges

createNewAccount()

on createNewAccount()
	--Determine the emailAddress based on the information we've found
	
	
	--Allow the user to verify their email address
	try
		with timeout of 600 seconds
			tell application "System Events" to display dialog "Please verify that your email address is correct. Enter any corrections." buttons {"OK"} default button "OK" default answer emailAddress
			set the_result to the result
			set emailAddress to text returned of the_result
		end timeout
	end try
	
	--Ensure the First Run Outlook screen does not appear
	do shell script ("/usr/bin/defaults write \"/Users/" & shortName & "/Library/Preferences/com.microsoft.Outlook\" \"FirstRunExperienceCompleted\" -bool YES") with administrator privileges
	do shell script ("/usr/sbin/chown " & shortName & ":staff \"/Users/" & shortName & "/Library/Preferences/com.microsoft.Outlook.plist\"") with administrator privileges
	
	
	--Configure the account
	tell application "Microsoft Outlook"
		activate
		make new exchange account with properties {name:WindowsDomain, full name:FullName, email address:emailAddress, user name:emailAddress, server:ExchangeServer, background autodiscover:true}
	end tell
	
	--Tell the user the account has been configured
	try
		with timeout of 600 seconds
			activate
			tell application "System Events" to display dialog "Your email account has been successfully configured in Outlook.  Please allow 5-10 minutes for Outlook to begin syncing your email.  Please enter your password on any Outlook dialogs that prompt for your password" buttons {"OK"} default button "OK"
		end timeout
	end try
end createNewAccount