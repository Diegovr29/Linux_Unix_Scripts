if [ -z "$scrpt" ] || [ -z "$tktnum" ]
then
        help_fc
fi

if [ -z "$SRVLIST" ]
then
        SRVLIST="/app/scripts/tmp/srvlist.txt"
fi

SSH="/usr/bin/ssh"
SCRIPTDIR="/tmp/share_script"
NFS_SCRIPTS="pfzrjmpsl1:/app/scripts"

if [ ! -f $SRVLIST ]
then
   echo "srvlist.txt file doesn't exist. Please create with the servers you need to gather the information and run the command again"
else
   for i in `cat $SRVLIST`;
   do
#      RT=$[`$SSH -q $i  "if [ -f /usr/local/bin/pbrun ]; then echo 1; elif [ -f /usr/local/bin/sudo ]; then echo 2; else echo 0; fi"`]
#      if [ $RT = "1" ]
#      then
         ROOT="/usr/local/bin/pbrun"
         SSH="/usr/bin/ssh"
#      elif [ $RT = "2" ]
#     then 
#         ROOT="/usr/local/bin/sudo"
#         SSH="/usr/bin/ssh -t"
#     elif [ $RT -eq 0 ]
#      then
#         ROOT="/usr/bin/sudo"
#         SSH="/usr/bin/ssh -t"
#      fi
      DIREXIST=`ssh -q $i "ls -d /tmp/share_script"`
      if [ "$DIREXIST" = "/tmp/share_script" ]
      then
         $SSH -q $i "$ROOT umount /tmp/share_script; $ROOT rmdir /tmp/share_script"
      fi
      STRCHECK=`$SSH -q $i "uname -a" | awk '{print $1,$3}'`
      if [ "$STRCHECK" = "SunOS 5.10" ]
      then
         STRING="mkdir $SCRIPTDIR; $ROOT mount -o vers=3 $NFS_SCRIPTS $SCRIPTDIR; $SCRIPTDIR/$scrpt $tktnum"
      else
         STRING="mkdir $SCRIPTDIR; $ROOT mount $NFS_SCRIPTS $SCRIPTDIR; $SCRIPTDIR/$scrpt $tktnum"
      fi
      $SSH $i $STRING
   done
fi

echo "Check the file in /app/share directory ("/app/share/$tktnum.txt")"
