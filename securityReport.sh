#!/bin/sh
set -x

#
# HARDCODED VALUES SET HERE
#

#Enter in the URL of the JSS we are are pulling and pushing the data to. (NOTE: We will need the https:// and :8443. EX:https://jss.company.com:8443 )
jssURL="$(osascript -e 'display dialog "Please enter the jss URL:" default answer "https://server.com:8443" with title "jss URL" giving up after 86400 with text buttons {"OK"} default button 1' -e 'return text returned of result')"
#jssURL=""

#Enter in a username and password that has the correct read and write permissions to the JSS API for what data we need

jssUser="$(osascript -e 'display dialog "Please enter Username:" default answer "" with title "jss Username" giving up after 86400 with text buttons {"OK"} default button 1' -e 'return text returned of result')"
jssPass="$(osascript -e 'display dialog "Please enter Password:" default answer "" with title "jss Password" giving up after 86400 with text buttons {"OK"} default button 1 with hidden answer' -e 'return text returned of result')"
#jssUser=""
#jssPass=""


#CSF file path for devices list - JSS ID numbers only
devicelist="/tmp/ids.csv"
computerList="/tmp/computers.csv"
touch /tmp/ids.csv
touch /tmp/computers.csv
curl -H "Accept: application/xml" -k -u "$jssUser":"$jssPass" "$jssURL"/JSSResource/computers | xpath /computers/computer/id | sed 's/<id>//g' | sed 's/<\/id>/\'$'\n/g' >> "$devicelist"

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"


#####No configuration variables below this line.  You should not need to edit unless you are modifying functionality
#####################################################################################################
echo "parsing Computer IDs"
l=`cat $devicelist`
PREV_IFS="$IFS" # Save previous IFS
IFS=, ids=($l)
IFS="$PREV_IFS" # Restore IFS
echo "computerName,domainName,osVersion,model,ipAddress,lastCheckIn,userName,userFullName,userEmail" >> $computerList
for id in ${ids[@]}; do
	computerName=$(curl -H "Accept: application/xml" -k -u "$jssUser":"$jssPass" "$jssURL"/JSSResource/computers/id/$id | xpath /computer/general/name | sed 's/<name>//g' | sed 's/<\/name>//g')
	domainName=$(curl -H "Accept: application/xml" -k -u "$jssUser":"$jssPass" "$jssURL"/JSSResource/computers/id/$id | xpath /computer/hardware/active_directory_status | sed 's/<active_directory_status>//g' | sed 's/<\/active_directory_status>//g')
	osVersion=$(curl -H "Accept: application/xml" -k -u "$jssUser":"$jssPass" "$jssURL"/JSSResource/computers/id/$id | xpath /computer/hardware/os_version | sed 's/<os_version>//g' | sed 's/<\/os_version>//g')
	model=$(curl -H "Accept: application/xml" -k -u "$jssUser":"$jssPass" "$jssURL"/JSSResource/computers/id/$id | xpath /computer/hardware/model | sed 's/<model>//g' | sed 's/<\/model>//g' | sed -e 's/,//g')
	ipAddress=$(curl -H "Accept: application/xml" -k -u "$jssUser":"$jssPass" "$jssURL"/JSSResource/computers/id/$id | xpath /computer/general/last_reported_ip | sed 's/<last_reported_ip>//g' | sed 's/<\/last_reported_ip>//g')
	lastCheckIn=$(curl -H "Accept: application/xml" -k -u "$jssUser":"$jssPass" "$jssURL"/JSSResource/computers/id/$id | xpath /computer/general/last_contact_time | sed 's/<last_contact_time>//g' | sed 's/<\/last_contact_time>//g')
	userName=$(curl -H "Accept: application/xml" -k -u "$jssUser":"$jssPass" "$jssURL"/JSSResource/computers/id/$id | xpath /computer/location/username | sed 's/<username>//g' | sed 's/<\/username>//g')
	userFullName=$(curl -H "Accept: application/xml" -k -u "$jssUser":"$jssPass" "$jssURL"/JSSResource/computers/id/$id | xpath /computer/location/realname | sed 's/<realname>//g' | sed 's/<\/realname>//g' | sed -e 's/,//g')
	userEmail=$(curl -H "Accept: application/xml" -k -u "$jssUser":"$jssPass" "$jssURL"/JSSResource/computers/id/$id | xpath /computer/location/email_address | sed 's/<email_address>//g' | sed 's/<\/email_address>//g')
	
	if [[ "$userName" == "<username />" ]]; then
		userName="Unassigned"
	fi
	if [[ "$userFullName" == "<realname />" ]]; then
		userFullName=""
	fi
	if [[ "$userEmail" == "<email_address />" ]]; then
		userEmail=""
	fi
	if [[ "$lastCheckIn" == "<last_contact_time />" ]]; then
		lastCheckIn=""
	fi
	
	echo ""$computerName","$domainName","$osVersion","$model","$ipAddress","$lastCheckIn","$userName","$userFullName","$userEmail"" >> "$computerList"
done

uuencode $computerList computers.csv | mail -s "Mac Client Summary" Person@company.com


#Clean up
sleep 15
rm "$devicelist"
rm "$computerList"

