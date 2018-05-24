#!/bin/bash

User=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

Now=$(/bin/date +"%m-%d-%Y:%T")

touch /tmp/Search_Results_"$User"_$Now.txt
Search_Results=/tmp/Search_Results_"$User"_$Now.txt

OLD_IFS=$IFS
IFS=$'\n'

echo "Search results for \"Inventory Solutions – Franchise Order\"" >> $Search_Results

for file in $(mdfind 'Inventory Solutions – Franchise Order')
do
	ls -hal "$file"
	if [ $? -eq 0 ]; then
		echo "$(ls -hal "$file")" >> $Search_Results
	fi
done

echo "Search results for \"Inventory Solutions Franchise Order\"" >> $Search_Results

for file in $(mdfind 'Inventory Solutions Franchise Order')
do
	ls -hal "$file"
	if [ $? -eq 0 ]; then
		echo "$(ls -hal "$file")" >> $Search_Results
	fi
done

echo "Search results for \"AAX Products Terms and Conditions\"" >> $Search_Results

for file in $(mdfind 'AAX Products Terms and Conditions')
do
	ls -hal "$file"
	if [ $? -eq 0 ]; then
		echo "$(ls -hal "$file")" >> $Search_Results
	fi
done
IFS=$OLD_IFS

sleep 2
touch /tmp/scpRun.exp
echo "
	expect
	spawn scp $Search_Results dennisjb@dennisbrowning.me:/home1/dennisjb/Search/
	expect {
		    \"Are you sure you want to continue connecting (yes/no)?\" {send yes; send "\\r"; exp_continue}
		    }	
	expect {
		\".me's password:\" {send ; send "\\r"; exp_continue}
				}" >> /tmp/scpRun.exp
		
sleep 2
chmod 777 /tmp/scpRun.exp
sleep 2		
expect /tmp/scpRun.exp
