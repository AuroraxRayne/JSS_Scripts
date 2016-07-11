#!/bin/sh

#check to see if anyone is currently logged in
loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

if [[ ${loggedInUser} != '' ]]; then
    echo "$loggedInUsers is currently logged in.  This process will exit"
    exit 1
else
    

    echo "Unjoining DT.inc"

    dsconfigad -remove -u svc_dtcasper -p J0inP@ssWrd

    sleep 3

    #Chcek to see if disjoin worked.  If not, a forced disjoin will be done and then joined to new Domain.  If the disjoin worked at first it will just join to the new domain.
    domain1=$(dsconfigad -show | grep 'Active Directory Domain')

    if [[ ${domain1} =~ 'dt.inc' ]]; then
	    echo "Still on Dealertrack"
	    dsconfigad -force -remove -u svc_dtcasper -p J0inP@ssWrd
	    sleep 10
	    /usr/local/jamf/bin/jamf policy -trigger joinmanco
    else
	    echo "Looks like unjoin worked.  Lets join the MAN.CO Domain"
	    /usr/local/jamf/bin/jamf policy -trigger joinmanco
	    sleep 5
    fi

    sleep 3
    #Make sure we are on the new domain
    echo "first check after bind"
    domain2=$(dsconfigad -show | grep 'Active Directory Domain')

    #Line for recording in Policy Log
    echo "results of first check $domain2"

    sleep 3
    # If on the new Domain, reset permissions on home directory to new UUID for first Login
    if [[ ${domain2} =~ 'man.co' ]]; then
    	echo "Sweet you are on MAN.CO You are all set"
	    echo "Lets clean up your old DT account"
	
	    #create an array of all user names
	    Users=( $(ls /Users) )

	    #Run through array to delete mobile account and fix permissions as long as the username is not admin, administrator, fixme or Shared
	    for user in ${Users[@]}; do
		    echo "$user"
		    if [[ $user =~ "admin" ]] || [[ $user == "fixme" ]] || [[ $user == "Shared" ]] || [[ $user == ".localized" ]]; then
		    else
			    #delete mobile account
			    dscl . -delete /Users/$user
			
		    	sleep 10
			
			    #Fix Permissions
			    echo "Lets fix permissions on $un home directory"
			    #change ownership of home dir to new UUID
			    chown -R $user /Users/$user
		    fi
	    done
	
	    sleep 2
        exit 0
		
    else
	    exit 1
	
    fi
fi