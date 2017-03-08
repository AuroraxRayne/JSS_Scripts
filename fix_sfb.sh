#!/bin/sh

#gets user name as variable
user=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'` 

#Close SFB
if ( pgrep "Skype for Business" > /dev/null ); then
    echo "Killing SFB"
    killall "Skype for Business"
else
    echo "SFB is not running"
fi


#Remove files for SFB
rm -rfv /Users/$user/Library/Preferences/com.microsoft.SkypeForBusinessTAP.plist
rm -rfv /Users/$user/Library/Logs/com.microsoft.SkypeForBusinessTAP
rm -rfv /Users/$user/Library/Application\ Support/Skype\ for\ Business
rm -rfv /Users/$user/Library/Containers/com.microsoft.SkypeForBusiness
rm -rfv /Users/$user/Library/Application\ Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.microsoft.skypeforbusinesstap.sfl
rm -rfv /Users/$user/Library/Application\ Support/com.microsoft.SkypeForBusinessTAP
rm -rfv /Users/$user/Library/Cookies/com.microsoft.SkypeForBusinessTAP.binarycookies

#Remove Keychain Items
security delete-generic-password -l "Skype for Business" /Users/$user/Library/Keychains/login.keychain
security delete-generic-password -l "com.microsoft.SkypeForBusiness.HockeySDK" /Users/$user/Library/Keychains/login.keychain
security delete-generic-password -l "com.microsoft.SkypeForBusinessTAP.HockeySDK" /Users/$user/Library/Keychains/login.keychain
security delete-generic-password -l "com.microsoft.skypeforbusiness.webmeetings.HockeySDK" /Users/$user/Library/Keychains/login.keychain
