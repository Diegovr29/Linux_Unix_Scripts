
#!/bin/bash

LUN="/tmp/vrtslun"
Lun_Name="/tmp/lname.txt"
Lun_ID="/tmp/lid.txt"
Lun_Concat="/tmp/Lconcat.txt"
Lun_Sorted="/tmp/Lsorted.txt"

function EMCP {
   cat $LUN |sort -u > $Lun_Sorted

   /etc/powermt display dev=all | grep Pseudo | awk '{print $2}' | cut -f2 -d'=' > $Lun_Name
   /etc/powermt display dev=all | grep Logical | awk '{print $4" "$5}' | sed -e 's/\[//; s/\]//' > $Lun_ID

   paste $Lun_Name $Lun_ID > $Lun_Concat

   for i in `cat $Lun_Sorted`;
   do
      cat $Lun_Concat | grep $i
   done

   rm $LUN $Lun_Name $Lun_ID $Lun_Concat
}


function Sol_10 {
   if [ -f /etc/powermt ]
   then
      EMCP
   else
      for i in `cat $LUN`; do
         Lun_avid=`vxdmpadm list dmpnode dmpnodename=$i | grep avid | awk '{print $3}'`
         echo $i " => " $Lun_avid >> $Lun_ID
      done
      cat $Lun_ID
      rm $LUN $Lun_ID
   fi
}


if [ -d $LUN ]
then
   rm $LUN
fi

if [ -z "$1" ]
then
   echo "You must define at leat one Filesystem separated by spaces"
   echo "Example: ./get_lunID.sh fs1 fs2 fs3...."
   exit 1
fi

while [ -n "$1" ]
do
   for i in `vxprint -ht | grep $1 | awk '{print $8}'`; do
      if [ $i != "-" ]
      then
         echo $i"a" >> $LUN
      fi
   done
   shift
done

ARCH=`uname -r`
if [ $ARCH = "5.10" ]
   then
      Sol_10
   else
      EMCP
fi

exit 0