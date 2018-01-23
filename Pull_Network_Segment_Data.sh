#!/bin/sh
set -x

#
# HARDCODED VALUES SET HERE
#

#Enter in the URL of the JSS we are are pulling and pushing the data to. (NOTE: We will need the https:// and :8443. EX:https://jss.company.com:8443 )
jssURL="https://casper.company.com:8443"

#Enter in a username and password that has the correct read and write permissions to the JSS API for what data we need

jssUser=""
jssPass=""



#CSF file path for devices list - JSS ID numbers only
dplist="/Users/ddcdennisb/Desktop/dpList.txt"
touch /Users/ddcdennisb/Desktop/dpList.txt

count=1

while [[ $count -lt 140 ]]; do
	echo "$count" >> $dplist
	name=$(curl -k --user "$jssUser":"$jssPass" "$jssURL/JSSResource/networksegments/id/$count" | xpath /network_segment/name)
	echo "DP Name: $name" >> $dplist
	DP=$(curl -k --user "$jssUser":"$jssPass" "$jssURL/JSSResource/networksegments/id/$count" | xpath /network_segment/distribution_point)
	echo "DP: $DP" >> $dplist
	count=$((count+=1))
done

