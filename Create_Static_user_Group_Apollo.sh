#!/bin/sh
set -x

#
# HARDCODED VALUES SET HERE
#


#Name our static Computer group (No spaces in name)
Name="$(osascript -e 'display dialog "Please enter the group name you want (all one word):" default answer "" with title "Group Name" giving up after 86400 with text buttons {"OK"} default button 1' -e 'return text returned of result')"


#Enter in the URL of the JSS we are are pulling and pushing the data to. (NOTE: We will need the https:// and :8443. EX:https://jss.company.com:8443 )
jssURL="$(osascript -e 'display dialog "Please enter the jss URL:" default answer "https://server.com:8443" with title "jss URL" giving up after 86400 with text buttons {"OK"} default button 1' -e 'return text returned of result')"


#Enter in a username and password that has the correct read and write permissions to the JSS API for what data we need

jssUser="$(osascript -e 'display dialog "Please enter Username:" default answer "" with title "jss Username" giving up after 86400 with text buttons {"OK"} default button 1' -e 'return text returned of result')"
jssPass="$(osascript -e 'display dialog "Please enter Password:" default answer "" with title "jss Password" giving up after 86400 with text buttons {"OK"} default button 1 with hidden answer' -e 'return text returned of result')"



#CSF file path for devices list - JSS ID numbers only
devicelist="/tmp/ids.csv"
touch /tmp/ids.csv
userlist="$(osascript -e 'display dialog "Please enter the path to Username List (Drag and drop csv file):" default answer "" with title "Path to Username File" giving up after 86400 with text buttons {"OK"} default button 1' -e 'return text returned of result')"


#Default temp file name and path we will build for API submission. - No need to edit this
groupFilePath="/tmp/devices.xml"

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"


#####No configuration variables below this line.  You should not need to edit unless you are modifying functionality
#####################################################################################################
echo "Finding Computer IDs for users in migration list"
l=`cat $userlist`
PREV_IFS="$IFS" # Save previous IFS
IFS=, names=($l)
IFS="$PREV_IFS" # Restore IFS

for nam in ${names[@]}; do
	list=$(curl -k --user "$jssUser":"$jssPass" "$jssURL"/JSSResource/users/name/$nam | xpath /user/links/computers/computer/id)
	echo $list | sed 's/<id>//g' | sed 's/<\/id>/\'$'\n/g' >> "$devicelist"
done



#Create new static user group

var1="<computer_group><name>"$Name"</name><is_smart>false</is_smart></computer_group>"

echo ${var1} > /tmp/newdevicegroup.xml

curl -k -v -u  "$jssUser":"$jssPass" "$jssURL"/JSSResource/computergroups/name/"$Name" -T "/tmp/newdevicegroup.xml" -X POST


#We will use these variable to build our xml file
a="<computer_group><computers>"
b="<computer>"
c="</computer>"
d="</computers></computer_group>"
	

#Build our array of values
echo "Building the array from CSV..."
v=`cat $devicelist`
PREV_IFS="$IFS" # Save previous IFS
IFS=, values=($v)
IFS="$PREV_IFS" # Restore IFS


#Build the XML from the array
echo "Building the xml at $groupFilePath..."
echo "$a" > "$groupFilePath"
for val in ${values[@]}; do
		echo "$b" >> "$groupFilePath"
		echo "<id>$val</id>" >> "$groupFilePath"
		echo "$c" >> "$groupFilePath"
done
	echo "$d" >> "$groupFilePath"
	
	#Submit group to JSS
echo "File submitting to $jssURL..."
	curl -k -v -u "$jssUser":"$jssPass" "$jssURL"/JSSResource/computergroups/name/$Name -T "$groupFilePath" -X PUT

#Clean up
rm "$groupFilePath"
rm "$devicelist"
rm /tmp/newdevicegroup.xml

"$jamfHelper" -windowType "utility" -title "Script Done" -description "Script Finished Running" -timeout 300 -button1 "OK"
