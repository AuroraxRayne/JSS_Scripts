#!/bin/sh

#Gets current users login
un=`ls -l /dev/console | cut -d " " -f4`

#Checks to see fi user is in group mac_admins and set permissions to local admin group if valid

#if groups $un | grep -q -E "Mac Users"; then
#	echo ‘yes’
#echo "Checking access for $un"
    if groups $un | grep -q -E "admin"; then
        echo 'sweet'
        echo "$un is already in the admin group"
        exit 0
    else
      /usr/sbin/dseditgroup -o edit -a $un -t user admin
      echo "$un has been added to admin group"
    fi
#else
#	echo ‘no’
 #   if groups $un | grep -q -E "admin"; then
    #    dseditgroup -o edit -d $un -t user admin
    #else
    #    echo 'not listed as admin'
    #fi
#fi

sleep 2

uname=admin
#if groups $uname | grep -q -E "admin"; then
 #   echo 'Already a member'
#else
 #   echo 'Not a member.  Let me add that for you Jack!'
    /usr/sbin/dseditgroup -o edit -a $uname -t user admin
#fi


#/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -users daladmin,admin,casperscreensharing -privs -all -restart -agent
