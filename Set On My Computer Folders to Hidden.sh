#!/bin/sh

#Get logged in username
user=$(logname)

echo "$user"

#This will set Hide On My Computer folders in Outlook to True
sudo -u $user defaults write com.microsoft.Outlook HideFoldersOnMyComputerRootInFolderList -bool true


