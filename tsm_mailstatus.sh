#!/bin/ksh
#
#	Script to send mail about the backup status
#	Don't forguet to add the extra line "echo $backupstatus > /tmp/backupstatus" at the bottom of the backup execution script
#

GZIP=/usr/contrib/bin/gzip
EMAIL_ADDRESSES="nselgmacpem@nucleussoftware.com,srs-helpdesk@nucleussoftware.com"
ALLYUNIXEMAIL="diegovr@hp.com"
LOG_FILE="$1"
ZIPPED_FILE="/tmp/`echo $1 | cut -d "/" -f4`"

cp $LOG_FILE /tmp
$GZIP $ZIPPED_FILE

backupstatus=`cat /tmp/backupstatus`

if [ "$backupstatus" -eq 4 ]
then
	MAILBODY="\"Backup succeeded on $NODENAME at `date` with warning code 4""\""
	echo $MAILBODY | mailx -r backupinfo@`uname -n`.eu.gmacfs.com -m -s "$MAILBODY" $EMAIL_ADDRESSES,$ALLYUNIXEMAIL 
elif [ "$backupstatus" -eq 0 ] 
then
	MAILBODY="\"Backup succeeded on $NODENAME at `date` with errors nor warnings""\""	
	echo $MAILBODY | mailx -r backupinfo@`uname -n`.eu.gmacfs.com -m -s "$MAILBODY" $EMAIL_ADDRESSES,$ALLYUNIXEMAIL
else
	MAILBODY="\"Backup FAILED on $NODENAME with error code $backupstatus at `date`""\""
	(echo $MAILBODY; uuencode "$ZIPPED_FILE.gz" "$ZIPPED_FILE.gz") | mailx -r backupinfo@`uname -n`.eu.gmacfs.com -m -s "$MAILBODY" $EMAIL_ADDRESSES,$ALLYUNIXEMAIL
fi

rm $ZIPPED_FILE.gz