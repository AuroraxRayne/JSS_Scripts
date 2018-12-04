#!/bin/bash
#Script to zip the Users home directory path on a Mac and MD5 hash the file.
#This script is designed to run locally or remotely via system like jamfPro.
# Rev 2.0 10/9/2018 Dennis Browning


#Grab the currently logged in user to scan their home dir
User=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

#Make a folder on root of drive to hold collection files.
#Change permissions on new folder to allow anyone to write to it
mkdir /Volumes/Secure_Backup/eDiscoverySelfCollection_$User
chmod a+w /Volumes/Secure_Backup/eDiscoverySelfCollection_$User

#Set variable for zipFile name
zipFile=/Volumes/Secure_Backup/eDiscoverySelfCollection_$User/$User.zip

#Define Home Directory
homeDir=/Users/$User

#Generate a MD5 list of all files in the Users home directory
find $homeDir -type f -exec md5 {} \; > /Volumes/Secure_Backup/eDiscoverySelfCollection_$User/checksums.md5

#Create a zip file with the contents of the users home directory excluding the folders for Music, Movies, Pictures and MobileSync/Backup.
zip -r -X /Volumes/Secure_Backup/eDiscoverySelfCollection_$User/$User $homeDir -x '*Music/*' 'Movies/*' 'Pictures/*' '*/MobileSync/Backup/*' '*/Library/Containers/*'

exit 0
