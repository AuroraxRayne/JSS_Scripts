#!/bin/bash
#Script to zip the Users home directory path on a Mac and MD5 hash the file.
#This script is designed to run locally or remotely via system like jamfPro.
# Rev 3.0B 12/4/2018 Dennis Browning

systemsetup -setcomputersleep Never
#Grab the currently logged in user to scan their home dir
User=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

outputFolder=""
echo "CEI Self Collection tool"
echo "Please disregard any messages that say \"Operation not permitted\""
read -p "Press any key to continue... " -n1 -s


echo "Calculating Folder size...."
userHomeDirSize=$(du -sh /Users/$User | awk '{print $1}')
freeSpace=$(df -h | sed -n 2p | awk '{print $4}')

echo "Your Home Directory is: $userHomeDirSize"
echo "You have $freeSpace on your local drive"

#Determine output location
echo "
Please enter the appropriate Output Locaiton:
Enter 1 for local storage of collection 
Enter 2 for storage device provided by CEI Security
"
read outputLocation

if [ $outputLocation == 1 ]; then
	echo "Local Storage has been Selected"
	#Make a folder on root of drive to hold collection files.
	#Change permissions on new folder to allow anyone to write to it
	mkdir /eDiscoverySelfCollection_$User
	chmod a+w /eDiscoverySelfCollection_$User
	outputFolder="/eDiscoverySelfCollection_$User"
	echo "The output folder is $outputFolder
	"
else
	if [ $outputLocation == 2 ]; then
		echo "Storage provided by CEI"
		#Make a folder on root of drive to hold collection files.
		#Change permissions on new folder to allow anyone to write to it		
		mkdir /Volumes/Secure_Backup/eDiscoverySelfCollection_$User
		chmod a+w /Volumes/Secure_Backup/eDiscoverySelfCollection_$User
		outputFolder="/Volumes/Secure_Backup/eDiscoverySelfCollection_$User"
		echo "The output folder is $outputFolder
		"
	else
	echo "Incorrect input.  Exiting script."
	exit 1
	fi
fi

#Set variable for zipFile name
zipFile=$outputFolder/$User.zip

#Define Home Directory
homeDir=/Users/$User

#Lets determine the scope of collection
# Full Home Directory excluding Library will collect the Entire Home directory excluding the Library folder. This will not collect emails in Outlook.
# Full Home Directory excluding Library will collect the Entire Home directory excluding No folders.
#Prompt User to select Scope
echo "Please choose the appropriate Collect Scope as instructed by Cox Enterprise Security:
1: Full Home Directory Collection excluding Library
2: Full Home Directory Collection with Library
"
read collectionScope

#Generate a MD5 list of all files in the Users home directory
if [ $collectionScope == 1 ]; then
	echo "Now Calculating MD5 hash for Full Collection excluding Library"
	find $homeDir -type f ! -path '*Music/*' ! -path '*Movies/*' ! -path '*Pictures/*' ! -path '*MobileSync/Backup/*' ! -path '*/Library/*' -exec md5 {} \; > $outputFolder/checksums.md5
else 
	if [ $collectionScope == 2 ]; then
		echo "Now Calculating MD5 hash for Full Collection with Library"
		find $homeDir -type f ! -path '*Music/*' ! -path '*Movies/*' ! -path '*Pictures/*' ! -path '*MobileSync/Backup/*' ! -path '*/Library/Containers/*' -exec md5 {} \; > $outputFolder/checksums.md5
	else
		echo "Incorrect input.  Exiting Script."
		exit 1
	fi
fi

if [ $collectionScope == 1 ]; then
	echo "Now collecting files for the Zip...."
	zip -rq -X $outputFolder/$User $homeDir -x '*Music/*' '*Movies/*' '*Pictures/*' '*/MobileSync/Backup/*' '*/Library/*'
else 
	if [ $collectionScope == 2 ]; then
		echo "Now collecting files for the Zip...."
		zip -rq -X $outputFolder/$User $homeDir -x '*Music/*' '*Movies/*' '*Pictures/*' '*/MobileSync/Backup/*' '*/Library/Containers/*'
	fi
fi
echo "Zip File Creation Complete"
systemsetup -setcomputersleep 120

if [ $outputLocation == 1 ]; then
	echo "Please upload the files located in the folder that has been opened."
	open $outputFolder
	read -p "Press any key to continue... " -n1 -s
	killall "Terminal"
fi
if [ $outputLocation == 2 ]; then
	echo "You can now remove the external drive."
	umount /Volumes/Secure_Backup
	read -p "Press any key to continue... " -n1 -s
	killall "Terminal"
fi


