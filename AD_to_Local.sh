#!/bin/sh
# Modified 2/7/2017
Version=1.2
# Original source is from MigrateUserHomeToDomainAcct.sh
# Written by Patrick Gallagher - https://twitter.com/patgmac
#
# Guidance and inspiration from Lisa Davies:
# http://lisacherie.com/?p=239
#
# Modified by Rich Trouton
#
# Version 1.0 - Migrates an Active Directory mobile account to a local account by the following process:

# 1. Detect if the Mac is bound to AD and offer to unbind the Mac from AD if desired
# 2. Display a list of the accounts with a UID greater than 1000
# 3. Once an account is selected, back up the password hash of the account from the AuthenticationAuthority attribute
# 4. Remove the following attributes from the specified account:
# 
# cached_groups
# cached_auth_policy
# CopyTimestamp - This attribute is used by the OS to determine if the account is a mobile account
# SMBPrimaryGroupSID
# OriginalAuthenticationAuthority
# OriginalNodeName
# AuthenticationAuthority
# SMBSID
# SMBScriptPath
# SMBPasswordLastSet
# SMBGroupRID
# PrimaryNTDomain
# AppleMetaRecordName
# MCXSettings
# MCXFlags
#
# 5. Recreate the AuthenticationAuthority attribute and restore the password hash of the account from backup
# 6. Restart the directory services process
# 7. Check to see if the conversion process succeeded by checking the OriginalNodeName attribute for the value "Active Directory"
# 8. If the conversion process succeeded, update the permissions on the account's home folder.
# 9. Prompt if admin rights should be granted for the specified account
#
# Version 1.1
#
# Changes:
# 
# 1. After conversion, the specified account is added to the staff group.  All local accounts on this Mac are members of the staff group,
#    but AD mobile accounts are not members of the staff group.
# 2. The "accounttype" variable is now checking the AuthenticationAuthority attribute instead of the OriginalNodeName attribute. 
#    The reason for Change 2's attributes change is that the AuthenticationAuthority attribute will exist following the conversion 
#    process while the OriginalNodeName attribute may not.
#
#
# Version 1.2
#
# Changes:
#
# Add RemoveAD function to handle the following tasks:
#
# 1. Force unbind the Mac from Active Directory
# 2. Deletes the Active Directory domain from the custom /Search and /Search/Contacts paths
# 3. Changes the /Search and /Search/Contacts path type from Custom to Automatic
# 
# Thanks to Rick Lemmon for the suggested changes to the AD unbind process.


#listUsers="$(/usr/bin/dscl . list /Users UniqueID | awk '$2 > 1000 {print $1}') FINISHED"
FullScriptName=`basename "$0"`
ShowVersion="$FullScriptName $Version"
check4AD=`/usr/bin/dscl localhost -list . | grep "Active Directory"`
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')


RemoveAD(){

    # This function force-unbinds the Mac from the existing Active Directory domain
    # and updates the search path settings to remove references to Active Directory 

    searchPath=`/usr/bin/dscl /Search -read . CSPSearchPath | grep Active\ Directory | sed 's/^ //'`

    # Force unbind from Active Directory

    /usr/sbin/dsconfigad -remove -force -u none -p none
    
    # Deletes the Active Directory domain from the custom /Search
    # and /Search/Contacts paths
    
    /usr/bin/dscl /Search/Contacts -delete . CSPSearchPath "$searchPath"
    /usr/bin/dscl /Search -delete . CSPSearchPath "$searchPath"
    
    # Changes the /Search and /Search/Contacts path type from Custom to Automatic
    
    /usr/bin/dscl /Search -change . SearchPolicy dsAttrTypeStandard:CSPSearchPath dsAttrTypeStandard:NSPSearchPath
    /usr/bin/dscl /Search/Contacts -change . SearchPolicy dsAttrTypeStandard:CSPSearchPath dsAttrTypeStandard:NSPSearchPath
}

RunAsRoot "${0}"

# Check for AD binding and offer to unbind if found. 
if [[ "${check4AD}" = "Active Directory" ]]; then
	/bin/echo "This machine is bound to Active Directory.  Performing a force Remove"
		RemoveAD
		/bin/echo "AD binding has been removed."
fi

