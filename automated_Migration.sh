#!/bin/sh
LoggedInUser=`ls -l /dev/console | cut -d " " -f4`

#create an array of all user names
	Users=( $(ls /Users) )
	
if [[ "$4" != "" ]]; then
un="$4"
fi
if [[ "$5" != "" ]]; then
pass="$5"
fi
if [[ "$6" != "" ]]; then
olddomain="$6"
fi
if [[ "$7" != "" ]]; then
newdomain="$7"
fi
if [[ "$8" != "" ]]; then
newDomainTrigger="$8"
fi
domain=$(dsconfigad -show | grep 'Active Directory Domain')

if [[ ${domain} == "" ]]; then
	echo "This computer is not currently joined to a domain.  Please manually join this computer to the new domain"
	exit 1
fi


runMigration ()
{

echo "Unjoining $olddomain"

dsconfigad -remove -u $un -p $pass

sleep 5

#Chcek to see if disjoin worked.  If not, a forced disjoin will be done and then joined to new Domain.  If the disjoin worked at first it will just join to the new domain.
domain1=$(dsconfigad -show | awk '/Active Directory Domain/ {print $4}')
echo "you are on domain: $domain1"

sleep 5

if [[ ${domain1} =~ '$olddomain' ]]; then
	echo "Still on $olddomain"
	dsconfigad -force -remove -u $un -p $pass
	sleep 10
	/usr/local/jamf/bin/jamf policy -trigger $newDomainTrigger
else
	echo "Looks like unjoin worked.  Lets join the $newdomain Domain"
	/usr/local/jamf/bin/jamf policy -trigger $newDomainTrigger
	sleep 5
fi

sleep 3
#Make sure we are on the new domain
echo "first check after bind"
domain2=$(dsconfigad -show | grep 'Active Directory Domain')

#Line for recording in Policy Log
echo "results of first check is: $domain2"

# If on the new Domain, reset permissions on home directory to new UUID for first Login
if [[ ${domain2} =~ $newdomain ]]; then
	echo "Sweet you are on $newdomain You are all set"
	
	#Run through array to delete mobile account and fix permissions as long as the username is not admin, administrator, fixme or Shared
	for user in ${Users[@]}; do
		echo "$user"
		if [[ $user =~ "admin" ]] || [[ $user == "Shared" ]] || [[ $user == ".localized" ]] || [[ $user == "Guest" ]] || [[ $user == "Library" ]]; then
		    echo "Local User.  Doing Nothing"
		else
		  	#Fix Permissions
			echo "Lets fix permissions on $user home directory"
			#change ownership of home dir to new UUID
			chown -R $user /Users/$user
			sleep 5
		fi
	done
	
	sleep 2
	exit 0

else
    echo "something went wrong with $newdomain join.  Please run manual remediation."
    exit 1
fi
}

if [[ ${LoggedInUser} == "" ]] || [[ ${LoggedInUser} == "root" ]]; then
    echo "No one is logged in lets run the migration"
    runMigration
else
    echo "$LoggedInUser is logged in and this process will exit"
    exit 1
fi