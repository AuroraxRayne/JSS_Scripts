#!/bin/sh

#touch .netrc
#chmod 700

#echo "machine ftp.dennisbrowning.me" >> .netrc
#echo "login test" >> .netrc
#echo "password Earth123!" >> .netrc

Search1=( $(mdfind 'poidf;lakdf - a;lkndf;d') )
Search2=( $(mdfind 'poidf;lakdf a;lkndf;d') )
Search3=( $(mdfind 'apjtak;egt') )

User=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

Now=$(/bin/date +"%m-%d-%Y")

touch /Library/Application\ Support/CAI/Search_Results_"$User"_$Now.txt
Search_Results=/Library/Application\ Support/CAI/Search_Results_"$User"_$Now.txt

echo "Search results for \"Inventory Solutions – Franchise Order\"" >> $Search_Results
for file1 in ${Search1[@]}; do
	ls -hal $file1 
	if [ $? -eq 0 ]; then
		echo "$(ls -hal $file1)" >> $Search_Results
	fi
done

echo "Search results for \"Inventory Solutions Franchise Order\"" >> $Search_Results
for file2 in ${Search2[@]}; do
	ls -hal $file2
	if [ $? -eq 0 ]; then
	echo "$(ls -hal $file2)" >> $Search_Results
	fi

done

echo "Search results for \"AAX Products Terms and Conditions\"" >> $Search_Results
for file3 in ${Search3[@]}; do
	ls -hal $file3
	if [ $? -eq 0 ]; then
	echo "$(ls -hal $file3)" >> $Search_Results
	fi
done


#ftp -d ftp.dennisbrowning.me << ftpEOF
#prompt
#put $Search_Results.txt
#quit
#ftpEOF

