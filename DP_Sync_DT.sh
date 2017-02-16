#!/bin/sh

if [ -e /Users/admin/temp ]; then
	echo "Mount point already exist"
else
	echo "Lets create the mount"
	/bin/mkdir /Users/admin/temp
fi

echo "Mounting the Share"
/sbin/mount -t smbfs "//vt1hs1-jssdp01;casperadmin:Fri3ndlyGh0st@vt1hs1-jssdp01.dt.inc/CasperShare" /Users/admin/temp

echo " VT CasperShare is now mounted"

/bin/sleep 2

HOSTS=( vDALsrvCSP001 10.134.45.35 nhpappcas01 vNHPsrvCSP001 vSLCsrvCSP001 ) 
SOURCE_DIR="/Users/admin/temp/Packages" #Source directory from CasperShare
STATUS="/var/log/datasync.status"
NOW=$(/bin/date +"%m-%d-%Y_%H:%M")
#touch /Users/admin/log/datasync.$NOW.log
#EMAIL="/Users/admin/log/datasync.$NOW.log"


for i in "${HOSTS[@]}"; do
TODAY=$(/bin/date)
/usr/bin/touch /Users/admin/log/datasync.$NOW.$i.log
EMAIL="/Users/admin/log/datasync.$NOW.$i.log"
echo "===== Beginning rsync of $i  Date: $TODAY =====" | tee -a $STATUS $EMAIL
#mkdir /Users/admin/temp2
/sbin/mount -t smbfs "//$i;casperadmin:Fri3ndlyGh0st@$i/CasperShare" /Users/admin/temp2
DST="/Users/admin/temp2"
/usr/bin/rsync -ahuv --delete --progress --stats "$SOURCE_DIR" "$DST" | tee -a $STATUS $EMAIL

if [ $? = "1" ]; then
echo "FAILURE : rsync failed." | tee -a $STATUS $EMAIL
exit 1
fi
/sbin/umount /Users/admin/temp2
TODAY=$(/bin/date)
echo "===== Completed rsync of $i Date: $TODAY =====" | tee -a $STATUS $EMAIL
mail -s "DP Sync Log for $NOW.$i" dennis.browning@coxautoinc.com < $EMAIL
done


TODAY=$(date)
/usr/bin/touch /Users/admin/log/datasync.$NOW.qts1.log
EMAIL="/Users/admin/log/datasync.$NOW.qts1.log"
echo "===== Beginning rsync of 10.102.72.190  Date: $TODAY =====" | tee -a $STATUS $EMAIL
/bin/mkdir /Users/admin/temp2
/sbin/mount_smbfs "//10.102.72.190;CasperAdmin:4m%40cs0nly%21@10.102.72.190/CasperShare" /Users/admin/temp2
DST="/Users/admin/temp2"
/bin/sleep 10
/usr/bin/rsync -rltDv --delete --progress --stats "$SOURCE_DIR" "$DST" | tee -a $STATUS $EMAIL

if [ $? = "1" ]; then
echo "FAILURE : rsync failed." | tee -a $STATUS $EMAIL
exit 1
fi
/sbin/umount /Users/admin/temp2
TODAY=$(/bin/date)
echo "===== Completed rsync of 10.102.72.190 Date: $TODAY =====" | tee -a $STATUS $EMAIL


/sbin/umount /Users/admin/temp

echo "SUCCESS : rsync completed successfully" | tee -a $STATUS $EMAIL

mail -s "DP Sync Log for $NOW.qts1" dennis.browning@coxautoinc.com < $EMAIL
