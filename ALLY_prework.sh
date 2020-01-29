#!/bin/bash

PREWKF=/tmp/prework.txt
VARTMP_FOLDER=/var/tmp/prework_`hostname`_`date +%Y%m%d`
MAILACC=Diegovr@hp.com

mkdir $VARTMP_FOLDER

echo `hostname` >> $PREWKF
echo "----------------------------------" >> $PREWKF
echo " "

echo "iostat -Ein" >> $PREWKF
iostat -Ein >> $PREWKF 

echo " " >> $PREWKF
echo "df -k " >> $PREWKF
df -k  >> $PREWKF

echo " " >> $PREWKF
echo "dumpadm " >> $PREWKF
dumpadm >> $PREWKF

echo " " >> $PREWKF
echo " prtvtoc (all disks) " >> $PREWKF
for i in `echo | format | awk '{print $2}' | egrep -v "for|DISK|disk|^$"`; do prtvtoc /dev/rdsk/"$i"s2; echo "=================================================================="; done >> $PREWKF

echo " " >> $PREWKF
echo "metastat   " >> $PREWKF
metastat  >> $PREWKF

echo " " >> $PREWKF
echo "eeprom " >> $PREWKF
eeprom | grep boot-device>> $PREWKF

echo " " >> $PREWKF
echo "Disk devices from OBP " >> $PREWKF
prtconf -pv |grep disk >> $PREWKF

echo " " >> $PREWKF
echo "Copying files to /var/tmp " >> $PREWKF
cp -p /etc/vfstab $VARTMP_FOLDER                                                
cp -p /etc/system $VARTMP_FOLDER
echo "Files already copied " >> $PREWKF

echo " " >> $PREWKF
echo "Creating backup " >> $PREWKF
echo " " >> $PREWKF
dsmc inc /  >> $PREWKF
echo "Backup  already created" >> $PREWKF

echo " " >> $PREWKF
echo " " >> $PREWKF
echo "Prework finished " >> $PREWKF
echo " " >> $PREWKF

unix2dos $VARTMP_FOLDER/vfstab $VARTMP_FOLDER/vfstab.enc.txt
unix2dos $VARTMP_FOLDER/system $VARTMP_FOLDER/system.enc.txt

uuencode $VARTMP_FOLDER/vfstab.enc.txt vfstab.enc.txt >> /tmp/datafile.csv
uuencode $VARTMP_FOLDER/system.enc.txt system.enc.txt >> /tmp/datafile.csv
cat $PREWKF /tmp/datafile.csv > /tmp/combined.file
mailx -s "Prework to `hostname`" $MAILACC < /tmp/combined.file

echo "Please check the files attached " >> $PREWKF

echo "Mail sent to $MAILACC"
echo "In case the email hasn't been sent to your mailbox, login into the server and execute manually the command: "
echo "mailx -s "Prework to `hostname`" $MAILACC < /tmp/combined.file"
echo "or copy out of the server the following files: "
echo " "
echo "$VARTMP_FOLDER/vfstab.enc.txt vfstab.enc.txt"
echo "$VARTMP_FOLDER/system.enc.txt system.enc.txt"
echo "$PREWKF"