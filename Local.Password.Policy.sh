#!/bin/sh

#create an array of all user names
Users=( $(ls /Users) )
Users2=()

#Run through array to create another array of non-admin/computer Local Accounts
for user in ${Users[@]}; do
    if [[ $user == "Shared" ]] || [[ $user == "admin" ]] || [[ $user == "administrator" ]] || [[ $user == ".localized" ]]; then
	echo ""
    else
	    uid=$(id -u $user)
		if [[ $uid -ge 500 ]] && [[ $uid -le 600 ]]; then
			Users2+=("$user")
		fi
    fi
done

#set password policy for all Local accounts in new array
for name in ${Users2[@]}; do
	pwpolicy -u $name -setpolicy "usingHistory=5 canModifyPasswordforSelf=1 usingExpirationDate=0 usingHardExpirationDate=0 requiresAlpha=1 requiresNumeric=1 expirationDateGMT=12/31/69 hardExpireDateGMT=12/31/69 maxMinutesUntilChangePassword=129600 maxMinutesUntilDisabled=0 maxMinutesOfNonUse=0 maxFailedLoginAttempts=0 minChars=8 maxChars=0 passwordCannotBeName=1 requiresMixedCase=1 requiresSymbol=1 newPasswordRequired=1 minutesUntilFailedLoginReset=0 notGuessablePattern=0"
	echo "Password policy has been set on $name"
done
