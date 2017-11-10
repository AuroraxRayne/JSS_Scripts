#!/bin/sh

#touch .netrc
#chmod 700

#echo "machine ftp.dennisbrowning.me" >> .netrc
#echo "login test" >> .netrc
#echo "password Earth123!" >> .netrc

User=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

Now=$(/bin/date +"%m-%d-%Y")

touch /Library/Application\ Support/CAI/Search_Results_"$User"_$Now.txt
Search_Results=/Library/Application\ Support/CAI/Search_Results_"$User"_$Now.txt

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



#ftp -d ftp.dennisbrowning.me << ftpEOF
#prompt
#put $Search_Results.txt
#quit
#ftpEOF