netname=`/usr/bin/osascript <<EOT
tell application "System Events"
    activate
    with timeout of 600 seconds
        set netname to text returned of (display dialog "Please type in Active Directory Username" default answer "" with icon 2)
	end timeout
end tell
EOT`
	

	
accounttype=`/usr/bin/dscl . -read /Users/"$netname" AuthenticationAuthority | head -2 | awk -F'/' '{print $2}' | tr -d '\n'`
			
if [[ "$accounttype" = "Active Directory" ]]; then
    mobileusercheck=`/usr/bin/dscl . -read /Users/"$netname" AuthenticationAuthority | head -2 | awk -F'/' '{print $1}' | tr -d '\n' | sed 's/^[^:]*: //' | sed s/\;/""/g`
    if [[ "$mobileusercheck" = "LocalCachedUser" ]]; then
	   /bin/echo "$netname has an AD mobile account.\nConverting to a local account with the same username and UID.\n"
	else
	   /bin/echo "The $netname account is not a AD mobile account\n"
	fi
else
	/bin/echo "The $netname account is not a AD mobile account\n"
fi

# Preserve the account password by backing up password hash
	
shadowhash=`/usr/bin/dscl . -read /Users/$netname AuthenticationAuthority | grep " ;ShadowHash;HASHLIST:<"`
			
# Remove the account attributes that identify it as an Active Directory mobile account
	
/usr/bin/dscl . -delete /users/$netname cached_groups
/usr/bin/dscl . -delete /users/$netname cached_auth_policy
/usr/bin/dscl . -delete /users/$netname CopyTimestamp
/usr/bin/dscl . -delete /users/$netname AltSecurityIdentities
/usr/bin/dscl . -delete /users/$netname SMBPrimaryGroupSID
/usr/bin/dscl . -delete /users/$netname OriginalAuthenticationAuthority
/usr/bin/dscl . -delete /users/$netname OriginalNodeName
/usr/bin/dscl . -delete /users/$netname AuthenticationAuthority
/usr/bin/dscl . -create /users/$netname AuthenticationAuthority \'$shadowhash\'
/usr/bin/dscl . -delete /users/$netname SMBSID
/usr/bin/dscl . -delete /users/$netname SMBScriptPath
/usr/bin/dscl . -delete /users/$netname SMBPasswordLastSet
/usr/bin/dscl . -delete /users/$netname SMBGroupRID
/usr/bin/dscl . -delete /users/$netname PrimaryNTDomain
/usr/bin/dscl . -delete /users/$netname AppleMetaRecordName
/usr/bin/dscl . -delete /users/$netname PrimaryNTDomain
/usr/bin/dscl . -delete /users/$netname MCXSettings
/usr/bin/dscl . -delete /users/$netname MCXFlags

# Refresh Directory Services
if [[ ${osvers} -ge 7 ]]; then
	/usr/bin/killall opendirectoryd
else
	/usr/bin/killall DirectoryService
fi
			
sleep 20
			
accounttype=`/usr/bin/dscl . -read /Users/"$netname" AuthenticationAuthority | head -2 | awk -F'/' '{print $2}' | tr -d '\n'`
if [[ "$accounttype" = "Active Directory" ]]; then
   /bin/echo "Something went wrong with the conversion process.\nThe $netname account is still an AD mobile account.\n"
   exit 1
else
   /bin/echo "Conversion process was successful.\nThe $netname account is now a local account.\n"
fi
			
homedir=`/usr/bin/dscl . -read /Users/"$netname" NFSHomeDirectory  | awk '{print $2}'`
if [[ "$homedir" != "" ]]; then
   /bin/echo "Home directory location: $homedir"
   /bin/echo "Updating home folder permissions for the $netname account"
   /usr/sbin/chown -R "$netname" "$homedir"		
fi
			
# Add user to the staff group on the Mac

/bin/echo "Adding $netname to the staff group on this Mac."
/usr/sbin/dseditgroup -o edit -a "$netname" -t user staff

			
/bin/echo "Displaying user and group information for the $netname account"
/usr/bin/id $netname

# Prompt to see if the local account should be give admin rights.
	
/bin/echo "Giving $netname account admin rights"
/usr/sbin/dseditgroup -o edit -a "$netname" -t user admin
/bin/echo "Admin rights given to this account"
