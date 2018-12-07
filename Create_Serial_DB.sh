#!/bin/sh
set -x
####################################################################################################
#
# Copyright (c) 2014, JAMF Software, LLC.  All rights reserved.
#
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions are met:
#               * Redistributions of source code must retain the above copyright
#                 notice, this list of conditions and the following disclaimer.
#               * Redistributions in binary form must reproduce the above copyright
#                 notice, this list of conditions and the following disclaimer in the
#                 documentation and/or other materials provided with the distribution.
#               * Neither the name of the JAMF Software, LLC nor the
#                 names of its contributors may be used to endorse or promote products
#                 derived from this software without specific prior written permission.
#
#       THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
#       EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
####################################################################################################
# HISTORY
# 	Version 1.0
#	
#	- Created by Erin McDonald September 3rd, 2014
#   - Edited 5/27/15 by Erin McDonald - changed mobile devices to computers
#
####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#    Create_Static_Device_Group.sh -- Create static user group
#
#    
# DESCRIPTION
#    This script was designed to create a static group then add mobile devices to it via
#    CSV list of usernames
#
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
#####################################################################################################
#
# HARDCODED VALUES SET HERE
#


#Name our static Device group
Name=""

#Enter in the URL of the JSS we are are pulling and pushing the data to. (NOTE: We will need the https:// and :8443. EX:https://jss.company.com:8443 )
jssURL=""

#Enter in a username and password that has the correct read and write permissions to the JSS API for what data we need
jssUser=""
jssPass=""

#CSF file path for devices list - JSS ID numbers only
devicelist="/Users/ddcdennisb/Downloads/serials.csv"

#Default temp file name and path we will build for API submission. - No need to edit this
groupFilePath="/tmp/devices.xml"


#####No configuration variables below this line.  You should not need to edit unless you are modifying functionality
#####################################################################################################
#Create new static user group

var1="<computer_group><name>${Name}</name><is_smart>false</is_smart></computer_group>"

echo ${var1} > /tmp/newdevicegroup.xml


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
		echo "<serial_number>$val</serial_number>" >> "$groupFilePath"
		echo "$c" >> "$groupFilePath"
done
	echo "$d" >> "$groupFilePath"
	
	#Submit group to JSS
	
#Clean up
#rm "$groupFilePath"

#done