#!/bin/bash
DATE=`date +%Y%m%d_%H%M%S`
USER=root
PASSWD=********
BD=Interruptores
MYSQLDUMP=/usr/bin/mysqldump
FILEBACKUP=respaldoBD_$DATE.tar.gz
TMPFILEBACKUP=respaldoBD.sql
LOGFILE=/var/log/backupDB.log
EXTERNALHD=/mnt
if [ ! -f /dev/sdb1 ]
then
   echo "Disco duro no conectado"
   echo "`date "+%b %d %T"` ` hostname`: Disco duro no conectado" >> $LOGFILE
   exit 1
else
   mount /dev/sdb1 $EXTERNALHD
   $MYSQLDUMP -u $USER --add-drop-database --skip-comments -p$PASSWD -R $BD >    $TMPFILEBACKUP
   tar -zcvf $FILEBACKUP $TMPFILEBACKUP
   mv $FILEBACKUP $EXTERNALHD
   umount $EXTERNALHD
   rm $TMPFILEBACKUP
   echo "`date "+%b %d %T"` ` hostname`: $FILEBACKUP copiado en disco" >> $LOGFILE 
fi