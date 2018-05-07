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
printerList="/tmp/printers.csv"
tempList="/tmp/tempList.csv"
touch /tmp/ids.csv
touch /tmp/printers.csv
touch /tmp/tempList.csv
#curl -H "Accept: application/xml" -k -u "$jssUser":"$jssPass" "$jssURL"/JSSResource/computers | xpath /computers/computer/id | sed 's/<id>//g' | sed 's/<\/id>/\'$'\n/g' >> "$devicelist"

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"


#####No configuration variables below this line.  You should not need to edit unless you are modifying functionality
#####################################################################################################
echo "parsing Computer IDs"
l=`cat $devicelist`
PREV_IFS="$IFS" # Save previous IFS
IFS=, ids=($l)
IFS="$PREV_IFS" # Restore IFS
echo "computerName,printerName,printerURI,printerDriverType" >> $printerList
for id in ${ids[@]}; do
	computerName=$(curl -H "Accept: application/xml" -k -u "$jssUser":"$jssPass" "$jssURL"/JSSResource/computers/id/$id | xpath /computer/general/name | sed 's/<name>//g' | sed 's/<\/name>//g')
	printerName=$(curl -H "Accept: application/xml" -k -u "$jssUser":"$jssPass" "$jssURL"/JSSResource/computers/id/$id/subset/hardware | xpath /computer/hardware/mapped_printers/printer/name | sed 's/<name>//g' | sed 's/<\/name>/\'$'\n/g')
	printerURI=$(curl -H "Accept: application/xml" -k -u "$jssUser":"$jssPass" "$jssURL"/JSSResource/computers/id/$id/subset/hardware | xpath /computer/hardware/mapped_printers/printer/uri | sed 's/<uri>//g' | sed 's/<\/uri>/\'$'\n/g')
	printerDriverType=$(curl -H "Accept: application/xml" -k -u "$jssUser":"$jssPass" "$jssURL"/JSSResource/computers/id/$id/subset/hardware | xpath /computer/hardware/mapped_printers/printer/type | sed  's/<type>//g' | sed 's/<\/type>/\'$'\n/g')
	
		echo ""$computerName","$printerName","$printerURI","$printerDriverType"" >> "$printerList"
		#done
done


#Clean up
#rm "$devicelist"

"$jamfHelper" -windowType "utility" -title "Script Done" -description "Script Finished Running" -timeout 300 -button1 "OK"
