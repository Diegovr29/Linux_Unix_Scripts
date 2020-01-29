#!/bin/bash 
#
#
#	exec_emcgrab.sh
#

if [ -f /usr/local/bin/pbrun ]
then
        ROOT="/usr/local/bin/pbrun"
elif [ -f /usr/local/bin/sudo ]
then
        ROOT="/usr/local/bin/sudo"
else 
	ROOT="/usr/bin/sudo"
fi

Check_Sol_Fc () {
   STRCHECK=`uname -a | awk '{print $1,$3}'`
   if [ "$STRCHECK" = 'SunOS 5.10' ]
   then
       $ROOT mount -o vers=3 pfzrjmpsl1:/app/share  $SHAREDIR
   else
       $ROOT mount pfzrjmpsl1:/app/share  $SHAREDIR
   fi
}

SHAREDIR=/tmp/mpshare
if [ ! -d $SHAREDIR ]
then
    $ROOT mkdir $SHAREDIR
    Check_Sol_Fc
else
    $ROOT umount -f $SHAREDIR
#    $ROOT rm -r $SHAREDIR
#    $ROOT mkdir $SHAREDIR
    Check_Sol_Fc
fi

PLATFORM=`uname -s`
if [ $PLATFORM = "SunOS" ]
then
    $ROOT at now + 3 min < /tmp/mpshare/cmdlist_sol.sh
else
    $ROOT at now + 3 min < /tmp/mpshare/cmdlist_lin.sh 
fi
